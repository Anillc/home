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
}
