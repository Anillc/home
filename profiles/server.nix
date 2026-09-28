let
  modules = [
    ../modules/common
    ../modules/trusted
  ];
in {
  imports = modules;
  secrets = {
    inherit modules;
    keys.age = [
      "age14qre8mr77uwwpzsk8na65ex92ulfewus37prer4yl62pjsdq7f6srrxpmu" # cola
      "age1z0tt5kr6maz5wv35pc73w7h5wrt0hpl06c7alskj6yuvttfrz9vqt75fzv" # hk
      "age1t6wjdm624k6fqcdy8m5ayj3ff6s8dpylqq24q78alwrvrrjq0vesxp8906" # home
      "age1380glkudxufzscly9e5ne68uns9dge39vns4ckanjhrxdfd979kq8wkcdn" # trunc
    ];
  };
  home.username = "root";
  home.homeDirectory = "/root";
}
