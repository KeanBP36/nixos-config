{
  description = "Kean's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-flatpak,
    catppuccin,
    ...
  }:

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
        nix-flatpak.homeManagerModules.nix-flatpak
      ];
    };
  in
  {
    nixosConfigurations = {

      desktop = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.home-manager
          commonHome
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/laptop/configuration.nix
          home-manager.nixosModules.home-manager
          commonHome
        ];
      };

    };
  };
}
