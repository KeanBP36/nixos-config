{ config, pkgs, lib, ... }:

let

# ============================================================

# Distrobox definitions

# ============================================================

distroboxes = {

alpine = {
  image = "docker.io/library/alpine:latest";
  packages = [
    "fastfetch"
  ];
  exports = {
    apps = [ ];
    bins = [ ];
  };
};

arch = {
  image = "docker.io/library/archlinux:latest";
  packages = [
    "fastfetch"
  ];
  exports = {
    apps = [ ];
    bins = [ ];
  };
};

debian = {
  image = "docker.io/library/debian:stable";
  packages = [
    "fastfetch"
  ];
  exports = {
    apps = [ ];
    bins = [ ];
  };
};

fedora = {
  image = "quay.io/fedora/fedora:latest";
  packages = [
    "fastfetch"
  ];
  exports = {
    apps = [ ];
    bins = [ ];
  };
};

gentoo = {
  image = "docker.io/gentoo/stage3:latest";
  packages = [
    "fastfetch"
  ];
  exports = {
    apps = [ ];
    bins = [ ];
  };
};

opensuse = {
  image = "registry.opensuse.org/opensuse/leap:latest";
  packages = [
    "fastfetch"
  ];
  exports = {
    apps = [ ];
    bins = [ ];
  };
};

slackware = {
  image = "docker.io/vbatts/slackware:current";
  packages = [
    "fastfetch"
  ];
  exports = {
    apps = [ ];
    bins = [ ];
  };
};

void = {
  image = "ghcr.io/void-linux/void-glibc-full:latest";
  packages = [
    "fastfetch"
  ];
  exports = {
    apps = [ ];
    bins = [ ];
  };
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
packageArgs = lib.escapeShellArgs packages;
in
{
Unit = {
Description = "Distrobox ${name}";
};

  Service = {
    Type = "oneshot";
    RemainAfterExit = true;
    Environment = [ "PATH=${runtimePath}" ];

    ExecStart = pkgs.writeShellScript "distrobox-${name}" ''
      set -euo pipefail

      echo "============================================"
      echo "Distrobox: ${name}"
      echo "============================================"

      # --------------------------------------------------------
      # Check whether the box already exists
      # --------------------------------------------------------

      boxes=$(distrobox list --no-color)

      if ! printf '%s\n' "$boxes" | awk -F'|' -v name="${name}" '
            {
              gsub(/[[:space:]]/, "", $2)
              if ($2 == name)
                found = 1
            }
            END {
              exit !found
            }
          '; then

        echo "Creating Distrobox: ${name}"

        distrobox create \
          --yes \
          --name "${name}" \
          --image "${cfg.image}"

      else
        echo "Distrobox already exists: ${name}"
      fi

      # --------------------------------------------------------
      # Install declared packages
      # --------------------------------------------------------

      ${lib.optionalString (packages != [ ]) ''
        echo "Installing packages in ${name}..."

        distrobox enter "${name}" -- bash -c '
          set -euo pipefail
          packages=("$@")

          if command -v pacman >/dev/null 2>&1; then
            sudo pacman -Syu --needed --noconfirm "''${packages[@]}"

          elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y "''${packages[@]}"

          elif command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y "''${packages[@]}"

          elif command -v apk >/dev/null 2>&1; then
            sudo apk add "''${packages[@]}"

          elif command -v zypper >/dev/null 2>&1; then
            sudo zypper --non-interactive install "''${packages[@]}"

          elif command -v xbps-install >/dev/null 2>&1; then
            sudo xbps-install -Sy "''${packages[@]}"

          elif command -v emerge >/dev/null 2>&1; then
            sudo emerge --quiet-build "''${packages[@]}"

          elif command -v slackpkg >/dev/null 2>&1; then
            sudo slackpkg install-new "''${packages[@]}"

          else
            echo "ERROR: Unsupported package manager" >&2
            exit 1
          fi
        ' -- ${packageArgs}
      ''}

      # --------------------------------------------------------
      # Export desktop applications
      # --------------------------------------------------------

      ${lib.concatMapStrings (app: ''
        echo "Exporting application: ${app}"

        distrobox enter "${name}" -- \
          distrobox-export \
          --app ${lib.escapeShellArg app}
      '') apps}

      # --------------------------------------------------------
      # Export binaries
      # --------------------------------------------------------

      ${lib.optionalString (bins != [ ]) ''
        mkdir -p "$HOME/.local/bin"
      ''}

      ${lib.concatMapStrings (bin: ''
        echo "Exporting binary: ${bin}"

        distrobox enter "${name}" -- \
          distrobox-export \
          --bin ${lib.escapeShellArg bin} \
          --export-path "$HOME/.local/bin"
      '') bins}

      echo "Distrobox ${name} is ready."
    '';
  };

  Install = {
    WantedBy = [ "default.target" ];
  };
};

in
{
home.packages = [
pkgs.distrobox
];

systemd.user.services =
lib.mapAttrs'
(
name: cfg:
lib.nameValuePair
"distrobox-${name}"
(mkDistrobox name cfg)
)
distroboxes;
}

