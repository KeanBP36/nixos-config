{
  description = "Kean's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixpkgs-unstable,
    nix-flatpak,
    catppuccin,
    ...
  }@inputs:

  let
    system = "x86_64-linux";

    commonHome = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.keanbp = {
        imports = [
          ./home/keanbp/home.nix
          catppuccin.homeModules.catppuccin
        ];
      };

      home-manager.sharedModules = [
        ({ ... }: {
          _module.args.inputs = inputs;
        })

        nix-flatpak.homeManagerModules.nix-flatpak
      ];
    };
  in
  {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.home-manager
          commonHome
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/laptop/configuration.nix
          home-manager.nixosModules.home-manager
          commonHome
        ];
      };
    };
  };
}
