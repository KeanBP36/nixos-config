{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.kdenlive
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    yt-dlp
  ];
}
