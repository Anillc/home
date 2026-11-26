{ inputs', ... }:
let
  hypr-rdp = inputs'.hypr-rdp.packages.hypr-rdp.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/capture/mod.rs \
        --replace-fail "inner.update_tx = tx.clone();" \
        "inner.update_tx = tx.clone();
        let _ = tx.try_send(DisplayUpdate::HidePointer);
        let _ = tx.try_send(DisplayUpdate::RGBAPointer(ironrdp_server::RGBAPointer {
          cache_index: 0,
          width: 1,
          height: 1,
          hot_x: 0,
          hot_y: 0,
          data: vec![0, 0, 0, 0],
        }));"
    '';
  });
in {
  xdg.configFile."hypr-rdp/config.toml".text = ''
    bind = "0.0.0.0:3389"
    auth_mode = "pam"
    fps = 60
    bitrate = 15000000
    capture_mode = "ext"
    max_frames_in_flight = 1

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
      ExecStart = "${hypr-rdp}/bin/hypr-rdp";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
