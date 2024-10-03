# nix-gleam-bin
Builds static javascript binaries from gleam packages

## Build Steps
The mkGleamBinary function does the following to a gleam package;
1. build gleam javascript package
2. use esbuild to minify js
3. use deno to compile static binary
