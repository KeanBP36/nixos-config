{ pkgs, ... }:

{
  services.flatpak.enable = true;

  systemd.services.flatpak-flathub = {
    description = "Add Flathub Flatpak remote";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak.service" ];
    serviceConfig.Type = "oneshot";

    script = ''
      sleep 15

      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists \
        flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  systemd.services.flatpak-apps = {
    description = "Install configured Flatpak applications";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-flathub.service" ];
    requires = [ "flatpak-flathub.service" ];
    serviceConfig.Type = "oneshot";

    script = ''
      ${pkgs.flatpak}/bin/flatpak install -y flathub \
        io.gitlab.librewolf-community \
        org.kde.kalzium \
        com.stremio.Stremio \
        org.vinegarhq.Sober \
        com.github.tchx84.Flatseal \
        com.heroicgameslauncher.hgl \
        io.github.Soundux \
        org.torproject.torbrowser-launcher \
        com.oppzippy.OpenSCQ30 \
        it.mijorus.gearlever


      # Mortar isn't on Flathub yet; install it from the developer's own repo
      ${pkgs.flatpak}/bin/flatpak install -y --system \
        https://mortar.rethunk.tech/packages/flatpak/tech.rethunk.Mortar.flatpakref \
        || echo "Mortar install failed"
    '';
  };
}
