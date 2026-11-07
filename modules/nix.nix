{ inputs, pkgs, ... }: {
  nix = {
    package = pkgs.nix;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.p.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
      extra-substituters = [
        "https://sns.ani.llc"
        "https://cache.saumon.network/proxmox-nixos"
      ];
      extra-trusted-public-keys = [
        "substituter-api-1:aJyds2K19yTBaVA2SyQIDqADwkhweR9w1Yib4Eqv4eY="
        "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM="
      ];
    };
  };
  programs.nix-index-database.comma.enable = true;
}
