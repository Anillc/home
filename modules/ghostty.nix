{
  programs.ghostty = {
    enable = true;
    settings = {
      term = "xterm-256color";
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
