{ config, pkgs, lib, ... }: let
  cfg = config.sops;
  toYAML = lib.generators.toYAML {};
  rule = lib.types.submodule ({ config, ... }: {
    options.path = lib.mkOption {
      type = lib.types.str;
      description = "path_regex";
    };
    options.pgp = lib.mkOption {
      type = with lib.types; listOf str;
      description = "pgp";
      default = [];
    };
    options.age = lib.mkOption {
      type = with lib.types; listOf str;
      description = "age";
      default = [];
    };
    options.result = lib.mkOption {
      type = with lib.types; anything;
      description = "result";
    };
    config.result = {
      path_regex = config.path;
      key_groups = [ {
        pgp = config.pgp;
        age = config.age;
      } ];
    };
  });
in {
  options.sops = {
    rules = lib.mkOption {
      type = with lib.types; attrsOf rule;
      description = "creation_rules";
    };
    result = lib.mkOption {
      type = with lib.types; path;
      description = "result";
    };
  };
  config.sops = let
    final = [ "FCCC 1B0B DF14 FEE4 B66C  3A40 CA5B 1409 FBA7 BF66" ];
    trusted_desktops = [ "age1p9vcj2y2q59reuswpwjdqj8j3gz5yhz77qm9qeua4f5cc3xe8gqqf698t8" ];
    trusted_servers = [
      "age1xzeru626ugw2znueqy034nme56fvf29pq2q3zq4609ajdn2hvdjqnm3vtu" # cola
      "age1efsd4ax034a5kwa092tg5puv4dg0hpxyt45dlytn5c5g6dwml9ysnhhsfa" # hk
      "age1vzu6hgq87xqz3k352x0x4mz6n63p32xgwt0ek7cha6sfjusxacgqydx8rr" # home
      "age1p9906crzyha38je9a9zx6zpzlqrff9kpr44euwxlf8gg8n8tva8s5x0ujk" # trunc
    ];
    untrusted_servers = [ "EBD0 58E3 26C8 A442 F24E  14AD 5F42 E8EC FF1C C9D4!" ];
  in {
    rules.common = {
      path = ".*common.*";
      pgp = final ++ untrusted_servers;
      age = trusted_desktops ++ trusted_servers;
    };
    rules.trusted = {
      path = ".*trusted.*";
      pgp = final;
      age = trusted_desktops ++ trusted_servers;
    };
    rules.desktop = {
      path = ".*desktop.*";
      pgp = final;
      age = trusted_desktops;
    };
    rules.server = {
      path = ".*server.*";
      pgp = final ++ untrusted_servers;
      age = trusted_servers;
    };
    rules.trusted-server = {
      path = ".*trusted-server.*";
      pgp = final;
      age = trusted_servers;
    };
    result = pkgs.writeText ".sops.yaml" (toYAML {
      creation_rules = lib.attrValues cfg.rules;
    });
  };
}
