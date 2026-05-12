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
      "age14qre8mr77uwwpzsk8na65ex92ulfewus37prer4yl62pjsdq7f6srrxpmu" # cola
      "age1z0tt5kr6maz5wv35pc73w7h5wrt0hpl06c7alskj6yuvttfrz9vqt75fzv" # hk
      "age1t6wjdm624k6fqcdy8m5ayj3ff6s8dpylqq24q78alwrvrrjq0vesxp8906" # home
      "age1380glkudxufzscly9e5ne68uns9dge39vns4ckanjhrxdfd979kq8wkcdn" # trunc
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
      creation_rules = lib.attrValues cfg.rules |> map (x: x.result);
    });
  };
}
