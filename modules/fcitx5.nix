{ pkgs, fetch, ... }: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = let
        rime-flypy = pkgs.callPackage ({ stdenv, fetchFromGitHub, librime, ... }: stdenv.mkDerivation {
          inherit (fetch.rime-flypy) pname version src;
          nativeBuildInputs = [ librime ];
          prePatch = "cp -r ${fetch.rime-prelude.src}/* .";
          makeFlags = [ "PREFIX=$(out)" ];
        }) {};
      in with pkgs; [
        (fcitx5-rime.override {
          rimeDataPkgs = [ rime-flypy ];
        })
      ];
      settings.addons.rime.globalSection.SwitchInputMethodBehavior = "Commit raw input";
      settings.inputMethod = {
        "GroupOrder"."0" = "Default";
        "Groups/0" = {
          "Name" = "Default";
          "Default Layout" = "us";
          "DefaultIM" = "rime";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "rime";
      };
    };
  };

  xdg.dataFile."fcitx5/rime/default.custom.yaml".source = (pkgs.formats.yaml { }).generate "default.custom.yaml" {
    patch = {
      "schema_list/+" = [
        { schema = "flypy"; }
        { schema = "flypydz"; }
      ];
      "ascii_composer/switch_key/Shift_L" = "commit_code";
      "ascii_composer/switch_key/Shift_R" = "commit_code";
    };
  };
}
