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
              ${rollpoly}/bin/rollpoly "$1" 2> >(${gnused}/bin/sed 's/rollpoly/roll/g' >&2)
            '';
          };

        extract-nano-banana-image =
          with pkgs;
          writeShellApplication {
            name = "extract_nano_banana_image";
            text = ''
              set -euo pipefail

              RESP="$1"
              OUT="$2"

              TMPB64=$(${coreutils}/bin/mktemp /tmp/nb_b64.XXXXXX)
              trap 'rm -f "$TMPB64"' EXIT

              # Check for API errors first
              ERROR=$(${coreutils}/bin/tr -d '\000-\010\013\014\016-\037' < "$RESP" \
                | ${jq}/bin/jq -r '.error.message // empty' 2>/dev/null)
              if [[ -n "$ERROR" ]]; then
                echo "API error: $ERROR" >&2
                exit 1
              fi

              # Extract base64 image data to intermediate file
              ${coreutils}/bin/tr -d '\000-\010\013\014\016-\037' < "$RESP" \
                | ${jq}/bin/jq -r '[.candidates[0].content.parts[]
                  | select(has("inlineData") or has("inline_data"))]
                  | .[0] | (.inlineData // .inline_data).data' \
                > "$TMPB64"

              if [[ ! -s "$TMPB64" ]]; then
                echo "No image data found in response." >&2
                echo "Response structure:" >&2
                ${coreutils}/bin/tr -d '\000-\010\013\014\016-\037' < "$RESP" \
                  | ${jq}/bin/jq 'del(.. | .data? // empty)' >&2
                exit 1
              fi

              # Decode to output file
              ${coreutils}/bin/base64 -d "$TMPB64" > "$OUT"

              echo "Saved $(${coreutils}/bin/wc -c < "$OUT") bytes to $OUT"

              # Print text commentary if present
              TEXT=$(${coreutils}/bin/tr -d '\000-\010\013\014\016-\037' < "$RESP" \
                | ${jq}/bin/jq -r '.candidates[0].content.parts[] | select(has("text")) | .text' 2>/dev/null)
              if [[ -n "$TEXT" ]]; then
                echo "---"
                echo "$TEXT"
              fi           
            '';
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
              extract-nano-banana-image
              convert-to-webp
              roll
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
