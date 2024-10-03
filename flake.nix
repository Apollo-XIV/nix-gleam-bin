{
  description = "Builds nix packages and static binaries from gleam projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-gleam.url = "github:arnarg/nix-gleam";
    deno2nix.url = "github:SnO2WMaN/deno2nix";
  };

  outputs = { self, nixpkgs, nix-gleam, deno2nix }: 
  let
    overlay = import ./overlay.nix;
    combinedOverlays = [ 
      nix-gleam.overlays.default 
      deno2nix.overlays.default 
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
      default = pkgs.buildGleamBin {
        pname = "test_package";
        src = ./test_package;
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
            bun
          ];          
        };
      }
    );
  };
 }
