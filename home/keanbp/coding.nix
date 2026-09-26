{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ─────────────────────────────────────────────
    # General development
    # ─────────────────────────────────────────────
    git
    gnumake
    cmake
    pkg-config
    gdb
    lldb

    # ─────────────────────────────────────────────
    # C / C++
    # ─────────────────────────────────────────────
    clang
    clang-tools

    # ─────────────────────────────────────────────
    # Python
    # ─────────────────────────────────────────────
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.pytest
    python3Packages.black
    python3Packages.ruff
    python3Packages.pyautogui

    # ─────────────────────────────────────────────
    # Rust
    # ─────────────────────────────────────────────
    rustc
    cargo
    rustfmt
    clippy

    # ─────────────────────────────────────────────
    # Go
    # ─────────────────────────────────────────────
    go
    gopls

    # ─────────────────────────────────────────────
    # JavaScript / TypeScript
    # ─────────────────────────────────────────────
    nodejs
    typescript

    # ─────────────────────────────────────────────
    # Lua
    # ─────────────────────────────────────────────
    lua
    luarocks

    # ─────────────────────────────────────────────
    # Shell
    # ─────────────────────────────────────────────
    shellcheck
    shfmt

    # ─────────────────────────────────────────────
    # Assembly
    # ─────────────────────────────────────────────
    nasm

    # ─────────────────────────────────────────────
    # Development CLI tools
    # ─────────────────────────────────────────────
    jq
    yq
    ripgrep
    fd
  ];

    # ─────────────────────────────────────────────
  # Ranger
  # ─────────────────────────────────────────────

  xdg.configFile."ranger/rc.conf".source =
    ../../configs/ranger/rc.conf;

  xdg.configFile."ranger/scope.sh".source =
    ../../configs/ranger/scope.sh;

}
