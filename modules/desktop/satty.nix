{ config, pkgs, ... }: {
  home.packages = [ pkgs.grim pkgs.slurp pkgs.wl-clipboard pkgs.jq ];

  programs.satty = {
    enable = true;
    settings.general = {
      fullscreen = true;
      corner-roundness = 12;
      output-filename = "${config.home.homeDirectory}/Pictures/Screenshots/screenshot-%Y-%m-%d_%H-%M-%S.png";
    };
  };
}
