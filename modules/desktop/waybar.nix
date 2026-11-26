{ config, pkgs, ... }: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 28;
      margin = "6 10 0 10";
      spacing = 6;

      modules-left = [ "custom/focus" "hyprland/workspaces" "custom/special" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "backlight" "pulseaudio" "network" "custom/dnd" "custom/battery" "tray" ];

      "custom/focus" = {
        exec = "hyprctl -j monitors 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg out \"$WAYBAR_OUTPUT_NAME\" 'first(.[] | select(.name == $out) | (if .focused then \"●\" else \"○\" end)) // \"○\"' 2>/dev/null";
        signal = 8;
        tooltip = false;
      };

      "custom/special" = {
        exec = "hyprctl -j monitors 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg out \"$WAYBAR_OUTPUT_NAME\" 'first(.[] | select(.name == $out) | ((.specialWorkspace.name // \"\") != \"\")) // false | if . then \"S\" else \"\" end' 2>/dev/null";
        signal = 9;
        tooltip = false;
      };

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

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        format-icons = [ "󰃞" "󰃟" "󰃠" ];
        scroll-step = 5.0;
        min-brightness = 1.0;
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

      "custom/dnd" = {
        exec = "${config.home.profileDirectory}/bin/waybar-dnd status";
        return-type = "json";
        signal = 11;
        on-click = "${config.home.profileDirectory}/bin/waybar-dnd toggle";
      };

      "custom/battery" = {
        exec = "${config.home.profileDirectory}/bin/waybar-battery";
        return-type = "json";
        interval = 30;
        signal = 10;
        on-click = "${config.home.profileDirectory}/bin/waybar-battery toggle";
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
        padding: 0 4px 0 0;
      }

      #custom-focus {
        padding: 0 0 0 8px;
        color: @accent;
      }

      #workspaces button,
      #custom-special {
        min-width: 0;
        min-height: 0;
        padding: 0 9px;
        margin: 5px 2px;
        border-radius: 8px;
      }

      #workspaces button {
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

      #workspaces button.visible.hosting-monitor,
      #custom-special {
        color: @crust;
        background: @accent;
      }

      #custom-special {
        margin-left: -8px;
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

      #backlight {
        padding: 0 10px;
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

      #custom-dnd {
        padding: 0 10px;
      }

      #custom-dnd.on {
        color: @overlay;
      }

      #custom-dnd.off {
        color: @yellow;
      }

      #custom-battery {
        padding: 0 10px;
        color: @green;
      }

      #custom-battery.eco {
        color: @accent;
      }

      #custom-battery.warning {
        color: @yellow;
      }

      #custom-battery.critical {
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
