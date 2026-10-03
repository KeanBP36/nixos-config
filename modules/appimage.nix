{ config, pkgs, lib, ... }:

let

  # ============================================================
  # AppImage definitions
  # ============================================================

  appimages = {
    # Example:
    #
    # myapp = {
    #   url = "https://example.com/MyApp.AppImage";
    #   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    # };

  };

  # ============================================================
  # Build AppImages
  # ============================================================

  appimagePackages = lib.mapAttrsToList
    (name: app:
      pkgs.stdenv.mkDerivation {
        pname = name;
        version = "1.0";

        src = pkgs.fetchurl {
          inherit (app) url hash;
        };

        dontUnpack = true;

        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/${name}
          chmod +x $out/bin/${name}
        '';
      })
    appimages;

in
{
  home.packages = appimagePackages;
}
