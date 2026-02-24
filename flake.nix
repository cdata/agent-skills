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
        overlays = [
          (import ./nix/rust.nix)
          (import ./nix/npm)
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
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

        pdf-to-markdown =
          with pkgs;
          writeShellApplication {
            name = "pdf_to_markdown";
            runtimeInputs = [
              kreuzberg-cli
            ];
            text = ''
              if [[ $# -lt 2 ]]; then
                echo "Usage: $(basename "$0") <input>.pdf <output>.md" >&2
                exit 1
              fi

              kreuzberg extract --output-format markdown "$1" > "$2"
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

        circle-crop =
          with pkgs;
          writeShellApplication {
            name = "circle-crop";
            runtimeInputs = [
              imagemagick
              gawk
            ];
            text = builtins.readFile ./plugins/loreduck/scripts/circle-crop.sh;
          };

        convert-to-webp =
          with pkgs;
          writeShellApplication {
            name = "convert_to_webp";
            text = ''
              set -euo pipefail

              IN_FILE="$1"
              OUT_FILE="$2"

              if [[ "''${DEBUG:-0}" == "1" ]]; then
                ${libwebp}/bin/cwebp -preset drawing "$IN_FILE" -o "$OUT_FILE"
              else
                ${libwebp}/bin/cwebp -preset drawing "$IN_FILE" -o "$OUT_FILE" > /dev/null 2>&1
              fi
            '';
          };
      in
      {
        packages = {
          foundryvtt-rest-api-relay = pkgs.foundryvtt-rest-api-relay;
        };
        devShells = with pkgs; {
          default = mkShell {
            nativeBuildInputs = [
              bubblewrap
              cachix
              libwebp
              socat
              extract-image
              create-image
              modify-image
              compose-image
              circle-crop
              convert-to-webp
              pdf-to-markdown
              kreuzberg-cli
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

  nixConfig = {
    extra-substituters = [
      "https://loreduck.cachix.org"
    ];
    extra-trusted-public-keys = [
      "loreduck.cachix.org-1:m14VBAfyZzAoalBHjqBERloSIGI1Uum/HrbSYXF2rbc="
    ];
  };
}
