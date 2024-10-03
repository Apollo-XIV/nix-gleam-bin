{
  description = "Builds nix packages and static binaries from gleam projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-gleam.url = "github:arnarg/nix-gleam";
    nix-deno = {
      type = "github";
      owner = "nekowinston";
      repo = "nix-deno";
      rev = "8223a3544a7cea8063ebba7a5d19d802293bb9e1";
    };
  };

  outputs = { self, nixpkgs, nix-gleam, nix-deno }: 
  let
    overlay = import ./overlay.nix;
    combinedOverlays = [ 
      nix-gleam.overlays.default 
      nix-deno.overlays.default
      overlay 
    ];

    systems = [ "x86_64-linux" ];
    forAllSystems = f: builtins.listToAttrs (map (system: { name = system; value = f system; }) systems);
  in
  {
#   OVERLAY - makes buildGleamBin available
    overlays.default = combinedOverlays;

#   PACKAGES - builds a test binary
    packages = forAllSystems (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = combinedOverlays;
      };
    in 
    {
      default = pkgs.mkGleamBinary {
        pname = "test_package";
        src = ./examples/simple;
        version = "1.0.0";
      };
    });


#   DEV SHELL
    devShells = forAllSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = combinedOverlays;
        };
      in
      {
        default = pkgs.mkShell {
          packages = with pkgs; [
            esbuild
          ];          
        };
      }
    );
  };
 }
