{
  mkDerivation
, buildGleamApplication
, gleam
, nodejs
, esbuild
, denoPlatform
, deno
}:

{pname, version, src}:
let
  gleam_build = buildGleamApplication {
    pname = "gleam_build";
    src = src;
    version = version;
    target = "javascript";
  };
  js_conv = mkDerivation {
    pname = "js_conversion";
    version = version;
    src = src;
    buildInputs = [
      nodejs
      gleam
      deno
      esbuild
    ];
    buildPhase = ''
      cp -r ${gleam_build}/lib build
      mkdir dist
      # deno bundle ./build/${pname}/${pname}.mjs dist/${pname}.js
      esbuild --bundle ./build/${pname}/${pname}.mjs --outfile='dist/${pname}.js' --format=cjs
      # echo "import { main } from './${pname}.js'; main();" > dist/glue.mjs;
      cat <<-EOF > dist/glue.mjs
        import pkg from './${pname}.js';
        const {main} = pkg;
        main()
      EOF
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
