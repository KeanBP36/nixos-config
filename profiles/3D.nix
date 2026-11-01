{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    blender
    freecad
    openscad
    orca-slicer
  ];
}
