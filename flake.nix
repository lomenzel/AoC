{
  description = "Advent of Code";

  inputs = {
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
     

      in
      {
        devShell = pkgs.mkShell {
         pkgs.writeShellScriptBin "readme" ''
          cp ${toString (import ./default.nix)} ./README.md
         '';
        };
      }

    );
}
