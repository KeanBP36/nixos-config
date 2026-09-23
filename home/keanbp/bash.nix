{ ... }:

{
  programs.bash = {
    enable = true;

    shellAliases = {
      # General
      ll = "ls -lah";
      la = "ls -A";
      ".." = "cd ..";

      # NixOS configuration
      nixconf = "find /etc/nixos-config/hosts/$HOSTNAME -type f | sort";
      nixhconf = "find /etc/nixos-config/home/keanbp -type f | sort";
      nixcommon = "find /etc/nixos-config/hosts -name 'common.nix' -type f";
      nixshowconf = "find /etc/nixos-config -type f | sort";

      nixconfigs = "find /etc/nixos-config/configs -type f | sort";
      nixhome = "find /etc/nixos-config/home -type f | sort";
      nixhosts = "find /etc/nixos-config/hosts -type f | sort";

      nixtree = "tree /etc/nixos-config";

      # NixOS rebuild
      nixrebsw =
        "sudo nixos-rebuild switch --flake /etc/nixos-config#$HOSTNAME";

      # Configs
      nixhypr = "find /etc/nixos-config/configs/hypr -type f | sort";
      nixhyprlock = "find /etc/nixos-config/configs/hyprlock -type f | sort";
      nixquickshell = "find /etc/nixos-config/configs/quickshell -type f | sort";
      nixfastfetch = "find /etc/nixos-config/configs/fastfetch -type f | sort";

      # Git branches
      nixmain = "cd /etc/nixos-config && git switch main";
      nixtesting = "cd /etc/nixos-config && git switch testing";
      nixalpha = "cd /etc/nixos-config && git switch alpha";
      nixbeta = "cd /etc/nixos-config && git switch beta";
      nixunstable = "cd /etc/nixos-config && git switch unstable";

      nixshow = "cd /etc/nixos-config && git branch --show-current";
      nixbranchlist = "cd /etc/nixos-config && git branch -vv";

      # Git logs
      nixlogmain = "cd /etc/nixos-config && git log --oneline main";
      nixlogtesting = "cd /etc/nixos-config && git log --oneline testing";
      nixlogunstable = "cd /etc/nixos-config && git log --oneline unstable";

      nixunstablelog =
        "cd /etc/nixos-config && git log --oneline main..unstable";

      nixunstabletestinglog =
        "cd /etc/nixos-config && git log --oneline testing..unstable";

      nixmainunstablelog =
        "cd /etc/nixos-config && git log --oneline unstable..main";

      nixlogtestingto =
        "cd /etc/nixos-config && git log --oneline unstable..testing";

      nixlogunstableto =
        "cd /etc/nixos-config && git log --oneline testing..unstable";

      nixpackagecommits =
        "cd /etc/nixos-config && git log --oneline -- flake.nix flake.lock";

      # Git comparisons
      nixdiffmain = "cd /etc/nixos-config && git diff main..HEAD";
      nixdifftesting = "cd /etc/nixos-config && git diff testing..HEAD";
      nixdiffunstable = "cd /etc/nixos-config && git diff unstable..HEAD";

      nixdifftestingunstable =
        "cd /etc/nixos-config && git diff --name-status unstable..testing";

      # Git sync
      nixsync = "cd /etc/nixos-config && git cherry-pick";

      nixsynctounstable =
        "cd /etc/nixos-config && git switch unstable && git cherry-pick";

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

      nixpushalpha() {
        cd /etc/nixos-config || return
        git switch alpha || return
        git status
        git add .
        read -rp "Commit message: " msg
        git commit -m "$msg" && git push origin alpha
      }

      nixpushbeta() {
        cd /etc/nixos-config || return
        git switch beta || return
        git status
        git add .
        read -rp "Commit message: " msg
        git commit -m "$msg" && git push origin beta
      }

      nixpushunstable() {
        cd /etc/nixos-config || return
        git switch unstable || return
        git status
        git add .
        read -rp "Commit message: " msg
        git commit -m "$msg" && git push origin unstable
      }

      # ─────────────────────────────────────────────
      # Safe testing → unstable synchronization
      # ─────────────────────────────────────────────

      nixsyncunstablesafe() {
        cd /etc/nixos-config || return

        echo "Switching to unstable..."
        git switch unstable || return

        echo
        echo "Finding commits from testing not on unstable..."
        echo

        local commits
        commits=$(git rev-list --reverse unstable..testing)

        if [ -z "$commits" ]; then
          echo "Nothing to sync."
          return
        fi

        for commit in $commits; do
          local files
          files=$(git diff-tree --no-commit-id --name-only -r "$commit")

          if echo "$files" | grep -qE '^(flake\.nix|flake\.lock)$'; then
            echo "SKIP $commit — changes flake.nix/flake.lock"
            continue
          fi

          echo "SYNC $commit"

          git cherry-pick "$commit" || {
            echo "Cherry-pick failed. Resolve it manually."
            return 1
          }
        done

        echo
        echo "Mass sync complete."
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
