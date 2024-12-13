{
  description = "Advent of Code";

 
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs = [(
         pkgs.writeShellScriptBin "readme" ''
          rm -f ./README.md
          cp ${toString (import ./default.nix)} ./README.md
         '')];
        };
      }

    );
}
