{
  description = "Kean's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { nixpkgs, home-manager, nix-flatpak, catppuccin, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./hosts/desktop/configuration.nix

        home-manager.nixosModules.home-manager

        {
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
        }
      ];
    };
  };
}
