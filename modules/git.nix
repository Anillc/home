{
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
      protocol.file.allow = "always";
    };
  };
}
