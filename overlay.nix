final: prev: 
let
  mkDerivation = final.stdenv.mkDerivation;
in 
{
  mkGleamBinary = final.callPackage ./mkGleamBinary.nix {inherit mkDerivation;};
}
