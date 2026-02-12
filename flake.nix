{
  description = "Loreduck - Obsidian world-building assistant powered by Claude";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells = with pkgs; {
          default = mkShell {
            nativeBuildInputs = [
              libwebp
            ];

            buildInputs = [ ];
            env = { };
            shellHook = ''
              echo "🦆 QUACK! Loreduck shell loaded"
              echo ""
              echo "Don't forget to export GEMINI_API_KEY!"
            '';
          };
        };
      }
    );

}
