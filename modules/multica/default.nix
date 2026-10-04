{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [ multica-cli ];
  sops.secrets.multica-token.sopsFile = ./secrets.yaml;
  systemd.user.services.multica = {
    Unit.After = [ "sops-nix.service" ];
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      Path = lib.makeBinPath [ pkgs.multica-cli pkgs.coreutils config.programs.codex.package ];
      ExecStart = "${pkgs.writeScript "multica-daemon" ''
        #!${pkgs.runtimeShell}
        set -e
        multica config set server_url https://multica.ani.llc
        multica config set app_url https://multica.ani.llc
        cat ${config.sops.secrets.multica-token.path} | xargs multica login --token
        exec multica daemon start --foreground
      ''}";
    };
  };
}
