{
  description = "Eason20000's reusable Nix modules";

  # Keep in sync with common/nix-substituters.nix
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    gamemaker-flake = {
      url = "github:skirlez/gamemaker-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    erosanix = {
      url = "github:emmanuelrosa/erosanix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    prelude.url = "github:Eason20000/prelude/v0.1.3";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      nixosModules.default = {
        imports = [
          ./modules/nixos
          ./pkgs
          ./lib
        ];
      };

      darwinModules.default = {
        imports = [
          ./modules/darwin
          ./pkgs
          ./lib
        ];
      };

      homeModules.default = {
        imports = [
          ./modules/home
          ./lib
        ];
      };

      homeManagerModules.default = self.homeModules.default;

      lib.my = import ./lib/my-lib.nix { inherit lib; };

      formatter = lib.genAttrs systems (
        system:
        nixpkgs.legacyPackages.${system}.nixfmt-tree.override {
          settings = {
            strict = true;
            width = 80;
          };
        }
      );
    };
}
