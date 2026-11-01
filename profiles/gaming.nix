{ pkgs, inputs, ... }:

{
  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;

    extraCompatPackages = [
      pkgs.proton-ge-bin
      inputs.proton-cachyos.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };

  environment.systemPackages = with pkgs; [
    vulkan-tools
    mesa-demos
    mangohud
    gamescope
    jdk25
    protontricks
    winetricks
    prismlauncher
    heroic

  ];
}
