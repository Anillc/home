{ config, lib, ... }: let
  owner = "FCCC 1B0B DF14 FEE4 B66C  3A40 CA5B 1409 FBA7 BF66";

  recipientsByModule = config.flake.homeConfigurations
    |> lib.attrValues
    |> map (profile: lib.genAttrs (map toString profile.config.secrets.modules) (_: profile.config.secrets.keys))
    |> lib.zipAttrsWith (_: sets: {
      age = sets |> lib.concatMap (set: set.age) |> lib.unique;
      pgp = sets |> lib.concatMap (set: set.pgp) |> lib.unique;
    })
    |> lib.filterAttrs (module: _: builtins.pathExists (module + "/secrets.yaml"))
    |> lib.mapAttrs' (module: keys: lib.nameValuePair (lib.removePrefix "${toString ./.}/" module) keys);

  rules = recipientsByModule |> lib.mapAttrsToList (path: keys: {
    path_regex = "^${lib.escapeRegex path}/secrets\\.yaml$";
    key_groups = [ {
      inherit (keys) age;
      pgp = keys.pgp ++ [ owner ];
    } ];
  });

  fallback = {
    path_regex = "";
    key_groups = [ { age = []; pgp = [ owner ]; } ];
  };
in {
  flake.homeModules.secrets = {
    options.secrets = {
      keys.age = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = "age keys";
      };
      keys.pgp = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = "pgp keys";
      };
      modules = lib.mkOption {
        type = with lib.types; listOf path;
        default = [];
        description = "modules that may contain secrets";
      };
    };
  };
  perSystem = {
    options.sops.result = lib.mkOption {
      type = lib.types.path;
      description = "result";
    };
    config.sops.result = builtins.toFile ".sops.yaml" (lib.generators.toYAML {} {
      creation_rules = rules ++ [ fallback ];
    });
  };
}
