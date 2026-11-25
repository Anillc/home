{ inputs', ... }: {
  xdg.configFile."hypr-rdp/config.toml".text = ''
    bind = "0.0.0.0:3389"
    auth_mode = "pam"
    fps = 60
    bitrate = 20000000

    on_session_end = "hyprctl eval 'hl.dispatch(hl.dsp.exec_cmd(\"pidof hyprlock || hyprlock\"))' || true"
  '';

  systemd.user.services.hypr-rdp = {
    Unit = {
      Description = "Native RDP server for Hyprland";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      ExecStart = "${inputs'.hypr-rdp.packages.hypr-rdp}/bin/hypr-rdp";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
