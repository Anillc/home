{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."Host *".User = "root";
  };
}
