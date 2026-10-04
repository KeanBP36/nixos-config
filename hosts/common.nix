{ config, pkgs, lib, username, ... }:

{

# ─────────────────────────────────────────────

# Boot

# ─────────────────────────────────────────────

boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

# ─────────────────────────────────────────────

# Nix

# ─────────────────────────────────────────────

nix.settings.experimental-features = [
"nix-command"
"flakes"
];

nixpkgs.config.allowUnfree = true;

# ─────────────────────────────────────────────

# Networking

# ─────────────────────────────────────────────

networking.networkmanager.enable = true;

networking.nameservers = [
"1.1.1.1"
"1.0.0.1"
];

# ─────────────────────────────────────────────

# Bluetooth

# ─────────────────────────────────────────────

hardware.bluetooth = {
enable = true;
powerOnBoot = true;
};

services.blueman.enable = true;

# ─────────────────────────────────────────────

# Snap

# ─────────────────────────────────────────────

services.snap.enable = true;

# ─────────────────────────────────────────────

# Locale

# ─────────────────────────────────────────────

time.timeZone = "Africa/Johannesburg";

i18n.defaultLocale = "en_ZA.UTF-8";

# ─────────────────────────────────────────────

# Keyboard

# ─────────────────────────────────────────────

services.xserver.xkb = {
layout = "za";
variant = "";
};

# ─────────────────────────────────────────────

# Graphics

# ─────────────────────────────────────────────

hardware.graphics = {
enable = true;
enable32Bit = true;
};

# ─────────────────────────────────────────────

# Hyprland

# ─────────────────────────────────────────────

programs.hyprland = {
enable = true;
xwayland.enable = true;
};

security.pam.services.hyprlock = {};

# ─────────────────────────────────────────────

# Login

# ─────────────────────────────────────────────

services.greetd = {
enable = true;

settings.default_session = {
  command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
  user = username;
};

};

# ─────────────────────────────────────────────

# Audio

# ─────────────────────────────────────────────

services.pulseaudio.enable = false;

security.rtkit.enable = true;

services.pipewire = {
enable = true;

alsa = {
  enable = true;
  support32Bit = true;
};

pulse.enable = true;

};

# ─────────────────────────────────────────────

# Hardware

# ─────────────────────────────────────────────

services.hardware.openrgb.enable = true;

services.udisks2.enable = true;

# ─────────────────────────────────────────────

# Printing

# ─────────────────────────────────────────────

services.printing.enable = true;

# ─────────────────────────────────────────────

# User

# ─────────────────────────────────────────────

users.users.${username} = {
isNormalUser = true;

extraGroups = [
  "networkmanager"
  "wheel"
  "uinput"
];

};

# ─────────────────────────────────────────────

# Shared system packages

# ─────────────────────────────────────────────

environment.systemPackages = with pkgs; [
flatpak
git
podman
docker

# Terminal
tree
btop
mpvpaper
gcc

# Desktop
quickshell
mako
hyprlock
hypridle
awww
bibata-cursors
wl-clipboard
grim
slurp
libnotify
rofi
pavucontrol
networkmanagerapplet

];

# ─────────────────────────────────────────────

# Bash

# ─────────────────────────────────────────────

programs.bash.enable = true;

# ─────────────────────────────────────────────

# System state

# ─────────────────────────────────────────────

system.stateVersion = "26.05";

# ─────────────────────────────────────────────

# ydotool / uinput

# ─────────────────────────────────────────────

users.groups.uinput = {};

services.udev.extraRules = ''
KERNEL=="uinput", GROUP="uinput", MODE="0660"
'';

# ─────────────────────────────────────────────

# Virtualization

# ─────────────────────────────────────────────

virtualisation.podman.enable = true;

virtualisation.containers.registries.search = [
"docker.io"
];
}
