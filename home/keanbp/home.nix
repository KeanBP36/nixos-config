{ config, pkgs, ... }:

{
  home.username = "keanbp";
  home.homeDirectory = "/home/keanbp";

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
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
    hyprlauncher
    libnotify
    jq

    # Apps
    fastfetch
    kitty
    steam
    prismlauncher
    discord
    neovim
    stremio-linux-shell
    openrgb
    thunar
    cava
    hollywood
    pear-desktop
    orca-slicer

    # Fonts
    nerd-fonts.symbols-only

  ];

  services.flatpak.packages = [
  ];

  programs.kitty = {
    enable = true;

    extraConfig = ''
      # =========================
      # Theme
      # =========================

      background #1f1f1f
      foreground #d4d4d4

      cursor #d4d4d4
      cursor_text_color #1f1f1f

      selection_background #3a3a3a
      selection_foreground #d4d4d4

      # =========================
      # Terminal Colors
      # =========================

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

      # =========================
      # Appearance
      # =========================

      font_size 11.0

      cursor_shape block
      cursor_blink_interval 0

      window_padding_width 8

      confirm_os_window_close 0
      enable_audio_bell no
    '';
  };

  home.file = {
    ".config/nvim/init.lua".source =
      ./nvim/init.lua;

    ".config/nvim/lazy-lock.json".source =
      ./nvim/lazy-lock.json;

    ".config/hypr/hyprland.lua" = {
      source = ../../configs/hypr/hyprland.lua;
      force = true;
    };

    ".config/hypr/hyprtoolkit.conf".source =
      ../../configs/hypr/hyprtoolkit.conf;

    ".config/hypr/hyprlock.conf".source =
      ../../configs/hyprlock/hyprlock.conf;

    ".config/quickshell/bar/shell.qml" = {
      source = ../../configs/quickshell/bar/shell.qml;
      force = true;
    };

    ".config/fastfetch/config.jsonc".source =
      ../../configs/fastfetch/config.jsonc;
  };

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "blue";

    kitty.enable = true;
    nvim.enable = true;
  };
}
