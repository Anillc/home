{ config, pkgs, lib, inputs, ... }:
let
  cryonet = inputs.cryonet.packages.${pkgs.stdenv.hostPlatform.system}.default;
  cryonet-ns-enter = pkgs.writeShellApplication {
    name = "cryonet-ns-enter";
    runtimeInputs = with pkgs; [ coreutils util-linux ];
    text = ''
      set -euo pipefail

      pidfile=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/cryonet-ns.pid
      if [ ! -r "$pidfile" ]; then
        echo "cryonet-ns-enter: $pidfile not found"
        exit 1
      fi

      pid=$(cat "$pidfile")
      if [ ! -e "/proc/$pid/ns/net" ]; then
        echo "cryonet-ns-enter: pid $pid is gone"
        exit 1
      fi

      uid=$(id -u)
      gid=$(id -g)
      if [ "''${1:-}" = "--root" ] || [ "''${1:-}" = "-r" ]; then
        uid=0
        gid=0
        shift
      fi
      [ $# -gt 0 ] || set -- "$SHELL"

      exec nsenter -U -n -t "$pid" -S "$uid" -G "$gid" --keep-caps -- "$@"
    '';
  };
in {
  home.packages = [ cryonet cryonet-ns-enter ];
  sops.secrets.cryonet-env.sopsFile = ./secrets.yaml;

  systemd.user.services.cryonet-netns = {
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      ExecStart = pkgs.writeShellScript "cryonet-netns" ''
        set -euo pipefail
        export PATH=$PATH:${lib.makeBinPath (with pkgs; [ coreutils util-linux gawk slirp4netns iproute2 ])}

        subuid=$(awk -F: -v u="$(id -un)" '$1 == u { print $2; exit }' /etc/subuid)
        subgid=$(awk -F: -v u="$(id -un)" '$1 == u { print $2; exit }' /etc/subgid)

        if [ -z "$subuid" ] || [ -z "$subgid" ]; then
          echo "cryonet-netns: no subuid/subgid"
          exit 1
        fi

        pidfile=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/cryonet-ns.pid

        unshare -cn \
          --map-users="0:$subuid:1" \
          --map-groups="0:$subgid:1" \
          -S 0 -G 0 \
          -- sleep infinity &
        ns=$!
        while [ "$(readlink /proc/$ns/ns/net)" == "$(readlink /proc/self/ns/net)" ]; do
          sleep 0.5
        done

        slirp4netns --configure --mtu=65520 "$ns" tap0 &
        slirp=$!
        while ! nsenter -t "$ns" -U -n -S "$(id -u)" -G "$(id -g)" -- ip route | grep -q '^default'; do
          sleep 0.5
        done

        trap 'rm -f "$pidfile"; kill $ns $slirp || true' INT TERM EXIT
        echo "$ns" > "$pidfile"

        wait -n "$ns" "$slirp"
      '';
    };
  };

  systemd.user.services.cryonet = {
    Unit = {
      BindsTo = [ "cryonet-netns.service" ];
      After = [ "cryonet-netns.service" "sops-nix.service" ];
    };
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      Environment = [
        "TAP_MODE=true"
        "SERVERS=wss://cola.s.kagari.org:16809,wss://hk.s.kagari.org:16809"
        "CANDIDATE_FILTER_PREFIXES=10.0.0.0/8"
      ];
      EnvironmentFile = config.sops.secrets.cryonet-env.path;
      ExecStart = "${cryonet-ns-enter}/bin/cryonet-ns-enter ${cryonet}/bin/cryonet 252";
      RuntimeDirectory = "cryonet";
    };
  };
}
