{ config, pkgs, lib, ... }: {
  home.stateVersion = "25.11";
  home.username = lib.mkDefault "anillc";
  home.homeDirectory = lib.mkDefault "/home/anillc";
  sops.gnupg.home = "${config.home.homeDirectory}/.gnupg";
  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  systemd.user.services.sops-nix.Install.WantedBy = [ "default.target" ];

  nixpkgs.config.allowUnfree = true;
  xdg.enable = true;
  home.packages = with pkgs; [ gawk ];
}
