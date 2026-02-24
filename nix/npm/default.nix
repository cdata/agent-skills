let
  foundryvtt-rest-api-relay = (import ./foundryvtt-rest-api-relay);
  # NOTE: Use pkgs.lib.composeManyExtensions [ a b c ... ] if/when we
  # have more overlays
in
foundryvtt-rest-api-relay
