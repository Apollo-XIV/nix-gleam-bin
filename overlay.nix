final: prev: 
let
  mkDerivation = final.stdenv.mkDerivation;
in 
{
  buildGleamBin = final.callPackage ./buildGleamBin.nix {inherit mkDerivation;};
}
