{ inputs, config, pkgs, lib, ... }: {
  imports = [ ./nixvim.nix ];

  home.stateVersion = "25.11";
  home.username = lib.mkDefault "anillc";
  home.homeDirectory = lib.mkDefault "/home/anillc";
  sops.gnupg.home = "${config.home.homeDirectory}/.gnupg";

  nixpkgs.config.allowUnfree = true;
  xdg.enable = true;

  # nix
  nix = {
    package = pkgs.nix;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.p.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
      substituters = lib.mkBefore [ "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store" ];
    };
  };
  programs.nix-index-database.comma.enable = true;

  # gpg
  programs.gpg = {
    enable = true;
    publicKeys = [ {
      # myself
      trust = 5;
      text = ''
        -----BEGIN PGP PUBLIC KEY BLOCK-----

        mDMEYlQbxxYJKwYBBAHaRw8BAQdAL3fAjgSzVFnz2uqLgjDeS6RbxjVQX8Yig7Rw
        2ayUyQO0FUFuaWxsYyA8dm9pZEBhbmlsLmxjPoiOBBMWCgA2FiEEYUEeT/4Qznsu
        FM12C+ioj0eyFFwFAmmm6vECGwMECwkIBwQVCgkIBRYCAwEAAh4BAheAAAoJEAvo
        qI9HshRci18A/R7jrg9xYA7Vfg2veqtBqTvJPEpT3Cf47pR0Sg3xTIWjAP4tOlb/
        98vznukMSrqiIULy3JBkD7q0x6Q7nlfVDRMKDbQSQW5pbGxjIDxpQGFuaWwubGM+
        iI4EExYKADYWIQRhQR5P/hDOey4UzXYL6KiPR7IUXAUCaabp9wIbAwQLCQgHBBUK
        CQgFFgIDAQACHgECF4AACgkQC+ioj0eyFFzUXAEA34vfTh61u1XAsyaxq7hVaYnv
        CfzmarLr5tz62wfByt8A/01Zoe2N0MNNvX+BuK4nfobmsP9TawizOs1sGGNH00QH
        uDgEYlQbxxIKKwYBBAGXVQEFAQEHQEnL7lC9znrT/5JAj+L8H+Fbp+cXfLA2egXe
        GCZQPsghAwEIB4h4BBgWCgAgFiEEYUEeT/4QznsuFM12C+ioj0eyFFwFAmJUG8cC
        GwwACgkQC+ioj0eyFFydTwD9HR3MQjvcLpwmpGcW85YVSJHWdZa2NyqV+wp3i5o9
        OdQA/2QY/hB8BJRkadJwQDg4Op2WgOR+puTjM3XWoCVp6qUGuDgEaafJihIKKwYB
        BAGXVQEFAQEHQNDct9vVHdluiwY+ZKsSMs+do8cqUKSN4A4nZ42c8ag6AwEIB4h+
        BBgWCgAmFiEEYUEeT/4QznsuFM12C+ioj0eyFFwFAmmnyYoCGwwFCQDtTgAACgkQ
        C+ioj0eyFFx8cgEA6APbyS+rJ/L5pcf0tqmZkdVrAAv/XH/1QxnVw1s1g00BAJ1Y
        Gm92ram5H71aM1OJMhuuj1zKakC+0Mx2w1kUU/8M
        =gV+p
        -----END PGP PUBLIC KEY BLOCK-----
      '';
    } ];
  };

  # git
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing = {
      signByDefault = true;
      key = "6141 1E4F FE10 CE7B 2E14  CD76 0BE8 A88F 47B2 145C";
    };
    settings = {
      init.defaultBranch = "master";
      user = {
        name = "Anillc";
        email = "void@anil.lc";
      };
    };
  };

  # shell
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      if ${pkgs.gnugrep}/bin/grep -qv 'fish' /proc/$PPID/comm && [[ $SHLVL == [1,2] ]] && [[ -z "$BASH_EXECUTION_STRING" ]]; then
        shopt -q login_shell && LOGIN_OPTION="--login" || LOGIN_OPTION=""
        SHELL=${config.programs.fish.package}/bin/fish exec ${config.programs.fish.package}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [ plugin-git done puffer z ]
      |> map (x: { name = x.pname; inherit (x) src; });
    shellAliases = {
      pb = "curl --data-binary @- https://pb.nichi.co/";
      s = "systemctl";
      suser = "systemctl --user";
    };
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings
      for mode in (bind --list-modes)
        bind -M $mode ctrl-c cancel-commandline
      end
    '';
  };
  programs.starship = {
    enable = true;
    settings = {
      format = "$all$time$line_break$battery$status$character";
      directory.truncation_length = 8;
      nix_shell.format = "via [$symbol]($style)";
      time = {
        disabled = false;
        format = "at [$time]($style)";
      };
      scala.disabled = true;
    };
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
