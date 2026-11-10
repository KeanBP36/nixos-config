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

    horizon-launcher = {
      version = "0.2.58";
      url = "https://github.com/horizon-rust/horizon/releases/download/launcher%400.2.58/horizon-launcher-linux-x86_64.AppImage";
      hash = "sha256-DUBAsIt3JAz9ypUQeLkpUNAHqRNUxau1tvHpk5qjoBE=";
      desktop = true;
      extraPkgs =
        p: with p; [
          jdk25
          vulkan-loader
          libxkbcommon
          wayland
        ];
    };
  };

  # ============================================================
  # Build AppImages
  # ============================================================

  appimagePackages = lib.mapAttrsToList (
    name: app:
    let
      src = pkgs.fetchurl { inherit (app) url hash; };
      extracted = pkgs.appimageTools.extract {
        pname = name;
        inherit (app) version;
        inherit src;
      };
    in
    pkgs.appimageTools.wrapType2 {
      pname = name;
      inherit (app) version;
      inherit src;
      extraPkgs = app.extraPkgs or (_: [ ]);
      extraInstallCommands = lib.optionalString (app.desktop or false) ''
        mkdir -p $out/share/applications $out/share/icons
        cp ${extracted}/*.desktop $out/share/applications/
        cp -r ${extracted}/usr/share/icons/. $out/share/icons/
      '';
    }
  ) appimages;
in
{
  home.packages = appimagePackages;
}
