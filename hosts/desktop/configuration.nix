# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
 
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix 
    ];

#home-manager.users.keanbp = import ./home.nix;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  
  ##############
  ###Services###
  #flatpak
  services.flatpak.enable = true;

  #EXPERAMENTAL#
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# Enabel bluetooth
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
};
services.blueman.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Johannesburg";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_ZA.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable Hyprland and stuff
programs.hyprland = {
  enable = true;
  xwayland.enable = true;
};

services.greetd = {
  enable = true;
  settings = {
    default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
      user = "keanbp";
    };
  };
};

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "za";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # Use the WirePlumber session manager
    #wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
  ###########
  ##APPS######
  ###########
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."keanbp" = {
    isNormalUser = true;
    description = "Kean Brandt Pieterse";
extraGroups = [ "networkmanager" "wheel" ];
packages = with pkgs; [
#  kdePackages.kate
#  thunderbird
];
};

# Install firefox.
programs.firefox.enable = true;

# Allow unfree packages
nixpkgs.config.allowUnfree = true;

# List packages installed in system profile.
# You can use https://search.nixos.org/ to find more packages (and options).
environment.systemPackages = with pkgs; [
flatpak
git
#HYRPALND
hyprlauncher
# Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
#   wget
];

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

#############
###NVIDIA####
#############

hardware.graphics = {
enable = true;
enable32Bit = true;
};
services.xserver.videoDrivers = ["nvidia"];

hardware.nvidia = {
open = true;
modesetting.enable =true;
nvidiaSettings = true;
};
#bash

programs.bash = {
  enable = true;

interactiveShellInit = ''
  fastfetch

  alias ll='ls -lah'
  alias la='ls -A'
  alias ..='cd ..'

  # NixOS
  alias nixconf='nvim /etc/nixos/hosts/desktop/configuration.nix'
  alias nixhconf='nvim /etc/nixos/home/keanbp/home.nix'
  alias nixrebsw='sudo nixos-rebuild switch --flake /etc/nixos#desktop'
  alias flakeup='cd /etc/nixos && nix flake update'

  # Hyprland
  alias hyprconf='nvim /etc/nixos/configs/hypr/hyprland.lua'
  alias hyprtest='cp /etc/nixos/configs/hypr/hyprland.lua ~/.config/hypr/hyprland.lua'

  # Quickshell
  alias qsbarconf='nvim /etc/nixos/configs/quickshell/bar/shell.qml'
  alias qsbtest='cp /etc/nixos/configs/quickshell/bar/shell.qml ~/.config/quickshell/bar/shell.qml'

  # Fastfetch
  alias fetchconf='nvim /etc/nixos/configs/fastfetch/config.jsonc'

  export EDITOR=nvim

  ctrl_l_fastfetch() {
    clear
    fastfetch
  }

  bind -x '"\C-l":ctrl_l_fastfetch'
'';

};

}

