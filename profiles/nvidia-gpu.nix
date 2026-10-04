{ config, pkgs, ... }:

{
services.xserver.videoDrivers = [ "nvidia" ];

hardware.nvidia = {
package = config.boot.kernelPackages.nvidiaPackages.stable;

open = true;

modesetting.enable = true;

nvidiaSettings = true;

};
}

