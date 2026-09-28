let
  modules = [
    ../modules/common
    ../modules/trusted
    ../modules/desktop
  ];
in {
  imports = modules;
  secrets = {
    inherit modules;
    keys.age = [
      "age1p9vcj2y2q59reuswpwjdqj8j3gz5yhz77qm9qeua4f5cc3xe8gqqf698t8" # duet
    ];
  };
}
