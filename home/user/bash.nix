{ ... }:

{
  programs.bash = {
    enable = true;

    shellAliases = {
      
      # NixOS configuration 
      nixshowtree = "find /etc/nixos-config -type f | sort";
      nixconfigs = "find /etc/nixos-config/configs -type f | sort";
      nixhome = "find /etc/nixos-config/home -type f | sort";
      nixhosts = "find /etc/nixos-config/hosts -type f | sort";
      nixmodules = "find /etc/nixos-config/modules -type f | sort";

      nixtree = "tree /etc/nixos-config";

      # NixOS rebuild
      #nixrebsw = "sudo nixos-rebuild switch --flake /etc/nixos-config#$HOSTNAME";
      nixrebsw = "sudo NIXOS_HARDWARE_CONFIG=/etc/nixos/hardware-configuration.nix nixos-rebuild switch --flake /etc/nixos-config#$HOSTNAME --impure";
      nixcheck = "NIXOS_HARDWARE_CONFIG=/etc/nixos/hardware-configuration.nix nix flake check /etc/nixos-config --impure";
 
      # Git branches
      nixmain = "cd /etc/nixos-config && git switch main";
      nixtesting = "cd /etc/nixos-config && git switch testing";
      nixshow = "cd /etc/nixos-config && git branch --show-current";
      nixbranchlist = "cd /etc/nixos-config && git branch -vv";

      # Git logs
      nixlogmain = "cd /etc/nixos-config && git log --oneline main";
      nixlogtesting = "cd /etc/nixos-config && git log --oneline testing";
       
      nixlogtestingto =
        "cd /etc/nixos-config && git log --oneline unstable..testing";
 
      nixpackagecommits =
        "cd /etc/nixos-config && git log --oneline -- flake.nix flake.lock";

      # Git comparisons
      nixdiffmain = "cd /etc/nixos-config && git diff main..HEAD";
      nixdifftesting = "cd /etc/nixos-config && git diff testing..HEAD";
      
      nixdifftestingunstable =
        "cd /etc/nixos-config && git diff --name-status unstable..testing";

      # Git sync
      nixsync = "cd /etc/nixos-config && git cherry-pick";
 
      nixshowcommit =
        "cd /etc/nixos-config && git show --stat --oneline";

      # Branch synchronization
      nixsynctesting =
        "cd /etc/nixos-config && git switch testing && git reset --hard main && git push --force-with-lease origin testing";

      nixmerge =
        "cd /etc/nixos-config && git switch main && git merge testing && git push origin main";

      # Hardware / networking
      ethup = "sudo nmcli device connect enp4s0";
    };

      initExtra = ''   
      # ─────────────────────────────────────────────
      # Environment
      # ─────────────────────────────────────────────

      export EDITOR=nvim

      # ─────────────────────────────────────────────
      # Startup
      # ─────────────────────────────────────────────

      fastfetch

      # ─────────────────────────────────────────────
      # Nix configuration
      # ─────────────────────────────────────────────

      nixwelp() {
        nvim /etc/nixos-config/hosts/common.nix
      }

      # ─────────────────────────────────────────────
      # Git push helpers
      # ─────────────────────────────────────────────

      nixpush() {
        cd /etc/nixos-config || return
        git status
        git add .
        read -rp "Commit message: " msg
        git commit -m "$msg" && git push
      }

      nixpushtesting() {
        cd /etc/nixos-config || return
        git switch testing || return
        git status
        git add .
        read -rp "Commit message: " msg
        git commit -m "$msg" && git push origin testing
      }
      
      #extra
            decrypt() {
        if [ -z "$1" ]; then
          echo "Usage: decrypt <partition>"
          echo "Example: decrypt sdc2"
          return 1
        fi

        udisksctl unlock -b "/dev/$1"
      }

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
}
