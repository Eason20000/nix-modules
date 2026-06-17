{ pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [ obs-vaapi ];
  };

  my.home.impermanence.extraDirectories = [ ".config/obs-studio" ];

}
