{
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
}
