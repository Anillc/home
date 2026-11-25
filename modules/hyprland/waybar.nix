{
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 28;

      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "battery"
      ];

      "hyprland/workspaces" = {
        format = "{id}";
        all-outputs = true;
      };

      clock.format = "{:%H:%M}";

      pulseaudio = {
        format = "{volume}%";
        format-muted = "muted";
      };

      battery.format = "{capacity}%";
    };

    style = ''
      * { font-size: 12px; border: none; border-radius: 0; }
      window#waybar { background: #1e1e2e; color: #cdd6f4; }
      #workspaces button { padding: 0 6px; color: #a6adc8; }
      #workspaces button.active { color: #1e1e2e; background: #89b4fa; }
      #clock, #pulseaudio, #battery { padding: 0 8px; }
    '';
  };
}
