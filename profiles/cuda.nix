{ pkgs, ... }:

{
  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (pkgs.lib.getName pkg) [
      "cuda_nvcc"
      "cuda_cudart"
    ];

  environment.systemPackages = with pkgs.cudaPackages; [
    cuda_nvcc
    cuda_cudart
  ];
}
