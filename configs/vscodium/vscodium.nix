{ pkgs, lib, ... }:
{
  programs.vscodium = {
    enable = true;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        # Editor
        vscodevim.vim
        jnoortheen.nix-ide
        mkhl.direnv

        # Languages
        sumneko.lua
        ms-pyright.pyright
        llvm-vs-code-extensions.vscode-clangd
        rust-lang.rust-analyzer
        golang.go
        mads-hartmann.bash-ide-vscode

        # Python
        charliermarsh.ruff
        ms-python.python

        # Formatters
        foxundermoon.shell-format
        esbenp.prettier-vscode

        # Linters
        timonwong.shellcheck
        dbaeumer.vscode-eslint
        davidanson.vscode-markdownlint

        # Extras
        gruntfuggly.todo-tree
        redhat.vscode-yaml

        # Discord Rich Presence
        leonardssh.vscord
      ];

      userSettings = lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./settings.json)) {
        "workbench.colorTheme" = lib.mkForce "Default Dark Modern";
      };

      keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
    };
  };
}
