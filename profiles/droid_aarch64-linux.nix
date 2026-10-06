{ config, lib, ... }:
let
  modules = [
    ../modules/core.nix
    ../modules/nix.nix
    ../modules/gpg.nix
    ../modules/git.nix
    ../modules/gh.nix
    ../modules/shell.nix
    ../modules/nvf.nix
    ../modules/atuin
    ../modules/ssh.nix
    ../modules/codex.nix
  ];
in {
  home.username = "nix-on-droid";
  home.homeDirectory = "/data/data/com.termux.nix/files/home";

  imports = modules;
  secrets.modules = modules;
  secrets.keys.age = [
    "age1ass6ggdl5vd76gl4tekx334ptcstkz50rdsjkegtpfe4h7mrncfsn9kayx" # droid
  ];

  home.activation.sops-nix-non-systemd = lib.mkIf (config.sops.secrets != { }) (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run env ${lib.concatStringsSep " " (
        lib.mapAttrsToList (name: value: "${name}=${lib.escapeShellArg value}") config.sops.environment
      )} ${lib.concatStringsSep " " config.systemd.user.services.sops-nix.Service.ExecStart}
    ''
  );

  programs.atuin.daemon.enable = false;
}
