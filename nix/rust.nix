(final: prev: {
  rollpoly =
    with prev;
    rustPlatform.buildRustPackage rec {
      pname = "rollpoly";
      version = "0.9.0";

      src = fetchCrate {
        inherit pname version;
        sha256 = "sha256-/ijnTORhL3uuoRRhKygOu3WUyalM73syajy8qHMw52Q=";
      };

      cargoHash = "sha256-xp7B1CQ8Pabky4uR7kPOrGc01wJlUEhTTb+sKlErzsk=";
    };

  kreuzberg-cli =
    with prev;
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
})
