"""BlueZ pairing agent for the Quickshell bar.

Registers org.bluez.Agent1 as the default agent and talks to Quickshell over stdio, one JSON object per line.

Requests (stdout):  {"id": 1, "type": "confirm", "device": "/org/bluez/hci0/dev_XX", "passkey": 123456}
Replies   (stdin):  {"id": 1, "accept": true, "value": "1234"}   ("value" only for pin / passkey)
Other events:       {"type": "cancel"} when BlueZ cancels the pending request.

Request types: pin, passkey, confirm, authorize, service (with "uuid"), displayPin (with "pin"),
displayPasskey (with "passkey"); the display types need no reply.
"""

import asyncio
import json
import sys

from dbus_fast import BusType, DBusError
from dbus_fast.aio import MessageBus
from dbus_fast.service import ServiceInterface, method

AGENT_PATH = "/org/quickshell/agent"
CAPABILITY = "KeyboardDisplay"
TIMEOUT = 60

pending = {}
counter = 0


def emit(obj):
    print(json.dumps(obj), flush=True)


async def ask(kind, device, **extra):
    """Send a request to Quickshell and wait for its reply."""
    global counter
    counter += 1
    rid = counter
    future = asyncio.get_running_loop().create_future()
    pending[rid] = future
    emit({"id": rid, "type": kind, "device": device, **extra})
    try:
        reply = await asyncio.wait_for(future, TIMEOUT)
    except asyncio.TimeoutError:
        emit({"type": "cancel"})
        raise DBusError("org.bluez.Error.Canceled", "timed out")
    finally:
        pending.pop(rid, None)
    if not reply.get("accept"):
        raise DBusError("org.bluez.Error.Rejected", "rejected")
    return reply


class Agent(ServiceInterface):
    def __init__(self):
        super().__init__("org.bluez.Agent1")

    @method()
    def Release(self):
        pass

    @method()
    async def RequestPinCode(self, device: "o") -> "s":
        reply = await ask("pin", device)
        return str(reply.get("value", ""))

    @method()
    def DisplayPinCode(self, device: "o", pincode: "s"):
        emit({"type": "displayPin", "device": device, "pin": pincode})

    @method()
    async def RequestPasskey(self, device: "o") -> "u":
        reply = await ask("passkey", device)
        try:
            return int(reply.get("value", 0))
        except ValueError:
            raise DBusError("org.bluez.Error.Rejected", "invalid passkey")

    @method()
    def DisplayPasskey(self, device: "o", passkey: "u", entered: "q"):
        emit({"type": "displayPasskey", "device": device, "passkey": passkey, "entered": entered})

    @method()
    async def RequestConfirmation(self, device: "o", passkey: "u"):
        await ask("confirm", device, passkey=passkey)

    @method()
    async def RequestAuthorization(self, device: "o"):
        await ask("authorize", device)

    @method()
    async def AuthorizeService(self, device: "o", uuid: "s"):
        await ask("service", device, uuid=uuid)

    @method()
    def Cancel(self):
        for future in pending.values():
            if not future.done():
                future.set_result({"accept": False})
        emit({"type": "cancel"})


async def read_replies():
    loop = asyncio.get_running_loop()
    reader = asyncio.StreamReader()
    await loop.connect_read_pipe(lambda: asyncio.StreamReaderProtocol(reader), sys.stdin)
    while True:
        line = await reader.readline()
        if not line:
            return  # Quickshell went away
        try:
            reply = json.loads(line)
        except ValueError:
            continue
        future = pending.get(reply.get("id"))
        if future and not future.done():
            future.set_result(reply)


async def main():
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
    bus.export(AGENT_PATH, Agent())
    introspection = await bus.introspect("org.bluez", "/org/bluez")
    manager = bus.get_proxy_object("org.bluez", "/org/bluez", introspection).get_interface("org.bluez.AgentManager1")
    await manager.call_register_agent(AGENT_PATH, CAPABILITY)
    await manager.call_request_default_agent(AGENT_PATH)
    emit({"type": "ready"})
    await read_replies()


if __name__ == "__main__":
    asyncio.run(main())
