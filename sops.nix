{ config, pkgs, lib, ... }: let
  cfg = config.sops;
  yaml = (pkgs.formats.yaml {}).generate;
in {
  options.sops = {
    tiers = lib.mkOption {
      type = with lib.types; listOf (lib.types.submodule {
        options.pgp = lib.mkOption {
          type = with lib.types; listOf str;
          description = "OpenPGP recipients belonging to this tier";
          default = [];
        };
        options.age = lib.mkOption {
          type = with lib.types; listOf str;
          description = "age recipients belonging to this tier";
          default = [];
        };
      });
      description = "Recipient tiers, most trusted first";
    };
    result = lib.mkOption {
      type = lib.types.path;
      description = "result";
    };
  };

  config.sops = let
    recipient = i: {
      pgp = lib.concatMap (t: t.pgp) (lib.take (i + 1) cfg.tiers);
      age = lib.concatMap (t: t.age) (lib.take (i + 1) cfg.tiers);
    };
    rule = i: _: {
      path_regex = "secrets\\.tier${toString (i + 1)}\\.ya?ml$";
      key_groups = [ (recipient i) ];
    };
  in {
    tiers = [
      { pgp = [ "FCCC 1B0B DF14 FEE4 B66C  3A40 CA5B 1409 FBA7 BF66" ]; }              # 1 owner
      { age = [ "age1p9vcj2y2q59reuswpwjdqj8j3gz5yhz77qm9qeua4f5cc3xe8gqqf698t8" ]; }  # 2 desktop
      { age = [                                                                        # 3 trusted servers
        "age14qre8mr77uwwpzsk8na65ex92ulfewus37prer4yl62pjsdq7f6srrxpmu" # cola
        "age1z0tt5kr6maz5wv35pc73w7h5wrt0hpl06c7alskj6yuvttfrz9vqt75fzv" # hk
        "age1t6wjdm624k6fqcdy8m5ayj3ff6s8dpylqq24q78alwrvrrjq0vesxp8906" # home
        "age1380glkudxufzscly9e5ne68uns9dge39vns4ckanjhrxdfd979kq8wkcdn" # trunc
      ]; }
      { pgp = [ "EBD0 58E3 26C8 A442 F24E  14AD 5F42 E8EC FF1C C9D4!" ]; }             # 4 untrusted servers
    ];
    result = yaml ".sops.yaml" {
      creation_rules = lib.lists.imap0 rule cfg.tiers;
    };
  };
}
