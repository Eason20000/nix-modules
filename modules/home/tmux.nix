{ pkgs, config, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-t";
    mouse = true;
    clock24 = true;
    escapeTime = 250;
    historyLimit = 5000;
    extraConfig = ''
      bind ${config.programs.tmux.prefix} send-prefix
      set-option -g set-clipboard on
      set-option -g status-position top
      set-option -g status-style "bg=color232 fg=color255"
      set-option -g status-interval 1
      set-option -g status-right-length 60
      set-option -g pane-border-status top
      set-option -g pane-border-format "#{pane_current_command}"
      set-option -g pane-border-lines heavy
    '';
  };

}
