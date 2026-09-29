{ pkgs, ... }: {
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
