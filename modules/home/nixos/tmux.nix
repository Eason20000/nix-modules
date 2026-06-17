{ pkgs, lib, ... }:

{
  programs.tmux.extraConfig = lib.mkAfter ''
    set-option -g status-right "#(${pkgs.system-status}/bin/system-status)"
  '';

}
