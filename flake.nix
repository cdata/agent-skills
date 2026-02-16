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

        kreuzberg-cli =
          with pkgs;
          let
            leptonica_src = fetchFromGitHub {
              owner = "DanBloomBerg";
              repo = "leptonica";
              rev = "1.85.0";
              hash = "sha256-meiSi0qL4i/KCMe5wsRK1/mbuRLHUb55DDOnxkrXZSs=";
            };

            tesseract_src = fetchFromGitHub {
              owner = "tesseract-ocr";
              repo = "tesseract";
              rev = "5.5.1";
              sha256 = "sha256-bLTYdT9CNfgrmmjP6m0rRqJDHiSOkcuGVCFwPqT12jk=";
            };
          in
          rustPlatform.buildRustPackage rec {
            pname = "kreuzberg-cli";
            version = "4.3.3";

            src = fetchFromGitHub {
              owner = "kreuzberg-dev";
              repo = "kreuzberg";
              tag = "v${version}";
              hash = "sha256-PnrtjznUzk6dnXCOz8U9YLWeOk9hqjq8ofCi0VWxhO8=";
            };

            nativeBuildInputs = [
              cmake
              gnused
            ];

            buildInputs = [
              tesseract
              leptonica
              pdfium-binaries
            ];

            env = {
              "KREUZBERG_PDFIUM_PREBUILT" = "${pdfium-binaries}";
              "KREUZBERG_PDFIUM_SYSTEM_PATH" = "${pdfium-binaries}/lib";
              "KREUZBERG_PDFIUM_SYSTEM_INCLUDE" = "${pdfium-binaries}/include";
            };

            buildPhase = ''
              CUSTOM_OUT_DIR="$(pwd)/crates/kreuzberg-tesseract/out"
              CACHE_DIR="$CUSTOM_OUT_DIR/cache"
              THIRD_PARTY_DIR="$CUSTOM_OUT_DIR/third_party"

              echo "${pdfium-binaries}"

              mkdir -p $THIRD_PARTY_DIR

              echo "${tesseract_src}"
              echo "$LD_LIBRARY_PATH"

              cp -r "${tesseract_src}" "$THIRD_PARTY_DIR/tesseract"
              cp -r "${leptonica_src}" "$THIRD_PARTY_DIR/leptonica"
              chmod -R u+w "$THIRD_PARTY_DIR"

              export TESSERACT_RS_CACHE_DIR="$CUSTOM_OUT_DIR"

              cargo build --release -p kreuzberg-cli
            '';

            installPhase = ''
              mkdir -p "$out/bin"
              mv ./target/release/kreuzberg "$out/bin/"
            '';

            cargoHash = "sha256-iNUHelnhCAmq+HEWDmCOIsZdjDnCSA9rGzMw7d8hAjs=";

            doCheck = false;
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

              if [[ "''${DEBUG:-0}" == "1" ]]; then
                ${libwebp}/bin/cwebp -preset drawing "$IN_FILE" -o "$OUT_FILE"
              else
                ${libwebp}/bin/cwebp -preset drawing "$IN_FILE" -o "$OUT_FILE" > /dev/null 2>&1
              fi
            '';
          };
      in
      {
        devShells = with pkgs; {
          default = mkShell {
            nativeBuildInputs = [
              cachix
              libwebp
              extract-image
              create-image
              modify-image
              compose-image
              convert-to-webp
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
