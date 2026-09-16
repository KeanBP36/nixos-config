# NixOS Configuration

My personal NixOS configuration, managed with **flakes + Home Manager + Git**.

## What's included

* NixOS 26.05
* Flakes
* Home Manager
* Catppuccin
* Hyprland configuration
* Quickshell configuration
* Neovim configuration
* Fastfetch configuration
* Kitty configuration
* Flatpak management
* NVIDIA desktop configuration
* Reproducible user configuration
* Git-backed configuration

## Repository layout

```text
/etc/nixos/
├── flake.nix
├── flake.lock
├── hosts/
│   └── desktop/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── home/
│   └── keanbp/
│       ├── home.nix
│       └── nvim/
│           ├── init.lua
│           └── lazy-lock.json
├── configs/
│   ├── hypr/
│   ├── quickshell/
│   └── fastfetch/
└── modules/
```

## Quick setup

### 1. Clone the repository  (WARING THIS WILL NUKE EXISTING SETUP!!!!!!)

On a fresh NixOS installation:

```bash
sudo mkdir -p /etc/nixos
sudo chown "$USER":users /etc/nixos
git clone  https://github.com/KeanBP36/nixos-config.git
cd /etc/nixos
```

> This requires GitHub SSH authentication to already be configured.

### 2. Check the configuration

```bash
cd /etc/nixos
git status
```

### 3. Build and activate

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

That's it.

The system configuration and Home Manager configuration will be activated together.

## Updating the configuration

Pull the latest configuration:

```bash
cd /etc/nixos
git pull
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```


Shared applications and user configuration can remain under:

```text
home/
configs/
modules/
```

