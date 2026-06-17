{ config, lib, pkgs, my, osConfig, ... }:

let
  cfg = config.my.home.kmscon-auto-tmux;

in
{
  options.my.home.kmscon-auto-tmux = {
    enable = lib.mkEnableOption "" // {
      default = my.lib.on osConfig "kmscon";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fastfetch ];

    programs.bash = {
      enable = true;
      initExtra = ''
        if [ "$COLORTERM" == 'kmscon' ] && [ -z "$TMUX" ]; then
          tmux attach-session -t KMSC || tmux new-session -s KMSC
          exit
        fi
      '';
    };

    programs.tmux.enable = true;

  };

}
