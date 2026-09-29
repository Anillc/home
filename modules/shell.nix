{ config, pkgs, ... }: {
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
      v = "nvim";
    };
    interactiveShellInit = ''
      set fish_greeting
      fish_vi_key_bindings
      bind -M insert -m default jj backward-char force-repaint
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
