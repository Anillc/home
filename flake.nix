{
  outputs = inputs@{
    self, nixpkgs, flake-parts, sops-nix, home-manager,
  }: flake-parts.lib.mkFlake { inherit inputs; } {
    debug = true;
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    perSystem = { config, pkgs, system, ... }: {
      imports = [ ./sops.nix ];
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [];
        nativeBuildInputs = with pkgs; [
          sops
          home-manager.packages.${system}.default
        ];
        shellHook = ''
          ln -sf ${config.sops.result} .sops.yaml
        '';
      };
    };
    flake.homeConfigurations = builtins.readDir ./profiles
      |> builtins.attrNames
      |> map (name: {
        name = builtins.elemAt (builtins.split "\\." name) 0;
        value = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          modules = [ (./profiles/${name}) ];
        };
      })
      |> builtins.listToAttrs;
  };
}
