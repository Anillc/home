{
  inputs.deploy.url = "github:serokell/deploy-rs";
  inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  inputs.nvf.url = "github:NotAShelf/nvf";
  inputs.cryonet.url = "github:kagari-org/cryonet";
  outputs = inputs@{
    self, nixpkgs, flake-parts, sops-nix, home-manager, deploy, nix-index-database, nvf, ...
  }: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ ./sops.nix ];
    debug = true;
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    perSystem = { config, pkgs, system, ... }: {
      devShells.default = pkgs.mkShell {
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
      |> map (file: let
        splited = nixpkgs.lib.splitString "_" (nixpkgs.lib.removeSuffix ".nix" file);
        name = builtins.head splited;
        system = if builtins.length splited > 1 then nixpkgs.lib.concatStringsSep "_" (builtins.tail splited) else "x86_64-linux";
      in {
        inherit name;
        value = home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = {
            inherit inputs;
            fetch = pkgs.callPackage ./fetch/_sources/generated.nix {};
          };
          modules = [
            ./profiles/${file}
            self.homeModules.secrets
            sops-nix.homeManagerModules.sops
            nix-index-database.homeModules.default
            nvf.homeManagerModules.default
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
