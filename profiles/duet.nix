let
  modules = [
    ../modules/core.nix
    ../modules/nix.nix
    ../modules/gpg.nix
    ../modules/git.nix
    ../modules/shell.nix
    ../modules/nvf.nix
    ../modules/atuin
    ../modules/gpg-agent.nix
    ../modules/ssh.nix
    ../modules/codex.nix
    ../modules/ghostty.nix
    ../modules/vivaldi.nix
    ../modules/fcitx5.nix
  ];
in {
  imports = modules;
  secrets = {
    modules = [ ../modules/atuin ];
    keys.age = [
      "age1p9vcj2y2q59reuswpwjdqj8j3gz5yhz77qm9qeua4f5cc3xe8gqqf698t8" # duet
    ];
  };
}
