{ config, ... }: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          monitor = "";
          path = "${config.home.homeDirectory}/Pictures/wallpaper.png";
          blur_passes = 2;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "240, 48";
          rounding = 10;
          outline_thickness = 1;
          outer_color = "rgba(7cb6c6ff) rgba(b5d9d8ff) 45deg";
          inner_color = "rgba(20, 26, 33, 0.85)";
          font_color = "rgb(232, 244, 245)";
          font_family = "JetBrainsMono Nerd Font";
          placeholder_text = "<span foreground='##6b7a8c'>Password</span>";
          fail_text = "<span foreground='##d08c8c'>Wrong password</span>";
          dots_size = 0.2;
          dots_spacing = 0.25;
          position = "0, -80";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 72;
          color = "rgb(232, 244, 245)";
          position = "0, 60";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:60000] date +'%A, %d %B'";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 18;
          color = "rgb(107, 122, 140)";
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
