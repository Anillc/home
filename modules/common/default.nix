{ config, pkgs, lib, ... }: {
  home.stateVersion = "25.11";
  home.username = lib.mkDefault "anillc";
  home.homeDirectory = lib.mkDefault "/home/anillc";

  nixpkgs.config.allowUnfree = true;
  xdg.enable = true;

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
        tBRBbmlsbGMgPGlAYW5pbGxjLmNuPoiOBBMWCgA2FiEEYUEeT/4QznsuFM12C+io
        j0eyFFwFAmJUG8cCGwMECwkIBwQVCgkIBRYCAwEAAh4FAheAAAoJEAvoqI9HshRc
        NhwA/iPY+Mpto7kEOIAUyhUWPENxcxSv6IkCmRQoJy/0oWFBAPwIWVdS6YzsjUaJ
        FzwoK+T8219s8MCPrHhayG6AYzrDBbg4BGJUG8cSCisGAQQBl1UBBQEBB0BJy+5Q
        vc560/+SQI/i/B/hW6fnF3ywNnoF3hgmUD7IIQMBCAeIeAQYFgoAIBYhBGFBHk/+
        EM57LhTNdgvoqI9HshRcBQJiVBvHAhsMAAoJEAvoqI9HshRcnU8A/R0dzEI73C6c
        JqRnFvOWFUiR1nWWtjcqlfsKd4uaPTnUAP9kGP4QfASUZGnScEA4ODqdloDkfqbk
        4zN11qAlaeqlBrg4BGmnyYoSCisGAQQBl1UBBQEBB0DQ3Lfb1R3ZbosGPmSrEjLP
        naPHKlCkjeAOJ2eNnPGoOgMBCAeIfgQYFgoAJhYhBGFBHk/+EM57LhTNdgvoqI9H
        shRcBQJpp8mKAhsMBQkA7U4AAAoJEAvoqI9HshRcfHIBAOgD28kvqyfy+aXH9Lap
        mZHVawAL/1x/9UMZ1cNbNYNNAQCdWBpvdq2puR+9WjNTiTIbro9cympAvtDMdsNZ
        FFP/DA==
        =qk49
        -----END PGP PUBLIC KEY BLOCK-----
      '';
    } ];
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
    plugins = with pkgs.fishPlugins; [ plugin-git done puffer ]
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
