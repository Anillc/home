{ config, pkgs, lib, ... }: {
  programs.atuin = {
    enable = true;
    daemon.enable = true;
    settings = {
      sync_address = "https://atuin.ani.llc";
      enter_accept = true;
    };
  };
  sops.secrets.atuin-login.sopsFile = ./secrets.yaml;
  systemd.user.services.atuin-login = {
    Unit.After = [ "sops-nix.service" ];
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeScript "atuin-login" ''
        #!${pkgs.runtimeShell}
        export PATH=$PATH:${lib.makeBinPath (with pkgs; [ coreutils bash atuin ])}
        bash ${config.sops.secrets.atuin-login.path} || true
      ''}";
    };
  };
}
