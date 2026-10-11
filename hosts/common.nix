{ config, pkgs, lib, username, unstable, ... }:

{
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    sortKey = "nixos";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "kvm-amd" ];

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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.blueman.enable = true;

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_ZA.UTF-8";

  services.xserver.xkb = {
    layout = "za";
    variant = "";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.mango = {
    enable = true;
    addLoginEntry = true;
  };

  security.pam.services.hyprlock = {};

  services.greetd = {
    enable = true;

    settings.default_session = {
      command = ''
        ${pkgs.tuigreet}/bin/tuigreet \
          --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions \
          --xsessions ${config.services.displayManager.sessionData.desktops}/share/xsessions \
          --time \
          --remember \
          --remember-user-session
      '';

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

  # Virtualization: QEMU/KVM and libvirt
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ username ];

  # Mullvad VPN
  services.mullvad-vpn = {
    enable = true;
    package = unstable.mullvad;
  };

  services.vice.enable = true;

  services.hardware.openrgb.enable = true;
  services.udisks2.enable = true;
  services.printing.enable = true;

  users.users.${username} = {
    isNormalUser = true;

    extraGroups = [
      "networkmanager"
      "wheel"
      "uinput"
      "input"
      "libvirtd"
    ];
  };

  environment.systemPackages = with pkgs; [
    flatpak
    git
    podman
    docker
    unzip
    _7zz
    zip
    wget
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
