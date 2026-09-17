{ config, pkgs, ... }:

{
  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Networking
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  # Locale
  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_ZA.UTF-8";

  # Keyboard
  services.xserver.xkb = {
    layout = "za";
    variant = "";
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Login
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
        user = "keanbp";
      };
    };
  };

  # Printing
  services.printing.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Firefox
  programs.firefox.enable = true;

  # Unfree
  nixpkgs.config.allowUnfree = true;

  # User
  users.users.keanbp = {
    isNormalUser = true;
    description = "Kean Brandt Pieterse";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Shared system packages
  environment.systemPackages = with pkgs; [
    flatpak
    git
    hyprlauncher
  ];

  # Bash
  programs.bash = {
    enable = true;

    interactiveShellInit = ''
      fastfetch

      alias ll='ls -lah'
      alias la='ls -A'
      alias ..='cd ..'

      # NixOS
      alias nixconf='nvim /etc/nixos/hosts/$HOSTNAME/configuration.nix'
      alias nixhconf='nvim /etc/nixos/home/keanbp/home.nix'
      alias nixrebsw='sudo nixos-rebuild switch --flake /etc/nixos#$HOSTNAME'
      alias flakeup='cd /etc/nixos && nix flake update'

      # Hyprland
      alias hyprconf='nvim /etc/nixos-config/configs/hypr/hyprland.lua'
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

  system.stateVersion = "26.05";
}
