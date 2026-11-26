{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "waybar-battery" ''
      state_file="''${XDG_RUNTIME_DIR:-/tmp}/power-save.state"

      set_effects() {
        hyprctl eval "hl.config({ animations = { enabled = $1 }, decoration = { shadow = { enabled = $1 }, blur = { enabled = $1 } } })" >/dev/null 2>&1 || true
      }

      set_profile() {
        command -v powerprofilesctl >/dev/null 2>&1 || return 0
        powerprofilesctl set "$1" >/dev/null 2>&1 || true
      }

      current() { cat "$state_file" 2>/dev/null || echo normal; }

      toggle() {
        if [ "$(current)" = eco ]; then
          set_effects true
          set_profile balanced
          echo normal > "$state_file"
        else
          set_effects false
          set_profile power-saver
          echo eco > "$state_file"
        fi

        pkill -RTMIN+10 waybar >/dev/null 2>&1 || true
      }

      status() {
        mode=$(current)

        battery=""
        for supply in /sys/class/power_supply/*; do
          [ "$(cat "$supply/type" 2>/dev/null)" = "Battery" ] || continue
          [ -r "$supply/capacity" ] || continue
          battery="$supply"
          break
        done

        if [ -z "$battery" ]; then
          echo '{"text":"","class":"","tooltip":"no battery"}'
          exit 0
        fi

        capacity=$(cat "$battery/capacity")
        status=$(cat "$battery/status")

        icons=("󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
        index=$((capacity / 10))
        [ "$index" -gt 9 ] && index=9
        icon="''${icons[$index]}"

        time=""
        power_now=$(cat "$battery/power_now" 2>/dev/null || echo 0)
        energy_now=$(cat "$battery/energy_now" 2>/dev/null || echo 0)
        energy_full=$(cat "$battery/energy_full" 2>/dev/null || echo 0)
        if [ "$power_now" -gt 0 ] 2>/dev/null; then
          case "$status" in
            Discharging) minutes=$((energy_now * 60 / power_now)) ;;
            Charging) minutes=$(((energy_full - energy_now) * 60 / power_now)) ;;
            *) minutes=0 ;;
          esac
          if [ "$minutes" -gt 0 ]; then
            time="$((minutes / 60))h $((minutes % 60))m"
          fi
        fi

        class=""
        case "$status" in
          Charging | Full) class=charging ;;
        esac
        if [ "$capacity" -le 15 ]; then
          class=critical
        elif [ "$capacity" -le 30 ]; then
          class=warning
        elif [ -z "$class" ] && [ "$mode" = eco ]; then
          class=eco
        fi

        tooltip="$capacity% ($status)"
        [ -n "$time" ] && tooltip="$tooltip\n$time"
        if [ "$mode" = eco ]; then
          tooltip="$tooltip\nPower save: on"
        else
          tooltip="$tooltip\nPower save: off"
        fi

        printf '{"text":"%s %s%%","class":"%s","tooltip":"%s"}\n' "$icon" "$capacity" "$class" "$tooltip"
      }

      case "''${1:-status}" in
        toggle) toggle ;;
        *) status ;;
      esac
    '')
  ];
}
