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
    umu-launcher
    gamemode
    vulkan-tools
    mesa-demos
    mangohud
    gamescope
    protontricks
    winetricks
    heroic
    prismlauncher
  ];
}
