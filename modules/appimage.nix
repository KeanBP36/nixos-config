{
  config,
  pkgs,
  lib,
  ...
}:

let
  # ============================================================
  # AppImage definitions
  # ============================================================

  appimages = {
    xodus-nexus = {
      version = "0.3.10";
      url = "https://github.com/domsvoboda/xodus-nexus/releases/download/v0.3.10/Xodus-Nexus-0.3.10-x86_64.AppImage";
      hash = "sha256-jIJUUfo4xuz5bHhka4ZQIZ1IVLPDXyScgGzqeyVTvSU=";
    };
  };

  # ============================================================
  # Build AppImages
  # ============================================================

  appimagePackages = lib.mapAttrsToList (
    name: app:
    pkgs.appimageTools.wrapType2 {
      pname = name;
      version = app.version;

      src = pkgs.fetchurl {
        inherit (app) url hash;
      };
    }
  ) appimages;

in
{
  home.packages = appimagePackages;
}
