{
  imports = [
    ../common.nix

    ../../profiles/amd-cpu.nix
    ../../profiles/nvidia-gpu.nix
    ../../profiles/cuda.nix
    ../../profiles/gaming.nix
    ../../profiles/btrfs.nix

    ../../modules/flatpak.nix
    ../../modules/snap.nix
  ];
}
