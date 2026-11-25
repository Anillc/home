{ pkgs, ... }: {
  imports = [
    ./waybar.nix
    ./fuzzel.nix
    ./hyprlock.nix
    ./hypridle.nix
  ];

  programs.bash.profileExtra = ''
    if [ "$(tty)" = /dev/tty1 ] && uwsm check may-start; then
      exec uwsm start hyprland.desktop
    fi
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    # use uwsm
    systemd.enable = false;

    settings = {
      config = {
        general = {
          layout = "lua:tape2d";
          gaps_in = 5;
          gaps_out = 0;
          border_size = 1;
          resize_on_border = true;
          col = {
            active_border = { colors = [ "rgba(7cb6c6ff)" "rgba(b5d9d8ff)" ]; angle = 45; };
            inactive_border = "rgba(2a3442aa)";
          };
        };

        decoration = {
          rounding = 10;
          active_opacity = 1.0;
          inactive_opacity = 0.92;
          dim_inactive = true;
          dim_strength = 0.12;
          shadow = { enabled = true; range = 8; render_power = 3; color = "rgba(0f1419aa)"; };
          blur = {
            enabled = true;
            size = 5;
            passes = 2;
            new_optimizations = true;
            xray = true;
            ignore_opacity = true;
            popups = true;
          };
        };

        cursor.sync_gsettings_theme = false;

        misc = {
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;
          font_family = "JetBrainsMono Nerd Font";
        };
      };

      monitor = [
        {
          output = "DSI-1";
          mode = "1600x2560@60.147";
          position = "0x1440";
          scale = 2;
          transform = 3;
        }
        {
          output = "DP-1";
          mode = "2560x1440@59.968";
          position = "0x0";
          scale = 1;
        }
      ];

      layer_rule = [
        {
          name = "waybar-blur";
          match.namespace = "waybar";
          blur = true;
        }
        {
          name = "fuzzel-blur";
          match.namespace = "fuzzel";
          blur = true;
        }
      ];
    };

    extraLuaFiles."tape2d" = ./tape2d.lua;

    extraConfig = ''
      local mod = "ALT"

      hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
      hl.env("XCURSOR_SIZE", "24")

      hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "default", style = "slidevert" })
      for _, leaf in ipairs({ "global", "windows", "windowsIn", "windowsOut", "fade", "layers" }) do
        hl.animation({ leaf = leaf, enabled = true, speed = 2, bezier = "default" })
      end

      hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("ghostty"))
      hl.bind(mod .. " + D", hl.dsp.exec_cmd("fuzzel"))
      hl.bind(mod .. " + Q", hl.dsp.window.close())
      hl.bind(mod .. " + F", hl.dsp.layout("zoom"))
      hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
      hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))

      hl.bind(mod .. " + O", function() tape2d_focus_monitor(-1) end)
      hl.bind(mod .. " + P", function() tape2d_focus_monitor(1) end)
      hl.bind(mod .. " + H", hl.dsp.layout("focusleft"))
      hl.bind(mod .. " + L", hl.dsp.layout("focusright"))
      hl.bind(mod .. " + K", hl.dsp.layout("focusup"))
      hl.bind(mod .. " + J", hl.dsp.layout("focusdown"))
      hl.bind(mod .. " + SHIFT + H", hl.dsp.layout("moveleft"))
      hl.bind(mod .. " + SHIFT + L", hl.dsp.layout("moveright"))
      hl.bind(mod .. " + SHIFT + J", hl.dsp.layout("movedown"))
      hl.bind(mod .. " + SHIFT + K", hl.dsp.layout("moveup"))

      hl.bind(mod .. " + comma", hl.dsp.layout("shrink"))
      hl.bind(mod .. " + period", hl.dsp.layout("grow"))
      hl.bind(mod .. " + SHIFT + comma", hl.dsp.layout("shorter"))
      hl.bind(mod .. " + SHIFT + period", hl.dsp.layout("taller"))

      for i = 1, 10 do
        local key = i % 10
        hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i, on_current_monitor = true }))
        hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
      end

      hl.on("hyprland.start", function()
        hl.exec_cmd("uwsm finalize")
        hl.exec_cmd([[sh -c 'exec swaybg -i "$HOME/Pictures/wallpaper.png" -m fill']])
        hl.exec_cmd("waybar")
      end)
    '';
  };

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
  };

  home.packages = [ pkgs.swaybg ];
}
