(
  final: prev:
  let
    pkgs = prev;

    foundryvtt-rest-api-relay-src = pkgs.fetchFromGitHub {
      owner = "ThreeHats";
      repo = "foundryvtt-rest-api-relay";
      rev = "2.1.2";
      hash = "sha256-Kwb36/zmu0Pctk4qthPigleqEvLQ+kihrToVHiShUM0=";
    };

    foundryvtt-rest-api-relay-patched-src =
      pkgs.runCommand "foundryvtt-rest-api-relay-src-patched" { }
        ''
          cp -r ${foundryvtt-rest-api-relay-src} $out
          chmod -R u+w $out
          cp ${./package-lock.json} $out/package-lock.json
          patch -d $out -p1 < ${./fix-express-types.patch}
        '';

    foundryvtt-rest-api-relay =
      with pkgs;
      buildNpmPackage {
        pname = "foundryvtt-rest-api-relay";
        version = "2.1.2";

        src = foundryvtt-rest-api-relay-patched-src;

        npmDepsHash = "sha256-CmbwuVyZrP6y5u+qW4h/8+Lj2QN5C8igichLTFY8DTo=";

        npmInstallFlags = [
          "--logs-dir=."
        ];

        nativeBuildInputs = [ ];

        env = {
          PUPPETEER_SKIP_DOWNLOAD = "true";
          npm_config_loglevel = "verbose";
        };

        doCheck = false;
      };
  in
  {
    inherit foundryvtt-rest-api-relay;
  }
)
