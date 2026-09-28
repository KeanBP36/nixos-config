{ pkgs, ... }:

{
  services.flatpak.enable = true;

  systemd.services.flatpak-flathub = {
    description = "Add Flathub Flatpak remote";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak.service" ];
    serviceConfig.Type = "oneshot";

    script = ''
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
        org.kde.kalzium
    '';
  };
}
