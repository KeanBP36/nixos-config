{ config, pkgs, lib, ... }:

let
  # ============================================================
  # Distrobox definitions
  # ============================================================

  distroboxes = {
    arch = {
      image = "docker.io/library/archlinux:latest";
      packages = [
        "fastfetch"
      ];
      exports = {
        apps = [ ];
        bins = [ ];
      };
      # update = true;  # full system upgrade on every run
    };

    fedora = {
      image = "registry.fedoraproject.org/fedora:latest";
      packages = [
        "fastfetch"
      ];
      exports = {
        apps = [ ];
        bins = [ ];
      };
      # update = true;
    };
  };

  # ============================================================
  # Runtime environment
  # ============================================================

  runtimePath =
    lib.makeBinPath (with pkgs; [
      distrobox
      coreutils
      gnugrep
      gawk
      gnused
      findutils
    ])
    + ":/run/wrappers/bin:/run/current-system/sw/bin:/usr/bin:/bin";

  # ============================================================
  # Distrobox service
  # ============================================================

  mkDistrobox = name: cfg:
    let
      packages = cfg.packages or [ ];
      exports = cfg.exports or { };
      apps = exports.apps or [ ];
      bins = exports.bins or [ ];
      update = cfg.update or false;

      packageArgs = lib.escapeShellArgs packages;
    in
    {
      Unit.Description = "Distrobox ${name}";

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "30s";
        Environment = [ "PATH=${runtimePath}" ];

        ExecStart = pkgs.writeShellScript "distrobox-${name}" ''
          set -euo pipefail

          # ---- Create the box if it doesn't exist ----------------
          # Capture the list at top level so a failing `distrobox list`
          # aborts the unit instead of being read as "box missing".
          boxes=$(distrobox list --no-color)

          if ! printf '%s\n' "$boxes" | awk -F'|' -v name="${name}" '
                { gsub(/[[:space:]]/, "", $2); if ($2 == name) found = 1 }
                END { exit !found }
              '; then
            echo "Creating Distrobox: ${name}"
            distrobox create --yes --name "${name}" --image "${cfg.image}"
          else
            echo "Distrobox already exists: ${name}"
          fi

          # ---- Full upgrade (optional) ---------------------------
          ${lib.optionalString update ''
            echo "Updating Distrobox: ${name}"
            distrobox enter "${name}" -- bash -c '
              set -euo pipefail
              if   command -v pacman  >/dev/null 2>&1; then sudo pacman -Syu --noconfirm
              elif command -v dnf     >/dev/null 2>&1; then sudo dnf upgrade -y
              elif command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get upgrade -y
              elif command -v apk     >/dev/null 2>&1; then sudo apk update && sudo apk upgrade
              else echo "ERROR: Unsupported package manager" >&2; exit 1
              fi
            '
          ''}

          # ---- Install declared packages -------------------------
          # pacman uses -Syu: syncing without upgrading risks partial
          # upgrades, and fresh Arch images have no sync database.
          ${lib.optionalString (packages != [ ]) ''
            echo "Installing declared packages in ${name}..."
            distrobox enter "${name}" -- bash -c '
              set -euo pipefail
              packages=("$@")
              if   command -v pacman  >/dev/null 2>&1; then sudo pacman -Syu --needed --noconfirm "''${packages[@]}"
              elif command -v dnf     >/dev/null 2>&1; then sudo dnf install -y "''${packages[@]}"
              elif command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y "''${packages[@]}"
              elif command -v apk     >/dev/null 2>&1; then sudo apk add "''${packages[@]}"
              else echo "ERROR: Unsupported package manager" >&2; exit 1
              fi
            ' -- ${packageArgs}
          ''}

          # ---- Export desktop apps -------------------------------
          ${lib.concatMapStrings (app: ''
            echo "Exporting app: ${app}"
            distrobox enter "${name}" -- distrobox-export --app ${lib.escapeShellArg app}
          '') apps}

          # ---- Export binaries -----------------------------------
          ${lib.optionalString (bins != [ ]) ''
            mkdir -p "$HOME/.local/bin"
          ''}
          ${lib.concatMapStrings (bin: ''
            echo "Exporting binary: ${bin}"
            distrobox enter "${name}" -- distrobox-export \
              --bin ${lib.escapeShellArg bin} \
              --export-path "$HOME/.local/bin"
          '') bins}

          echo "Distrobox ${name} is ready."
        '';
      };

      Install.WantedBy = [ "default.target" ];
    };
in
{
  home.packages = [ pkgs.distrobox ];

  systemd.user.services =
    lib.mapAttrs'
      (name: cfg: lib.nameValuePair "distrobox-${name}" (mkDistrobox name cfg))
      distroboxes;
}
