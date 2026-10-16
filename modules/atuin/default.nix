{ config, pkgs, lib, ... }: {
  programs.atuin = {
    enable = true;
    daemon.enable = lib.mkDefault true;
    settings = {
      sync_address = "https://atuin.ani.llc";
      enter_accept = true;
      filter_mode = "session-preload";
      keymap_mode = "auto";
      keymap = lib.genAttrs [ "emacs" "vim-insert" "vim-normal" ] (_: {
        left = [
          { when = "cursor-at-start"; action = "return-selection"; }
          { action = "cursor-left"; }
        ];
        ctrl-left = [
          { when = "cursor-at-start"; action = "return-selection"; }
          { action = "cursor-word-left"; }
        ];
        ctrl-right = [
          { when = "cursor-at-end"; action = "return-selection"; }
          { action = "cursor-word-right"; }
        ];
      });
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
