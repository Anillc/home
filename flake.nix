{
  inputs.home-manager.url = "github:Anillc/home-manager/systemd-user-root";
  inputs.deploy.url = "github:serokell/deploy-rs";
  outputs = inputs@{
    self, nixpkgs, flake-parts, sops-nix, home-manager, deploy,
  }: flake-parts.lib.mkFlake { inherit inputs; } {
    debug = true;
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    perSystem = { config, pkgs, system, ... }: {
      imports = [ ./sops.nix ];
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [];
        nativeBuildInputs = with pkgs; [
          sops nvfetcher
          home-manager.packages.${system}.default
          deploy.packages.${system}.default
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
        value = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          extraSpecialArgs.fetch = pkgs.callPackage ./fetch/_sources/generated.nix {};
          modules = [
            ./profiles/${name}
            sops-nix.homeManagerModules.sops
          ];
        };
      })
      |> builtins.listToAttrs;
    flake.deploy.nodes = self.homeConfigurations
      |> builtins.mapAttrs (_: value: let
        system = value.pkgs.stdenv.buildPlatform.system;
        path = deploy.lib.${system}.activate.home-manager value;
      in {
        profiles.home-manager = { inherit path; };
        hostname = ""; # we pass this via CLI
      });
  };
}
