{
  mkDerivation
, buildGleamApplication
, fetchFromGithub
, gleam
, nodejs
, esbuild
, bun
, deno2nix
}:

{pname, version, src}:
let
  # any precalc
  js_conv = mkDerivation {
    pname = pname;
    version = version;
    src = src;
    buildInputs = [
      nodejs
      gleam
      esbuild
      bun
    ];
    # build steps will go here (leave it to me) 
    buildPhase = ''
      gleam build --target javascript
      # esbuild ./build/dev/javascript/${pname}/${pname}.mjs --bundle
      bun build ./build/dev/javascript/${pname}/${pname}.mjs
      echo "import { main } from './${pname}.js'; main();" > dist/glue.mjs;
      # bun build ./dist/glue.mjs --compile --outfile=out
    '';
    installPhase = ''
      mkdir -p $out
      cp out $out/bin
    '';
  };
in
  # js_conv
  deno2nix.mkExecutable {
    pname = pname;
    version = version;
    src = src;
    bin = "simple";
    entrypoint = "dist/glue.mjs";
    lockfile = "./deno.lock";
    config = "./deno.jsonc";
    allow = {
      all = true;
    };
  }
