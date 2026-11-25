{
  programs.ghostty = {
    enable = true;
    settings = {
      term = "xterm-256color";
      background-opacity = 0.85;
      background = "#141a21";
      foreground = "#e8f4f5";
      cursor-color = "#7cb6c6";
      keybind = [
        "ctrl+t=new_tab"
        "f11=toggle_maximize"
        "ctrl+shift+j=unbind"
        "ctrl+shift+n=unbind"
        "ctrl+shift+enter=unbind"
      ];
    };
  };
}
