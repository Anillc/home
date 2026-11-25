{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        prompt = "› ";
        namespace = "fuzzel";
        lines = 10;
        width = 45;
        horizontal-pad = 14;
        vertical-pad = 12;
        inner-pad = 8;
        anchor = "center";
        layer = "overlay";
        terminal = "ghostty -e";
      };
      colors = {
        background = "141a21e6";
        text = "e8f4f5ff";
        prompt = "7cb6c6ff";
        placeholder = "6b7a8cff";
        input = "e8f4f5ff";
        match = "7cb6c6ff";
        selection = "2a3442ff";
        selection-text = "e8f4f5ff";
        selection-match = "7cb6c6ff";
        counter = "6b7a8cff";
        border = "2a3442ff";
      };
      border = {
        width = 1;
        radius = 10;
      };
      "key-bindings" = {
        delete-line-forward = "none";
        delete-line-backward = "none";
        delete-next = "none";
        prev = "Up Control+p Control+k";
        next = "Down Control+n Control+j";
        prev-page = "Page_Up KP_Page_Up Control+u";
        next-page = "Page_Down KP_Page_Down Control+d";
      };
      dmenu.exit-immediately-if-empty = "yes";
    };
  };
}
