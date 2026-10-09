{ config, pkgs, lib, username, unstable, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_ZA.UTF-8";

  services.xserver.xkb = {
    layout = "za";
    variant = "";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  security.pam.services.hyprlock = {};

  services.greetd = {
    enable = true;

    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
      user = username;
    };
  };

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

  # Mullvad VPN: use matching packages from the locked unstable input.
  services.mullvad-vpn = {
    enable = true;
    package = unstable.mullvad;
  };

  services.hardware.openrgb.enable = true;
  services.udisks2.enable = true;

  services.printing.enable = true;

  users.users.${username} = {
    isNormalUser = true;

    extraGroups = [
      "networkmanager"
      "wheel"
      "uinput"
    ];
  };

  environment.systemPackages = with pkgs; [
    flatpak
    git
    podman
    docker
    unzip

    tree
    btop
    mpvpaper
    gcc

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
  ] ++ [
    unstable.mullvad-vpn
  ];

  programs.bash.enable = true;

  system.stateVersion = "26.05";

  users.groups.uinput = {};

  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="uinput", MODE="0660"
  '';

  virtualisation.podman.enable = true;

  virtualisation.containers.registries.search = [
    "docker.io"
  ];
}
