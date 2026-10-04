{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vulkan-tools
    mesa-demos
    mangohud
    gamescope
    jdk25
  ];

  programs.gamemode.enable = true;
}
