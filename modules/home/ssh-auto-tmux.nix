{
  config,
  lib,
  ...
}:

let
  cfg = config.my.home.ssh-auto-tmux;

in
{
  options.my.home.ssh-auto-tmux = {
    enable = lib.mkEnableOption "" // {
      # Follows the shared SSH client module, so both NixOS and Darwin hosts
      # get the same behaviour.
      default = config.my.home.ssh.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bash.initExtra = ''
      if [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
        tmux attach-session -t SSH || tmux new-session -s SSH
        exit
      fi
    '';
  };

}
