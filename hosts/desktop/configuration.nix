{ ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
  };

  networking.networkmanager.unmanaged = [
    "interface-name:wlp5s0"
];

}
