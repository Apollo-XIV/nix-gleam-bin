# nix-gleam-bin
Builds static javascript binaries from gleam packages

## Build Steps
The mkGleamBinary function does the following to a gleam package;
1. build gleam javascript package
2. use esbuild to minify js
3. use deno to compile static binary

---
### With thanks to
- Comamoca/garnet - I based most of the build process off of this tool
- arnarg/nix-gleam - Used as part of compilation
- nekowinston/nix-deno - Used to build the final binary
