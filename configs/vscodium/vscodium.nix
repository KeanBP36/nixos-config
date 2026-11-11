{ pkgs, lib, ... }:
{
  programs.vscodium = {
    enable = true;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim # modal editing, leader keys, surround, gc comments
        jnoortheen.nix-ide # nixd
        mkhl.direnv
        sumneko.lua # lua_ls
        ms-pyright.pyright
        llvm-vs-code-extensions.vscode-clangd
        rust-lang.rust-analyzer
        golang.go # gopls
        mads-hartmann.bash-ide-vscode
        # formatters
        charliermarsh.ruff
        foxundermoon.shell-format
        esbenp.prettier-vscode
        # linters
        timonwong.shellcheck
        dbaeumer.vscode-eslint
        davidanson.vscode-markdownlint
        # extras
        gruntfuggly.todo-tree # todo-comments
        redhat.vscode-yaml
      ];

      # lib.mkForce on the theme key beats catppuccin's "Catppuccin Mocha"
      userSettings = lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./settings.json)) {
        "workbench.colorTheme" = lib.mkForce "Default Dark Modern";
      };

      keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
    };
  };
}
