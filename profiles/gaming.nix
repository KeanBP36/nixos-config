{ pkgs, ... }:

{
programs.gamemode.enable = true;

environment.systemPackages = with pkgs; [
vulkan-tools
mesa-demos
mangohud
gamescope
jdk25
];
}
