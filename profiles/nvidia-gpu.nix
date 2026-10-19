
{ config, pkgs, unstable, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = (unstable.linuxPackagesFor config.boot.kernelPackages.kernel).nvidiaPackages.stable;

    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
  };
}

