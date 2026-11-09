{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kicad
    ngspice
    gmsh
    elmerfem
    paraview
    openrocket
  ];
}
