{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    package = pkgs.openssh;
    settings."Host *".User = "root";
  };
}
