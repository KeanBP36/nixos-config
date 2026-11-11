{ pkgs, ... }:

let
  # Python environment with debugging support
  pythonWithDebugpy = pkgs.python3.withPackages (
    ps: with ps; [
      pip
      virtualenv
      pytest
      black
      ruff
      pyautogui
      debugpy
    ]
  );

  # Expose CodeLLDB on PATH for Neovim
  codelldbWrapper = pkgs.writeShellScriptBin "codelldb" ''
    exec ${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
  '';

  # Shared FHS dependencies for both editors
  editorFhsPackages =
    ps: with ps; [
      zlib
      openssl
      pkg-config
      gcc
      gnumake
    ];

in
{
  # ─────────────────────────────────────────────
  # Development Tools
  # ─────────────────────────────────────────────

  home.packages = with pkgs; [
    (vscodium.fhsWithPackages editorFhsPackages)
    #text editors
    neovim
    uemacs

    # General Development
    git
    gnumake
    cmake
    pkg-config
    gdb
    lldb

    # C / C++
    clang
    clang-tools
    cpplint

    # Python
    pythonWithDebugpy

    # Rust
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer

    # Go
    go
    gopls
    golangci-lint

    # JavaScript / TypeScript
    nodejs
    typescript
    typescript-language-server
    eslint_d
    stylelint

    # Lua
    lua
    luarocks

    # Shell
    shellcheck
    shfmt
    bash-language-server

    # Assembly
    nasm

    # Development CLI Tools
    jq
    yq
    ripgrep
    fd

    # Other Tools
    ydotool
    tree-sitter

    # Neovim Tools
    stylua
    nixfmt
    prettier
    lua-language-server
    nixd
    nil
    pyright
    statix
    luajitPackages.luacheck

    # Neovim Debugging
    codelldbWrapper

    # Syntax Checking
    yamllint
    markdownlint-cli
    hadolint
    checkmake
    ansible-lint

    # Additional Development Tools
    sqlfluff

    # Shell Utilities
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
    zoxide
    eza
    bat

    # Git GUI Applications
    github-desktop
    sourcegit
  ];

  # # ─────────────────────────────────────────────
  # # Visual Studio Code (FHS)
  # # ─────────────────────────────────────────────
  #
  # programs.vscode = {
  #   enable = true;
  #   package = pkgs.vscode.fhsWithPackages editorFhsPackages;
  # };

  # ─────────────────────────────────────────────
  # VSCodium (FHS)
  # ─────────────────────────────────────────────


  # ─────────────────────────────────────────────
  # Ranger
  # ─────────────────────────────────────────────

  xdg.configFile."ranger/rc.conf".source = ../../configs/ranger/rc.conf;

  xdg.configFile."ranger/scope.sh" = {
    source = ../../configs/ranger/scope.sh;
    executable = true;
  };
}
