{ config, pkgs, ... }:

{
  # ─────────────────────────────────────────────
  # Boot
  # ─────────────────────────────────────────────

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.kernelPackages = pkgs.linuxPackages_latest;


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
      user = "keanbp";
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

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };


  # ─────────────────────────────────────────────
  # Printing
  # ─────────────────────────────────────────────

  services.printing.enable = true;


  # ─────────────────────────────────────────────
  # User
  # ─────────────────────────────────────────────

  users.users.keanbp = {
    isNormalUser = true;
    description = "Kean Brandt Pieterse";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };


  # ─────────────────────────────────────────────
  # Shared system packages
  # ─────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    flatpak
    git

    # Terminal utilities
    tree
    zoxide
    bat
    eza
    fd
    fzf
    tldr
    ncdu
    btop
  ];


  # ─────────────────────────────────────────────
  # Bash
  # ─────────────────────────────────────────────
  #
  # Personal aliases and functions will eventually
  # live in Home Manager instead of the system config.
  #

  programs.bash.enable = true;


  # ─────────────────────────────────────────────
  # System state
  # ─────────────────────────────────────────────

  system.stateVersion = "26.05";
}
