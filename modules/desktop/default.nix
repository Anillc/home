{ pkgs, ... }: {
  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
  programs.ghostty = {
    enable = true;
    settings.keybind = [
      "ctrl+t=new_tab"
      "f11=toggle_maximize"
    ];
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
}
