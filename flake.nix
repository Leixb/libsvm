{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          default = self.outputs.packages.${system}.libsvm-all;

          libsvm = pkgs.callPackage ./default.nix { };
          libsvm-no-omp = pkgs.callPackage ./default.nix { withOpenMP = false; };

          libsvm-all = pkgs.symlinkJoin {
            name = "libsvm-all";
            paths = with self.packages.${system}.libsvm; [ bin out dev ];
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            hyperfine
            gdb
          ];
        };
      }
    );
}
