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

        rollpoly =
          with pkgs;
          rustPlatform.buildRustPackage rec {
            pname = "rollpoly";
            version = "0.9.0";

            src = fetchCrate {
              inherit pname version;
              sha256 = "sha256-/ijnTORhL3uuoRRhKygOu3WUyalM73syajy8qHMw52Q=";
            };

            cargoHash = "sha256-xp7B1CQ8Pabky4uR7kPOrGc01wJlUEhTTb+sKlErzsk=";
          };

        roll =
          with pkgs;
          writeShellApplication {
            name = "roll";
            text = ''
              for arg in "$@"; do
                ${rollpoly}/bin/rollpoly "$arg" 2> >(${gnused}/bin/sed 's/rollpoly/roll/g' >&2)
              done
            '';
          };

        create-image =
          with pkgs;
          writeShellApplication {
            name = "create_image";
            runtimeInputs = [
              curl
              jq
              extract-image
              convert-to-webp
            ];
            text = builtins.readFile ./plugins/loreduck/scripts/create-image.sh;
          };

        modify-image =
          with pkgs;
          writeShellApplication {
            name = "modify_image";
            runtimeInputs = [
              curl
              jq
              coreutils
              extract-image
              convert-to-webp
            ];
            text = builtins.readFile ./plugins/loreduck/scripts/modify-image.sh;
          };

        compose-image =
          with pkgs;
          writeShellApplication {
            name = "compose_image";
            runtimeInputs = [
              curl
              jq
              coreutils
              extract-image
              convert-to-webp
            ];
            text = builtins.readFile ./plugins/loreduck/scripts/compose-image.sh;
          };

        extract-image =
          with pkgs;
          writeShellApplication {
            name = "extract_image";
            runtimeInputs = [
              jq
              coreutils
            ];
            text = builtins.readFile ./plugins/loreduck/scripts/extract-image.sh;
          };

        convert-to-webp =
          with pkgs;
          writeShellApplication {
            name = "convert_to_webp";
            text = ''
              set -euo pipefail

              IN_FILE="$1"
              OUT_FILE="$2"

              ${libwebp}/bin/cwebp -preset drawing "$IN_FILE" -o "$OUT_FILE"
            '';
          };
      in
      {
        devShells = with pkgs; {
          default = mkShell {
            nativeBuildInputs = [
              libwebp
              extract-image
              create-image
              modify-image
              compose-image
              convert-to-webp
              roll
            ];

            buildInputs = [ ];
            env = { };
            shellHook = ''
              echo "🦆 QUACK! Loreduck shell loaded"
              if [ -z "''${GEMINI_API_KEY}" ]; then
                echo ""
                echo "Don't forget to export GEMINI_API_KEY!"
              fi
            '';
          };
        };
      }
    );

}
