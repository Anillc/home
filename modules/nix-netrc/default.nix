{ config, ... }: {
  sops.secrets.nix-netrc.sopsFile = ./secrets.yaml;
  nix.settings.netrc-file = config.sops.secrets.nix-netrc.path;
}
