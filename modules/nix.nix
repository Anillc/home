{ inputs, lib, pkgs, ... }: {
  nix = {
    package = pkgs.nix;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.p.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
      # substituters = lib.mkBefore [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
    };
  };
  programs.nix-index-database.comma.enable = true;
}
