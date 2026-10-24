{
  config,
  lib,
  pkgs,
  my,
  osConfig,
  ...
}:

let
  cfg = config.my.home.ssh-auto-tmux;

in
{
  options.my.home.ssh-auto-tmux = {
    enable = lib.mkEnableOption "" // {
      default = my.lib.on osConfig "ssh";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fastfetch ];

    programs.bash = {
      enable = true;
      initExtra = ''
        if [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
          tmux attach-session -t SSH || tmux new-session -s SSH
          exit
        fi
      '';
    };

    programs.tmux.enable = true;

  };

}
