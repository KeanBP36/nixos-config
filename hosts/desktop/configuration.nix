{ ... }:

{
  imports = [
    ../common.nix

    ../../profiles/amd-cpu.nix
    ../../profiles/nvidia-gpu.nix
    ../../profiles/gaming.nix

    ../../modules/flatpak.nix
    ../../modules/snap.nix
  ];
}
