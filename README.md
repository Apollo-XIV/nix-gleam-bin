# nix-gleam-bin
Build gleam apps into nix packages and static binaries.

## Build Steps
1. build gleam javascript package
  - test
2. use esbuild to minify js
3. use deno to compile static binary
