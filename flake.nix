{
  description = "Reusable NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
    catppuccin.url = "github:catppuccin/nix";

    nix-snapd = {
      url = "github:nix-community/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nix-flatpak,
    catppuccin,
    nix-snapd,
    ...
  }:

  let
    mkSystem =
      {
        system ? "x86_64-linux",
        hostname,
        username,
        hardware,
        modules ? [ ],
      }:

      let
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs unstable username hostname;
        };

        modules = [
          ./hosts/common.nix

          nix-snapd.nixosModules.default

          ./modules/snap.nix

          home-manager.nixosModules.home-manager

          {
            networking.hostName = hostname;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.${username} = {
              imports = [
                ./home/user/home.nix
                catppuccin.homeModules.catppuccin
              ];
            };

            home-manager.extraSpecialArgs = {
              inherit inputs unstable username;
            };

            home-manager.sharedModules = [
              nix-flatpak.homeManagerModules.nix-flatpak
            ];
          }

          hardware
        ]

        ++ modules;
      };
  in
  {
    lib = {
      mkSystem = mkSystem;

      profiles = {
        # GPU
        nvidia-gpu = ./profiles/nvidia-gpu.nix;
        amd-gpu = ./profiles/amd-gpu.nix;
        intel-gpu = ./profiles/intel-gpu.nix;

        # CPU
        amd-cpu = ./profiles/amd-cpu.nix;
        intel-cpu = ./profiles/intel-cpu.nix;

        # Features
        gaming = ./profiles/gaming.nix;
      };
    };
  };
}
