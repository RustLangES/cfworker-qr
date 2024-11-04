{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix.url = "github:nix-community/fenix";
    flake-utils.url = "github:numtide/flake-utils";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
  # Iterate over Arm, x86 for MacOs 🍎 and Linux 🐧
    flake-utils.lib.eachSystem (flake-utils.lib.defaultSystems) (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        bundle = import ./. {
          inherit pkgs system flake-utils;
          crane = inputs.crane.mkLib pkgs;
          fenix = inputs.fenix.packages;
        };
      in {
        inherit (bundle) packages apps devShells;
      }
    );
}
