{
  description = "Kean's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      catppuccin,
      ...
    }@inputs:

    let
      system = "x86_64-linux";

      # Unstable packages are opt-in.
      # Allow unfree packages such as NVIDIA.
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Shared Home Manager configuration.
      commonHome = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        home-manager.users.keanbp = {
          imports = [
            ./home/keanbp/home.nix
            catppuccin.homeModules.catppuccin
          ];
        };

        # Make inputs and the unstable package set
        # available to Home Manager modules.
        home-manager.extraSpecialArgs = {
          inherit inputs unstable;
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

          specialArgs = {
            inherit inputs unstable;
          };

          modules = [
            ./hosts/desktop/configuration.nix
            home-manager.nixosModules.home-manager
            commonHome
          ];
        };

        laptop = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./hosts/laptop/configuration.nix
            home-manager.nixosModules.home-manager
            commonHome
          ];
        };
      };
    };
}
