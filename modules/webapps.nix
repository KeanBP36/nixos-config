# modules/webapps.nix
{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # ── add web apps here ───────────────────────────
  urls = [
    "https://youtube.com"
    "https://web.whatsapp.com"
    "https://github.com"
  ];
  # ────────────────────────────────────────────────

  user = "keanbp";
  dir = "/home/${user}/.local/share";
  browser = "${inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/helium";
in
{
  systemd.services.webapps = {
    description = "Install configured web apps";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = with pkgs; [
      curl
      coreutils
      gnused
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = user;
    };

    script = ''
      apps=${dir}/applications
      icons=${dir}/webapp-icons
      mkdir -p "$apps" "$icons"

      rm -f "$apps"/webapp-*.desktop

      for url in ${lib.escapeShellArgs urls}; do
        host=$(printf '%s' "$url" | sed -E 's#^[a-z]+://##; s#/.*$##; s#^www\.##')
        id=$(printf '%s' "$host" | sed 's/[^a-zA-Z0-9]/-/g')
        icon="$icons/$id.png"

        if [ ! -s "$icon" ]; then
          curl -fsSL --max-time 10 "https://www.google.com/s2/favicons?domain=$host&sz=128" -o "$icon" \
            || curl -fsSL --max-time 10 "$url/favicon.ico" -o "$icon" \
            || { rm -f "$icon"; echo "icon fetch failed for $host"; }
        fi
        [ -s "$icon" ] || icon="applications-internet"

        cat > "$apps/webapp-$id.desktop" <<EOF
      [Desktop Entry]
      Type=Application
      Name=$host
      Exec=${browser} --app=$url --class=webapp-$id
      Icon=$icon
      StartupWMClass=webapp-$id
      Categories=Network;
      EOF
      done
    '';
  };
}
