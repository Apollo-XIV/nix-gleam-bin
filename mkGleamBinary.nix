{
  mkDerivation
, buildGleamApplication
, fetchFromGithub
, gleam
, nodejs
, esbuild
, bun
, deno2nix
, denoPlatform
}:

{pname, version, src}:
let
  gleam_build = buildGleamApplication {
    pname = "gleam_build";
    src = src;
    version = version;
    target = "javascript";
  };
  # any precalc
  js_conv = mkDerivation {
    pname = "js_conversion";
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
      cp -r ${gleam_build}/lib build
      ls ${gleam_build}/lib
      ls build/test_package
      esbuild ./build/${pname}/${pname}.mjs --bundle
      # bun build ./build/dev/javascript/${pname}/${pname}.mjs
      echo "import { main } from './${pname}.js'; main();" > dist/glue.mjs;
      cat <<-EOF > deno.lock
        {
          "version": "3",
          "remote": {}
        }
      EOF
      # bun build ./dist/glue.mjs --compile --outfile=out
    '';
    installPhase = ''
      mkdir -p $out/lib
      cp -r dist/* $out/lib
      cp deno.lock $out/lib
    '';
  };
in
  denoPlatform.mkDenoBinary {
    name = pname;
    version = version;
    src = "${js_conv}/lib";
    permissions.allow.all = true;
    entryPoint = "glue.mjs";
  }
  # js_conv
  # deno2nix.mkExecutable {
  #   pname = pname;
  #   version = version;
  #   src = src;
  #   bin = "simple";
  #   entrypoint = "dist/glue.mjs";
  #   lockfile = "./deno.lock";
  #   config = "./deno.jsonc";
  #   allow = {
  #     all = true;
  #   };
  # }
