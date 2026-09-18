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

  networking.nameservers = [
  "1.1.1.1"
  "1.0.0.1"
  ];

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
#Terminial tools
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

  # BASH CONFIG START
  programs.bash = {
    enable = true;
    interactiveShellInit = ''
      
     # ─────────────────────────────────────────────
     # Welp
     # ─────────────────────────────────────────────
     alias nixwelp='sed -n "119,241p" /etc/nixos-config/hosts/common.nix'

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

     # Major branches
     alias nixconfigs='find /etc/nixos-config/configs -type f | sort'
     alias nixhome='find /etc/nixos-config/home -type f | sort'
     alias nixhosts='find /etc/nixos-config/hosts -type f | sort'
     alias nixmodules='find /etc/nixos-config/modules -type f | sort'
     alias nixpatches='find /etc/nixos-config/patches -type f | sort'
     alias nixbackup='find /etc/nixos-config/backup -type f | sort'
 
     # Tree
     alias nixtree='tree /etc/nixos-config'
 
     # ─────────────────────────────────────────────
     # NixOS — rebuild
     # ─────────────────────────────────────────────
     alias nixrebsw='sudo nixos-rebuild switch --flake /etc/nixos-config#$HOSTNAME'
 
     # ─────────────────────────────────────────────
     # Git — branch navigation
     # ─────────────────────────────────────────────
     alias nixmain='cd /etc/nixos-config && git switch main'
     alias nixtesting='cd /etc/nixos-config && git switch testing'
     alias nixalpha='cd /etc/nixos-config && git switch alpha'
     alias nixbeta='cd /etc/nixos-config && git switch beta'
     alias nixunstable='cd /etc/nixos-config && git switch unstable'
     alias nixshow='cd /etc/nixos-config && git branch --show-current'
     alias nixbranchlist='cd /etc/nixos-config && git branch -vv'
 
     # ─────────────────────────────────────────────
     # Git — current branch
     # ─────────────────────────────────────────────
     alias nixpull='cd /etc/nixos-config && git pull --ff-only'
     alias nixpush='cd /etc/nixos-config && git status && git add . && read -p "Commit message: " msg && git commit -m "$msg" && git push'
 
     # ─────────────────────────────────────────────
     # Git — testing branch
     # ─────────────────────────────────────────────
     alias nixpulltesting='cd /etc/nixos-config && git switch testing && git pull --ff-only'
     alias nixpushtesting='cd /etc/nixos-config && git switch testing && git status && git add . && read -p "Commit message: " msg && git commit -m "$msg" && git push origin testing'
 
     # ─────────────────────────────────────────────
     # Git — alpha branch
     # ─────────────────────────────────────────────
     alias nixpullalpha='cd /etc/nixos-config && git switch alpha && git pull --ff-only'
     alias nixpushalpha='cd /etc/nixos-config && git switch alpha && git status && git add . && read -p "Commit message: " msg && git commit -m "$msg" && git push origin alpha'
 
     # ─────────────────────────────────────────────
     # Git — beta branch
     # ─────────────────────────────────────────────
     alias nixpullbeta='cd /etc/nixos-config && git switch beta && git pull --ff-only'
     alias nixpushbeta='cd /etc/nixos-config && git switch beta && git status && git add . && read -p "Commit message: " msg && git commit -m "$msg" && git push origin beta'
 
     # ─────────────────────────────────────────────
     # Git — unstable branch
     # ─────────────────────────────────────────────
     alias nixpullunstable='cd /etc/nixos-config && git switch unstable && git pull --ff-only'
     alias nixpushunstable='cd /etc/nixos-config && git switch unstable && git status && git add . && read -p "Commit message: " msg && git commit -m "$msg" && git push origin unstable'
     
     # Show commits on unstable that are not on main
     alias nixunstablelog='cd /etc/nixos-config && git log --oneline main..unstable'
 
     # Show commits on unstable that are not on testing
     alias nixunstabletestinglog='cd /etc/nixos-config && git log --oneline testing..unstable'
 
     # Show commits on main that are not on unstable
     alias nixmainunstablelog='cd /etc/nixos-config && git log --oneline unstable..main'
 
     # ─────────────────────────────────────────────
     # Git — selective branch synchronization
     # ─────────────────────────────────────────────
     # Show commits available from each branch
     alias nixlogmain='cd /etc/nixos-config && git log --oneline main'
     alias nixlogtesting='cd /etc/nixos-config && git log --oneline testing'
     alias nixlogunstable='cd /etc/nixos-config && git log --oneline unstable'
 
     # Selectively copy a commit into the current branch
     alias nixsync='cd /etc/nixos-config && git cherry-pick'
   
     # Compare branches
     alias nixdiffmain='cd /etc/nixos-config && git diff main..HEAD'
     alias nixdifftesting='cd /etc/nixos-config && git diff testing..HEAD'
     alias nixdiffunstable='cd /etc/nixos-config && git diff unstable..HEAD'
 
      # ─────────────────────────────────────────────
      # Git — branch synchronization
      # ─────────────────────────────────────────────
      # Testing follows main when intentionally synchronized
      alias nixsynctesting='cd /etc/nixos-config && git switch testing && git reset --hard main && git push --force-with-lease origin testing'
 
      # Merge testing into main
      alias nixmerge='cd /etc/nixos-config && git switch main && git merge testing && git push origin main'
 
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
  # BASH CONFIG END

  system.stateVersion = "26.05";
}
