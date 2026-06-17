{ pkgs, ... }:

{
  home.packages = with pkgs; [
    coreutils
    tree
    firefox
    vlc-bin
    prismlauncher
    utm
  ];

  home.shellAliases = {
    ls = "ls --color=auto";
    ll = "ls -l --color=auto";
    la = "ls -a --color=auto";
  };

}
