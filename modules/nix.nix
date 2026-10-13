{ inputs, pkgs, ... }: {
  nix = {
    package = pkgs.nix;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.p.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
      extra-substituters = [ "https://sns.ani.llc" ];
      extra-trusted-public-keys = [ "substituter-api-1:aJyds2K19yTBaVA2SyQIDqADwkhweR9w1Yib4Eqv4eY=" ];
    };
  };
  programs.nix-index-database.comma.enable = true;
}
