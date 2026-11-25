{ ... }: {
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 28;
      margin = "6 10 0 10";
      spacing = 6;

      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "tray" ];

      "hyprland/workspaces" = {
        format = "{id}";
        on-click = "activate";
        all-outputs = true;
      };

      "hyprland/window" = {
        format = "{}";
        max-length = 40;
        separate-outputs = true;
      };

      clock = {
        format = "{:%H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          format = {
            today = "<span color='#cba6f7'><b>{}</b></span>";
          };
        };
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "{icon} 0%";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
        scroll-step = 5;
      };

      network = {
        format-wifi = "󰤨 {essid}";
        format-ethernet = "󰈀 {ifname}";
        format-disconnected = "󰤭 offline";
        tooltip-format = "{ifname}  {ipaddr}";
      };

      battery = {
        format = "{icon} {capacity}%";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        states = {
          warning = 30;
          critical = 15;
        };
        tooltip-format = "{timeTo}";
      };

      tray.spacing = 10;
    };

    style = ''
      @define-color crust     #141a21;
      @define-color mantle    #0f1419;
      @define-color base      rgba(20, 26, 33, 0.72);
      @define-color surface   #1f2733;
      @define-color overlay   #6b7a8c;
      @define-color text      #e8f4f5;
      @define-color subtext   #a7bcc5;
      @define-color accent    #7cb6c6;
      @define-color teal      #8fb8c4;
      @define-color sapphire  #66a4b4;
      @define-color green     #a8c6a0;
      @define-color yellow    #d8cfa0;
      @define-color red       #d08c8c;

      * {
        font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", monospace;
        font-size: 13px;
        font-weight: 600;
        min-height: 0;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background: @base;
        color: @text;
        border-radius: 12px;
      }

      #workspaces {
        padding: 0 4px;
      }

      #workspaces button {
        padding: 0 9px;
        margin: 5px 2px;
        border-radius: 8px;
        border: none;
        outline: none;
        box-shadow: none;
        background-image: none;
        color: @overlay;
        background: transparent;
        transition: background-color 0.25s ease, color 0.25s ease;
      }

      #workspaces button:hover {
        border: none;
        outline: none;
        box-shadow: none;
        color: @text;
        background: @surface;
      }

      #workspaces button.active {
        color: @crust;
        background: @accent;
      }

      #workspaces button.urgent {
        color: @crust;
        background: @red;
      }

      #window {
        padding: 0 10px;
        color: @subtext;
        font-weight: 500;
      }

      window#waybar.empty #window {
        background: transparent;
      }

      #clock {
        padding: 0 12px;
        color: @yellow;
      }

      #pulseaudio {
        padding: 0 10px;
        color: @sapphire;
      }

      #pulseaudio.muted {
        color: @red;
      }

      #network {
        padding: 0 10px;
        color: @teal;
      }

      #network.disconnected {
        color: @red;
      }

      #battery {
        padding: 0 10px;
        color: @green;
      }

      #battery.warning {
        color: @yellow;
      }

      #battery.critical {
        color: @red;
        animation: blink 1.2s steps(2) infinite;
      }

      #tray {
        padding: 0 8px;
      }

      tooltip {
        background: @mantle;
        border: 1px solid @surface;
        border-radius: 8px;
      }

      tooltip label {
        color: @text;
      }

      @keyframes blink {
        to { color: @surface; }
      }
    '';
  };
}
