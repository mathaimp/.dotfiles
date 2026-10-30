# Olympus NixOS Config

A multi-host NixOS flake built on **flake-parts** + **import-tree**, covering a Hyprland laptop, a Raspberry Pi home server, and a VM testbed. Themes are handled with **Stylix**, secrets with **sops-nix**, and secure boot via **lanzaboote**.

## Customising for your machine

Each host is just a folder under `modules/hosts/` (see `ares`, `hermes`, or `proteus` as a template). To adapt this flake to your own system:

1. **Create a host folder** under `modules/hosts/<your-host>/` with at least:
   - `default.nix` — registers the `nixosConfigurations.<your-host>` entry and pulls in the modules you want (copy one of the existing hosts as a starting point).
   - `hardware.nix` — your machine's hardware config, **wrapped as a flake module**. Run `nixos-generate-config` on your machine, then take the generated `hardware-configuration.nix` contents and paste them inside a `flake.nixosModules.hostXxx = { ... }` block (see `ares/hardware.nix` for the pattern). If your machine has a matching [nixos-hardware](https://github.com/NixOS/nixos-hardware) profile, import it in `default.nix` instead of hand-writing quirks.
   - `home.nix` — defines a `flake.homeModules.<user>-<hostname>` module (e.g. `mathai-ares`) that the host's `default.nix` wires into `home-manager.users.<user>`.
2. **Set the hostname** via `networking.hostName` in the host's `default.nix`.
3. **Change the user details.** Defaults live in `modules/nixos/config/user.nix` (`name`, `fullName`, `email`) — change those, or override them per-host under `preferences.user`. The username flows into the `home-manager.users.<name>` mapping, so keep them consistent. (Search for the text `mathai` in the repo, and if you find it anywhere you probably have to replace it)
4. **Update your git identity** in `modules/home/programs/git/.gitconfig` (name, email, signing key).
5. **Pick your modules.** Each host's `default.nix` imports only the NixOS/home modules it needs — add or remove things like `nvidia`, `bluetooth`, `docker`, desktop environments, etc.

Default apps are not hard-coded: the terminal and browser modules set `preferences.terminal` / `preferences.browser` (e.g. importing `homeModules.ghostty` sets the terminal to ghostty), and keybinds only exist for what is enabled. See `modules/home/desktop/preferences.nix`.

### Secrets (sops-nix)

By default hosts source user/root passwords from sops, which expects a private `.nix-secrets` repo (referenced in `flake.nix`). **You can't build those hosts without creating your own secrets repo** with matching keys.

To get a working build without sops, follow **`proteus`** — it sets `preferences.user.useSopsPassword = false` and a plain `password`, so it needs no secrets at all.

## Hosts

| host | role | notes |
|---|---|---|
| `ares` | HP Omen 16 laptop | Hyprland, Nvidia + AMD, secure boot, btrfs, bluetooth, tailscale |
| `hermes` | Raspberry Pi 4 server | disko, Jellyfin/\*arr stack, Immich, Vaultwarden, Caddy, Glance |
| `proteus` | VM testbed | Hyprland, auto-login, builds with `nixos-rebuild build-vm` |

## Stack

| layer | choice |
|---|---|
| OS | NixOS (nixos-unstable) |
| Flake layout | flake-parts + import-tree |
| WM | Hyprland (niri also wired up) |
| Shell | Quickshell (QML bar, control center, launcher, notifications), colours from Stylix |
| Theming | Stylix (Nord, dark) + Papirus icons |
| Terminal | Ghostty (Kitty also wired up) |
| Editor | Neovim ([separate repo](https://github.com/mathaimp/nvim), submodule) + Zed |
| Shell | zsh + powerlevel10k, atuin, fzf, zoxide |
| Secrets | sops-nix (private `.nix-secrets` repo) |
| Boot | lanzaboote (secure boot) |
| Services | Jellyfin, Immich, Vaultwarden, \*arr, Caddy, Tailscale |

## Usage

```bash
# Clone (with submodules for the nvim config)
git clone --recurse-submodules git@github.com:mathaimp/.dotfiles ~/.dotfiles
cd ~/.dotfiles

# First build
sudo nixos-rebuild switch --flake .#ares   # or hermes / proteus

# Test a change without applying it
sudo nixos-rebuild dry-activate --flake .#ares
```

### Secrets

Some hosts decrypt secrets via sops-nix from a private [`.nix-secrets`](https://github.com/mathaimp/.nix-secrets) repo over SSH. Forward your agent when building those:

```bash
sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch --flake .#ares
```

## Developer tooling

```bash
nix develop -c $SHELL       # shell with treefmt, deadnix, statix, nil
treefmt          # format all .nix files
deadnix .          # find dead code
statix check .     # lint for anti-patterns
```
