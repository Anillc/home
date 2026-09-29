{ pkgs, fetch, ... }: {
  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."Host *".User = "root";
  };

  programs.ghostty = {
    enable = true;
    settings = {
      term = "xterm-256color";
      keybind = [
        "ctrl+t=new_tab"
        "f11=toggle_maximize"
      ];
    };
  };
  programs.vivaldi = {
    enable = true;
    package = pkgs.vivaldi.override {
      inherit (pkgs) vivaldi-ffmpeg-codecs widevine-cdm;
      proprietaryCodecs = true;
      enableWidevine = true;
    };
  };
  xdg.mimeApps = let
    vivaldi = {
      "text/html" = "vivaldi-stable.desktop";
      "x-scheme-handler/http" = "vivaldi-stable.desktop";
      "x-scheme-handler/https" = "vivaldi-stable.desktop";
      "application/pdf" = "vivaldi-stable.desktop";
      "application/xhtml+xml" = "vivaldi-stable.desktop";
    };
  in {
    enable = true;
    associations.added = vivaldi;
    defaultApplications = vivaldi;
  };

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
