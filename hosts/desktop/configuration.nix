{ config, pkgs, unstable, ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # Use the latest kernel from nixpkgs-unstable.
  #boot.kernelPackages = unstable.linuxPackages_latest;

  # NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Match NVIDIA to the selected kernel package set.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
  };

  # Gaming / graphics tools
  environment.systemPackages = with pkgs; [
    vulkan-tools
    mesa-demos
    mangohud
    gamescope
    jdk25
  ];

  programs.gamemode.enable = true;

  networking.networkmanager.unmanaged = [
    "interface-name:wlp5s0"
  ];
}
