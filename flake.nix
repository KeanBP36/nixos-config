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
    hardwareConfig =
      let
        path = builtins.getEnv "NIXOS_HARDWARE_CONFIG";
      in
      if path != "" then
        [ path ]
      else
        [ ];

    mkSystem =
      {
        system ? "x86_64-linux",
        hostname,
        username,
        hostModule,
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

        modules =
          [
            hostModule

            home-manager.nixosModules.home-manager
            nix-snapd.nixosModules.default

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
          ]
          ++ hardwareConfig;
      };
  in
  {
    nixosConfigurations = {
      desktop = mkSystem {
        hostname = "desktop";
        username = "keanbp";
        hostModule = ./hosts/desktop/configuration.nix;
      };

      laptop = mkSystem {
        hostname = "laptop";
        username = "keanbp";
        hostModule = ./hosts/laptop/configuration.nix;
      };
    };

    lib = {
      inherit mkSystem;

      profiles = {
        nvidia-gpu = ./profiles/nvidia-gpu.nix;
        amd-gpu = ./profiles/amd-gpu.nix;
        intel-gpu = ./profiles/intel-gpu.nix;

        amd-cpu = ./profiles/amd-cpu.nix;
        intel-cpu = ./profiles/intel-cpu.nix;

        gaming = ./profiles/gaming.nix;
      };
    };
  };
}
