{
  imports = [
    ../common.nix

    ../../profiles/amd-cpu.nix
    ../../profiles/nvidia-gpu.nix
    ../../profiles/cuda.nix
    ../../profiles/gaming.nix
    ../../profiles/btrfs.nix
    #    ../../profiles/video.nix
    #    ../../profiles/audio.nix
    #    ../../profiles/3D.nix
    ../../profiles/documents.nix
    #    ../../profiles/engineering.nix
    #    ../../profiles/photo.nix

    ../../modules/flatpak.nix
    ../../modules/snap.nix
  ];
}
