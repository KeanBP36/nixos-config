# NixOS Configuration

My personal NixOS desktop, managed with **flakes + Home Manager**.

This is built for my own machines, not as a drop-in install. It's public so you can
take pieces of it. Most parts are separate, so you can lift one config (the
Quickshell bar, the Hyprland setup, a profile) without taking everything.
See [Borrowing from this repo](#borrowing-from-this-repo).

## What's in it

- **NixOS 26.05** with flakes, Home Manager (release-26.05) and Catppuccin
- **Hyprland** (Lua config) and **MangoWC** as a second compositor, both selectable at login
- **Quickshell** custom bar with workspaces, clock, audio visualiser (cava), Mullvad status
  and a control panel (audio, network, Bluetooth, lock, power)
- **greetd + tuigreet** login, **hyprlock** lock screen, **rofi** launcher, **mako** notifications
- **Neovim**, **kitty**, **zsh/bash**, **ranger**, **qutebrowser**, **btop**, **fastfetch**
- Gaming: Steam, GameMode, Proton-GE, CachyOS Proton, Gamescope, MangoHud
- Networking: Mullvad VPN, Tailscale, NetworkManager
- Flatpak and Snap support, AppImage, distrobox, Podman, libvirt/QEMU, VirtualBox
- NVIDIA (open driver) and AMD CPU profile for the desktop, btrfs with zstd compression

## Repository layout

```text
.
├── flake.nix              # inputs, mkSystem helper, hosts, exported profiles
├── flake.lock
├── hosts/
│   ├── common.nix         # shared system config (boot, network, audio, login, services)
│   ├── desktop/           # desktop host: AMD CPU + NVIDIA + gaming + btrfs
│   └── laptop/            # laptop host: common config + Flatpak/Snap
├── profiles/              # optional hardware/app profiles (gpu, cpu, gaming, audio, video...)
├── modules/               # appimage, distrobox, flatpak, snap
├── home/user/             # Home Manager: home.nix, bash.nix, coding.nix, mango.nix
├── packages/cupp/         # local package definition
└── configs/               # plain app configs linked into ~/.config by Home Manager
    ├── hypr/  hyprlock/  mango/
    ├── quickshell/bar/    # shell.qml + Audio/Network/Bluetooth/Control panels
    ├── nvim/  kitty/  zsh/  ranger/  qutebrowser/
    └── rofi/  mako/  btop/  fastfetch/
```

`hardware-configuration.nix` is deliberately **not** in the repo (it is gitignored).
It is machine-specific, so each machine supplies its own. See below.

## Hosts and profiles

Two hosts are defined in `flake.nix`:

| Host      | Imports |
|-----------|---------|
| `desktop` | `common.nix`, AMD CPU, NVIDIA GPU, CUDA, gaming, btrfs, documents, Flatpak, Snap |
| `laptop`  | `common.nix`, Flatpak, Snap |

Profiles in `profiles/` are plain NixOS modules. Hosts opt in by importing them.
Available: `amd-cpu`, `intel-cpu`, `amd-gpu`, `intel-gpu`, `nvidia-gpu`, `cuda`, `gaming`,
`audio`, `video`, `3D`, `photo`, `documents`, `engineering`, `btrfs`.
Some are commented out in `hosts/desktop/configuration.nix`.

`mkSystem` and the profile paths are also exported as `lib.mkSystem` and `lib.profiles`,
so another flake can reuse them.

## Installing

> **This configuration is written for my setup.** Read it before you build it. It enables
> a lot (VPN, virtualisation, Snap, Flatpak) and sets my username, locale and timezone.

1. Install NixOS normally, which generates `/etc/nixos/hardware-configuration.nix`.
2. Clone the repo to `/etc/nixos-config` (the path my aliases and the Mango config expect):

   ```bash
   sudo git clone https://github.com/KeanBP36/nixos-config.git /etc/nixos-config
   sudo chown -R "$USER":users /etc/nixos-config
   ```

3. Check the flake evaluates. The hardware config is passed in through an environment
   variable, which means the flake must be evaluated with `--impure`:

   ```bash
   cd /etc/nixos-config
   NIXOS_HARDWARE_CONFIG=/etc/nixos/hardware-configuration.nix \
     nix flake check --impure
   ```

4. Build and switch. The flake output name is the **hostname** (`desktop` or `laptop`):

   ```bash
   sudo NIXOS_HARDWARE_CONFIG=/etc/nixos/hardware-configuration.nix \
     nixos-rebuild switch --flake /etc/nixos-config#desktop --impure
   ```

Once Home Manager's bash config is active, the `nixrebsw` and `nixcheck` aliases wrap
steps 3 and 4 using `$HOSTNAME`.

## Updating

```bash
cd /etc/nixos-config
git pull
nixrebsw        # or the full nixos-rebuild command above
```

To bump inputs: `nix flake update`, then rebuild.

## Keybinds

`SUPER` is the main modifier on Hyprland. Mango uses a mix of `SUPER` and `ALT`.

| Keys | Hyprland | Mango |
|------|----------|-------|
| `SUPER + Q` | kitty | kitty |
| `SUPER + Space` | rofi launcher | rofi launcher |
| `SUPER + B` | Helium browser | Helium browser |
| `SUPER + C` | close window | close window |
| `SUPER + L` | lock (hyprlock) | lock (hyprlock) |
| `SUPER + M` | exit Hyprland | quit Mango |
| `SUPER + E` | ranger in kitty | n/a |
| `SUPER + 1-9` | go to workspace | n/a |
| `SUPER + SHIFT + 1-9` | move window to workspace | n/a |
| `SUPER + V` | toggle floating | n/a |
| `SUPER + S` | scratchpad | n/a |
| `SUPER + R` | n/a | reload config |
| `Ctrl + P` | screenshot (full) | n/a |
| `Ctrl + Shift + P` | screenshot (area) | n/a |

Screenshots are saved to `~/Pictures/Screenshots/`. Check `configs/hypr/hyprland.lua`
and `configs/mango/config.conf` for the complete lists.

## Borrowing from this repo

Easy things to take on their own:

- **Quickshell bar**: copy `configs/quickshell/bar/`. It needs `quickshell`, `cava`, and
  `mullvad` (the VPN indicator can be removed). It auto-detects Hyprland vs Mango.
- **Hyprland config**: `configs/hypr/hyprland.lua` (written for the Lua config format).
- **Profiles**: `profiles/*.nix` are small and self-contained.

Things you'll need to change, because they're specific to me:

- **Username `keanbp`**: set in `flake.nix`, and hardcoded in `configs/mango/config.conf`
  (rofi's `XDG_DATA_DIRS`) and in the Logout button of
  `configs/quickshell/bar/ControlPanel.qml`.
- **Locale, timezone, keyboard layout**: `en_ZA.UTF-8`, `Africa/Johannesburg`, `za`
  in `hosts/common.nix`.
- **Hardware assumptions in `hosts/common.nix`**: `kvm-amd` kernel module and the
  `enp3s0` wake-on-LAN interface. Move or remove these if you aren't on AMD or that NIC.
- **Services you may not want**: Mullvad, Tailscale, VirtualBox, libvirt, Snap,
  OpenRGB, and the Flatpak app list in `modules/flatpak.nix`.
- **Repo path**: `/etc/nixos-config` is used by the shell aliases in
  `home/user/bash.nix` and by Mango's autostart.
- **Aliases**: `home/user/bash.nix` contains git helpers that force-push and
  `git add .`. Read them before using them.
- **Default apps**: `xdg.mimeApps` in `home/user/home.nix` references apps that may
  not be installed on your system (Brave, Thunar, VLC, OnlyOffice).

## Credits

Built on [NixOS](https://nixos.org), [Home Manager](https://github.com/nix-community/home-manager),
[Hyprland](https://hypr.land), [MangoWC](https://github.com/mangowm/mango),
[Quickshell](https://quickshell.org) and [Catppuccin](https://github.com/catppuccin/nix).
