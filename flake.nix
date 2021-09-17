{
  description = "HROB 2021 Website";

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    hakyll-contrib-tojnar.url = "gitlab:tojnar.cz/hakyll-contrib-tojnar";

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-compat, hakyll-contrib-tojnar, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        haskellPackages = pkgs.haskellPackages.override {
          overrides = final: prev: {
            hrob2021-potkavarnauhavrana-cz = final.callPackage ./hrob2021-potkavarnauhavrana-cz.nix { };
          } // hakyll-contrib-tojnar.haskellOverlay final prev;
        };

      in {
        devShell = pkgs.mkShell {
          buildInputs = [
            self.defaultPackage.${system}
          ];
        };

        haskellDevShell = self.packages.${system}.hrob2021-potkavarnauhavrana-cz.env.overrideAttrs (attrs: {
          nativeBuildInputs = attrs.nativeBuildInputs ++ [
            pkgs.cabal-install
          ];
        });

        packages.hrob2021-potkavarnauhavrana-cz = haskellPackages.hrob2021-potkavarnauhavrana-cz;

        defaultPackage = self.packages.${system}.hrob2021-potkavarnauhavrana-cz;

        apps.hrob2021-potkavarnauhavrana-cz = utils.lib.mkApp { drv = self.packages.${system}.hrob2021-potkavarnauhavrana-cz; };

        defaultApp = self.apps.${system}.hrob2021-potkavarnauhavrana-cz;
      }
  );
}
