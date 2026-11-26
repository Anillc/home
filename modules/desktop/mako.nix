{ config, pkgs, ... }: {
  home.packages = [
    pkgs.libnotify
    (pkgs.writeShellScriptBin "waybar-dnd" ''
      makoctl="${pkgs.mako}/bin/makoctl"

      case "''${1:-status}" in
        toggle)
          if "$makoctl" mode 2>/dev/null | grep -qx do-not-disturb; then
            "$makoctl" mode -r do-not-disturb
          else
            "$makoctl" mode -a do-not-disturb
          fi
          pkill -RTMIN+11 waybar >/dev/null 2>&1 || true
          ;;
        *)
          if "$makoctl" mode 2>/dev/null | grep -qx do-not-disturb; then
            echo '{"text":"󰂛","class":"on","tooltip":"Do not disturb: on"}'
          else
            echo '{"text":"󰂚","class":"off","tooltip":"Do not disturb: off"}'
          fi
          ;;
      esac
    '')
  ];

  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 11";
      "background-color" = "#141a21";
      "text-color" = "#e8f4f5";
      "border-color" = "#7cb6c6";
      "progress-color" = "over #1f2733";
      "border-size" = 2;
      "border-radius" = 10;
      "icon-border-radius" = 8;
      padding = 10;
      margin = 8;
      width = 360;
      "default-timeout" = 5000;
      "max-visible" = 5;
      anchor = "top-right";
      layer = "overlay";
      icons = 1;
      markup = 1;
      format = "<b>%s</b>\\n%b";

      "mode=do-not-disturb" = {
        invisible = 1;
      };
    };
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "mako notification daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
