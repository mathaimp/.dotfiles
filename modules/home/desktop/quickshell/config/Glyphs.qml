pragma Singleton
import QtQuick
import Quickshell

// Every icon the shell uses, by name, from the Lucide icon font (https://lucide.dev, the `lucide`
// package in nixpkgs, loaded by Theme.qml). The comments are Lucide's icon names; code points
// come from lucide-static's font/info.json. To change the icon set, change only this file and
// the iconFont path in default.nix.
Singleton {
    readonly property int apps: 0xE0FF // layout-grid
    readonly property int pin: 0xE259 // pin
    readonly property int pinFilled: 0xE259 // pin
    readonly property int music: 0xE122 // music
    readonly property int messageCircle: 0xE116 // message-circle
    readonly property int code: 0xE093 // code
    readonly property int school: 0xE234 // graduation-cap
    readonly property int gamepad: 0xE0DF // gamepad-2
    readonly property int gamepad2: 0xE0DF // gamepad-2
    readonly property int brush: 0xE1D3 // brush
    readonly property int wifi: 0xE1AE // wifi
    readonly property int wifi3: 0xE5F7 // wifi-high
    readonly property int wifi2: 0xE5F7 // wifi-high
    readonly property int wifi1: 0xE5F8 // wifi-low
    readonly property int wifi0: 0xE5F9 // wifi-zero
    readonly property int wifiOff: 0xE1AF // wifi-off
    readonly property int wifiExclamation: 0xE1AF // wifi-off
    readonly property int ethernet: 0xE620 // ethernet-port
    readonly property int fileText: 0xE0CC // file-text
    readonly property int deviceDesktop: 0xE11D // monitor
    readonly property int world: 0xE0E8 // globe
    readonly property int dots: 0xE0B6 // ellipsis
    readonly property int dotsVertical: 0xE0B7 // ellipsis-vertical
    readonly property int volume: 0xE1AB // volume-2
    readonly property int volumeOff: 0xE1AC // volume-x
    readonly property int microphone: 0xE118 // mic
    readonly property int microphoneOff: 0xE119 // mic-off
    readonly property int speedometer: 0xE1BF // gauge
    readonly property int flame: 0xE0D2 // flame
    readonly property int cpu: 0xE0A9 // cpu
    readonly property int settings: 0xE154 // settings
    readonly property int x: 0xE1B2 // x
    readonly property int check: 0xE06C // check
    readonly property int headphones: 0xE0F1 // headphones
    readonly property int keyboard: 0xE284 // keyboard
    readonly property int mouse: 0xE28E // mouse
    readonly property int deviceMobile: 0xE163 // smartphone
    readonly property int bluetooth: 0xE05C // bluetooth
    readonly property int bluetoothOff: 0xE1B9 // bluetooth-off
    readonly property int bluetoothConnected: 0xE1B8 // bluetooth-connected
    readonly property int trash: 0xE18E // trash-2
    readonly property int home: 0xE0F5 // house
    readonly property int bell: 0xE059 // bell
    readonly property int bellOff: 0xE05A // bell-off
    readonly property int brightness: 0xE178 // sun
    readonly property int mug: 0xE096 // coffee
    readonly property int search: 0xE151 // search
    readonly property int lock: 0xE10B // lock
    readonly property int moon: 0xE11E // moon
    readonly property int logout: 0xE10E // log-out
    readonly property int reboot: 0xE149 // rotate-cw
    readonly property int power: 0xE140 // power
    readonly property int chevronDown: 0xE06D // chevron-down
    readonly property int chevronRight: 0xE06F // chevron-right
    readonly property int eye: 0xE0BA // eye
    readonly property int eyeOff: 0xE0BB // eye-off
    readonly property int arrowLeft: 0xE048 // arrow-left
    readonly property int plus: 0xE13D // plus
    readonly property int refresh: 0xE145 // refresh-cw
    readonly property int bolt: 0xE1B4 // zap
    readonly property int play: 0xE13C // play
    readonly property int pause: 0xE12E // pause
    readonly property int skipBack: 0xE15F // skip-back
    readonly property int skipForward: 0xE160 // skip-forward
    readonly property int user: 0xE19F // user
    readonly property int thermometer: 0xE186 // thermometer
    readonly property int memory: 0xE445 // memory-stick

    // Size correction per icon (1 = the nominal size). Lucide icons have different footprints: the
    // 2- and 1-arc Wi-Fi icons and the dot have far less ink than the full one, while the stat icons in
    // the bar fill the whole box and look big next to the text. Factors were tuned by eye.
    readonly property var scales: [
        [wifi3, 1.3],
        [wifi2, 1.3],
        [wifi1, 1.5],
        [wifi0, 1.5],
        [speedometer, 0.85],
        [flame, 0.85],
        [cpu, 0.85]
    ]

    function scaleOf(glyph) {
        return scales.find(s => s[0] === glyph)?.[1] ?? 1;
    }

    // How far below the centre of its box an icon draws, in em (measured on rendered pixels); Icon lifts
    // it by that much. Only the weaker Wi-Fi icons need it: their arcs hang low in the box.
    readonly property var drops: [
        [wifi3, 0.125],
        [wifi2, 0.125],
        [wifi1, 0.229],
        [wifi0, 0.333]
    ]

    function dropOf(glyph) {
        return drops.find(d => d[0] === glyph)?.[1] ?? 0;
    }
}
