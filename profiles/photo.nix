{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gimp
    krita
    inkscape
    imagemagick
    darktable
    rawtherapee
  ];
}
