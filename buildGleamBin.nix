{
  mkDerivation
, buildGleamApplication
, gleam
, nodejs
, esbuild
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
    ];
    buildPhase = ''
      cp -r ${gleam_build}/lib build
      esbuild ./build/${pname}/${pname}.mjs --bundle --minify-syntax --minify-whitespace --minify-identifiers
      echo "import { main } from './${pname}.js'; main();" > dist/glue.mjs;
      cat <<-EOF > deno.lock
        {
          "version": "3",
          "remote": {}
        }
      EOF
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
