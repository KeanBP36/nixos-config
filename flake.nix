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

    nix-snapd = {
      url = "github:nix-community/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      catppuccin,
      nix-snapd,
      ...
    }@inputs:

    let
      system = "x86_64-linux";
      username = "keanbp";

      # Unstable packages are opt-in.
      # Allow unfree packages such as NVIDIA.
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Shared system configuration.
      common = {
        imports = [
          ./hosts/common.nix
          nix-snapd.nixosModules.default
        ];
      };

      # Shared Home Manager configuration.
      commonHome = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        home-manager.users.${username} = {
          imports = [
            ./home/user/home.nix
            catppuccin.homeModules.catppuccin
          ];
        };

        # Make inputs, unstable, and username available
        # to Home Manager modules.
        home-manager.extraSpecialArgs = {
          inherit inputs unstable username;
        };

        home-manager.sharedModules = [
          nix-flatpak.homeManagerModules.nix-flatpak
        ];
      };

      # Build a complete NixOS system.
      #
      # The hardware configuration is supplied by the
      # machine-specific wrapper flake, not this public repo.
      mkSystem =
        {
          hostname,
          hardware,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs unstable username;
          };

          modules = [
            common
            ./hosts/${hostname}/configuration.nix
            hardware
            home-manager.nixosModules.home-manager
            commonHome
          ];
        };
    in
    {
      # Reusable system builder.
      #
      # A local machine-specific flake supplies the hardware
      # configuration when creating a nixosConfigurations output.
      lib.mkSystem = mkSystem;
    };
}
