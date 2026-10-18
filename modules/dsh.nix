{ config, pkgs, ... }: {
  systemd.user.services.dsh = {
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${pkgs.writeShellScript "dsh" ''
        cd ${config.home.homeDirectory}/.dsh.nix || exit 0
        [ -f flake.nix ] || exit 0
        exec ${pkgs.nix}/bin/nix develop -c dsh --no-open
      ''}";
    };
  };

  home.packages = [
    (pkgs.writeShellApplication {
      name = "dso";
      runtimeInputs = [ pkgs.curl ];
      text = ''
        curl http://127.0.0.1:3080/api/open
      '';
    })
    (pkgs.writeShellApplication {
      name = "dsl";
      runtimeInputs = [ pkgs.curl ];
      text = ''
        curl http://127.0.0.1:3080/api/launch -d "$PWD"
      '';
    })
  ];
}
