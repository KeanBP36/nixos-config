{ config, pkgs, inputs, unstable, username, ... }:

{
  imports = [
    ./bash.nix
    ./coding.nix
    ../../modules/distrobox.nix
  ];

  # ─────────────────────────────────────────────
  # Home
  # ─────────────────────────────────────────────

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";


  # ─────────────────────────────────────────────
  # Environment
  # ─────────────────────────────────────────────

  home.sessionVariables = {
    XDG_DATA_DIRS =
      "/home/${username}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share";
  };


  # ─────────────────────────────────────────────
  # Packages
  # ─────────────────────────────────────────────

  programs.obs-studio.enable = true;

  home.packages = with pkgs; [     
    # Terminals and editors
    kitty
    neovim
    fastfetch

    # Gaming
    steam
    prismlauncher
    heroic

    # Communication and collaboration
    discord
    thunderbird
    
    # Web browsing
    qutebrowser
    #helium as flake
    #librewolf and flatpak

    # File management and archives
    kdePackages.dolphin
    ranger
    xarchiver

    # Desktop workflow
    kdePackages.kdeconnect-kde
    playerctl
    cliphist
    flameshot
    gthumb

    # Audio, music and sound
    cava
    audacity
    vlc
    ardour
    lmms
    
    # Video editing and recording
    kdePackages.kdenlive
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    yt-dlp

    # Image editing and illustration
    gimp
    krita
    inkscape
    imagemagick

    # Photography
    darktable
    rawtherapee

    # 3D modelling, animation and printing
    blender
    freecad
    openscad
    orca-slicer

    # Publishing, documents and PDFs
    scribus
    libreoffice
    pdfarranger
    kdePackages.okular
    xournalpp
   
    # Downloads and file transfer
    qbittorrent
    aria2
    rclone
    localsend
    rpi-imager

    # Password management and privacy
    bitwarden-desktop

    # Development and technical utilities
    openrgb
    hollywood
    pear-desktop

    # Media utilities
    ffmpeg
    ffmpegthumbnailer

    # Electronics and circuit simulation
    kicad
    ngspice

    # Engineering: mesh generation, simulation and visualisation
    gmsh
    elmerfem
    paraview  

    # Rocketry
    openrocket

    # Fonts
    nerd-fonts.symbols-only
  ];
  # ─────────────────────────────────────────────
  # Kitty
  # ─────────────────────────────────────────────

  programs.kitty = {
    enable = true;

    extraConfig = ''
      # Theme
      background #1f1f1f
      foreground #d4d4d4

      cursor #d4d4d4
      cursor_text_color #1f1f1f

      selection_background #3a3a3a
      selection_foreground #d4d4d4

      # Terminal colors
      color0  #1f1f1f
      color1  #f44747
      color2  #608b4e
      color3  #dcdcaa
      color4  #569cd6
      color5  #c586c0
      color6  #4ec9b0
      color7  #d4d4d4

      color8  #666666
      color9  #f44747
      color10 #608b4e
      color11 #dcdcaa
      color12 #569cd6
      color13 #c586c0
      color14 #4ec9b0
      color15 #ffffff

      # Appearance
      font_size 11.0

      cursor_shape block
      cursor_blink_interval 0

      window_padding_width 8

      confirm_os_window_close 0
      enable_audio_bell no
    '';
  };


  # ─────────────────────────────────────────────
  # Neovim
  # ─────────────────────────────────────────────

  home.file = {
    ".config/nvim/init.lua".source =
      ../../configs/nvim/init.lua;

    ".config/nvim/lazy-lock.json".source =
      ../../configs/nvim/lazy-lock.json;

    # Hyprland
    ".config/hypr/hyprland.lua" = {
      source = ../../configs/hypr/hyprland.lua;
      force = true;
    };

    ".config/hypr/hyprtoolkit.conf".source =
      ../../configs/hypr/hyprtoolkit.conf;

    ".config/hypr/hyprlock.conf".source =
      ../../configs/hyprlock/hyprlock.conf;

    # Quickshell
    ".config/quickshell/bar/shell.qml" = {
      source = ../../configs/quickshell/bar/shell.qml;
      force = true;
    };

    ".config/quickshell/bar/ControlPanel.qml" = {
      source = ../../configs/quickshell/bar/ControlPanel.qml;
      force = true;
    };

    ".config/quickshell/bar/AudioPanel.qml" = {
      source = ../../configs/quickshell/bar/AudioPanel.qml;
      force = true;
    };

    ".config/quickshell/bar/NetworkPanel.qml" = {
      source = ../../configs/quickshell/bar/NetworkPanel.qml;
      force = true;
    };

    ".config/quickshell/bar/BluetoothPanel.qml" = {
      source = ../../configs/quickshell/bar/BluetoothPanel.qml;
      force = true;
    };

    # Fastfetch
    ".config/fastfetch/config.jsonc".source =
      ../../configs/fastfetch/config.jsonc;
  };


  # ─────────────────────────────────────────────
  # Qutebrowser
  # ─────────────────────────────────────────────

  xdg.configFile."qutebrowser/config.py".source =
    ../../configs/qutebrowser/config.py;

  xdg.configFile."qutebrowser/bookmarks/urls" = {
    source = ../../configs/qutebrowser/bookmarks;
    force = true;
  };


  # ─────────────────────────────────────────────
  # Other application configs
  # ─────────────────────────────────────────────

  xdg.configFile."btop/btop.conf" = {
    source = ../../configs/btop/btop.conf;
    force = true;
  };

  xdg.configFile."rofi/config.rasi".source =
    ../../configs/rofi/config.rasi;

  xdg.configFile."mako/config" = {
    source = ../../configs/mako/config;
    force = true;
  };


  # ─────────────────────────────────────────────
  # Neovim desktop entry
  # Opens files in Neovim inside Kitty
  # ─────────────────────────────────────────────

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    comment = "Edit text and code files in Neovim";
    exec = "kitty nvim %F";
    terminal = false;
    categories = [ "Utility" "TextEditor" ];

    mimeType = [
      "text/plain"
      "text/markdown"
      "text/x-markdown"
      "text/html"
      "text/css"
      "text/xml"
      "application/xml"
      "application/json"
      "application/javascript"
      "text/javascript"
      "text/x-python"
      "text/x-shellscript"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
      "text/x-csrc"
      "text/x-chdr"
      "text/x-rust"
      "text/x-go"
      "text/x-lua"
      "text/x-nix"
      "application/x-nix"
      "text/x-java"
      "text/x-makefile"
      "text/x-yaml"
      "application/yaml"
      "application/x-yaml"
      "text/x-toml"
      "application/toml"
      "text/x-sql"
      "text/x-php"
      "text/x-perl"
      "text/x-ruby"
      "text/x-scss"
      "text/x-less"
      "application/x-desktop"
      "application/x-zerosize"
    ];
  };


  # ─────────────────────────────────────────────
  # Catppuccin
  # ─────────────────────────────────────────────

  catppuccin = {
    enable = true;
    autoEnable = true;

    flavor = "mocha";
    accent = "blue";

    kitty.enable = true;
    nvim.enable = true;
  };


  # ─────────────────────────────────────────────
  # Default applications
  # ─────────────────────────────────────────────

  # Resolve conflicts with an existing mimeapps.list.
  xdg.configFile."mimeapps.list".force = true;

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # Web browser
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";

      # File manager
      "inode/directory" = "thunar.desktop";

      # Text and code
      "text/plain" = "nvim.desktop";
      "text/markdown" = "nvim.desktop";
      "text/x-markdown" = "nvim.desktop";
      "text/html" = "nvim.desktop";
      "text/css" = "nvim.desktop";
      "text/xml" = "nvim.desktop";
      "application/xml" = "nvim.desktop";
      "application/json" = "nvim.desktop";
      "application/javascript" = "nvim.desktop";
      "text/javascript" = "nvim.desktop";
      "text/x-python" = "nvim.desktop";
      "text/x-shellscript" = "nvim.desktop";
      "application/x-shellscript" = "nvim.desktop";
      "text/x-c" = "nvim.desktop";
      "text/x-c++" = "nvim.desktop";
      "text/x-csrc" = "nvim.desktop";
      "text/x-chdr" = "nvim.desktop";
      "text/x-rust" = "nvim.desktop";
      "text/x-go" = "nvim.desktop";
      "text/x-lua" = "nvim.desktop";
      "text/x-nix" = "nvim.desktop";
      "application/x-nix" = "nvim.desktop";
      "text/x-java" = "nvim.desktop";
      "text/x-makefile" = "nvim.desktop";
      "text/x-yaml" = "nvim.desktop";
      "application/yaml" = "nvim.desktop";
      "application/x-yaml" = "nvim.desktop";
      "text/x-toml" = "nvim.desktop";
      "application/toml" = "nvim.desktop";
      "text/x-sql" = "nvim.desktop";
      "text/x-php" = "nvim.desktop";
      "text/x-perl" = "nvim.desktop";
      "text/x-ruby" = "nvim.desktop";
      "text/x-scss" = "nvim.desktop";
      "text/x-less" = "nvim.desktop";
      "application/x-desktop" = "nvim.desktop";

      # PDFs
      "application/pdf" = "onlyoffice-desktopeditors.desktop";

      # Images
      "image/jpeg" = "org.gnome.gThumb.desktop";
      "image/png" = "org.gnome.gThumb.desktop";
      "image/gif" = "org.gnome.gThumb.desktop";
      "image/webp" = "org.gnome.gThumb.desktop";
      "image/tiff" = "org.gnome.gThumb.desktop";

      # Video
      "video/mp4" = "vlc.desktop";
      "video/x-matroska" = "vlc.desktop";
      "video/webm" = "vlc.desktop";
      "video/x-msvideo" = "vlc.desktop";

      # Audio
      "audio/mpeg" = "vlc.desktop";
      "audio/flac" = "vlc.desktop";
      "audio/ogg" = "vlc.desktop";
      "audio/wav" = "vlc.desktop";

      # Torrents
      "application/x-bittorrent" =
        "org.qbittorrent.qBittorrent.desktop";

      # Email
      "x-scheme-handler/mailto" = "thunderbird.desktop";
    };
  };
}
