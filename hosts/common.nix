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

  # Hyprlock PAM
  security.pam.services.hyprlock = {};

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

  # ─────────────────────────────────────────────
  # Welp
  # ─────────────────────────────────────────────
  alias nixwelp='sed -n "104,167p" /etc/nixos-config/hosts/common.nix'

  # ─────────────────────────────────────────────
  # Startup
  # ─────────────────────────────────────────────
  fastfetch

  # ─────────────────────────────────────────────
  # General aliases
  # ─────────────────────────────────────────────
  alias ll='ls -lah'
  alias la='ls -A'
  alias ..='cd ..'

  # ─────────────────────────────────────────────
  # NixOS — configuration
  # ─────────────────────────────────────────────
  alias nixconf='find /etc/nixos-config/hosts/$HOSTNAME -type f | sort'
  alias nixhconf='find /etc/nixos-config/home/keanbp -type f | sort'
  alias nixcommon='find /etc/nixos-config/hosts -name "common.nix" -type f'
  alias nixshowconf='find /etc/nixos-config -type f | sort'

  # ─────────────────────────────────────────────
  # NixOS — rebuild
  # ─────────────────────────────────────────────
  alias nixrebsw='sudo nixos-rebuild switch --flake /etc/nixos-config#$HOSTNAME'

  # ─────────────────────────────────────────────
  # Git — branch navigation
  # ─────────────────────────────────────────────
  alias nixmain='cd /etc/nixos-config && git switch main'
  alias nixtest='cd /etc/nixos-config && git switch test'
  alias nixshow='cd /etc/nixos-config && git branch --show-current'

  # ─────────────────────────────────────────────
  # Git — current branch
  # ─────────────────────────────────────────────
  alias nixpull='cd /etc/nixos-config && git pull --ff-only'
  alias nixpush='cd /etc/nixos-config && git status && git add . && read -p "Commit message: " msg && git commit -m "$msg" && git push'

  # ─────────────────────────────────────────────
  # Git — test branch
  # ─────────────────────────────────────────────
  alias nixpulltest='cd /etc/nixos-config && git switch test && git pull --ff-only'
  alias nixpushtest='cd /etc/nixos-config && git switch test && git status && git add . && read -p "Commit message: " msg && git commit -m "$msg" && git push origin test'

  # ─────────────────────────────────────────────
  # Git — main branch
  # ─────────────────────────────────────────────
  alias nixpullmain='cd /etc/nixos-config && git switch main && git pull --ff-only'
  alias nixpushmain='cd /etc/nixos-config && git switch main && git status && git add . && read -p "Commit message: " msg && git commit -m "$msg" && git push origin main'

  # ─────────────────────────────────────────────
  # Git — branch synchronization
  # ─────────────────────────────────────────────
  alias nixsynctest='cd /etc/nixos-config && git switch test && git reset --hard main && git push origin test'
  alias nixmerge='cd /etc/nixos-config && git switch main && git merge test && git push origin main'

  # ─────────────────────────────────────────────
  # Config — Hyprland
  # ─────────────────────────────────────────────
  alias nixhypr='find /etc/nixos-config/configs/hypr -type f | sort'
  alias nixhyprlock='find /etc/nixos-config/configs/hyprlock -type f | sort'
  alias nixquickshell='find /etc/nixos-config/configs/quickshell -type f | sort'
  alias nixfastfetch='find /etc/nixos-config/configs/fastfetch -type f | sort'

  # ─────────────────────────────────────────────
  # Editor
  # ─────────────────────────────────────────────
  export EDITOR=nvim

  # ─────────────────────────────────────────────
  # Terminal
  # ─────────────────────────────────────────────
  ctrl_l_fastfetch() {
    clear
    fastfetch
  }

  bind -x '"\C-l":ctrl_l_fastfetch'
'';

      };

  system.stateVersion = "26.05";
}
