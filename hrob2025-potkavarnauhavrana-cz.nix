{ mkDerivation
, base
, containers
, filepath
, hakyll
, hakyll-contrib-tojnar
, pandoc
, stdenv
, lib
}:

mkDerivation {
  pname = "hrob2025-potkavarnauhavrana-cz";
  version = "0.0.1";

  # Keep the contents of the src/ directory and top-level .cabal file.
  src = lib.sourceByRegex ./. [ "^src(/.+|$)" "[^/]+\.cabal$" ];

  isLibrary = false;
  isExecutable = true;

  executableHaskellDepends = [
    base
    containers
    filepath
    hakyll
    hakyll-contrib-tojnar
    pandoc
  ];

  license = stdenv.lib.licenses.mit;
}
