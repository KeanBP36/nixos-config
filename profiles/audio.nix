{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    audacity
    vlc
    ardour
    lmms
  ];
}
