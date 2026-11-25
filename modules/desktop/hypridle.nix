{ pkgs, ... }: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "pidof hyprlock || hyprlock";
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
      };
      listener = [
        {
          timeout = 120;
          on-timeout = "${pkgs.writeShellScript "hypridle-locked-suspend" ''
            pidof hyprlock >/dev/null || exit 0

            hyprctl dispatch 'hl.dsp.dpms({ action = "off" })' || true

            while pidof hyprlock >/dev/null; do
              on_ac=0

              for supply in /sys/class/power_supply/*; do
                [ "$(cat "$supply/type" 2>/dev/null)" = "Mains" ] || continue
                [ "$(cat "$supply/online" 2>/dev/null)" = "1" ] && on_ac=1
              done

              if [ "$on_ac" -eq 0 ]; then
                systemctl suspend-then-hibernate
                exit 0
              fi

              sleep 30
            done
          ''}";
          on-resume = "pkill -f hypridle-locked-suspend >/dev/null 2>&1 || true; hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
        }
      ];
    };
  };
}
