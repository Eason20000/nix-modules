{
  config,
  lib,
  pkgs,
  my,
  osConfig,
  ...
}:

let
  cfg = config.my.home.base;

in
{
  options.my.home.base = {
    username = lib.mkOption { type = lib.types.str; };
    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = osConfig.users.users.${cfg.username}.home;
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = (my.lib.nixos osConfig "base").stateVersion or null;
    };
  };

  config = {
    home.username = cfg.username;
    home.homeDirectory = cfg.homeDirectory;
    home.stateVersion = cfg.stateVersion;

    home.packages = with pkgs; [
      bc
      tree
      just
      nixfmt
      fastfetch
      btop
    ];

    programs.bash = {
      enable = true;
      # Same prompt as NixOS' /etc/bashrc, so interactive shells look identical
      # on NixOS and Darwin.
      initExtra = ''
        if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
          PROMPT_COLOR="1;31m"
          ((UID)) && PROMPT_COLOR="1;32m"
          if [ -n "$INSIDE_EMACS" ]; then
            PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
          else
            PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
          fi
          if test "$TERM" = "xterm"; then
            PS1="\[\033]2;\h:\u:\w\007\]$PS1"
          fi
        fi
      '';
    };

    # Same aliases as NixOS' /etc/bashrc.
    home.shellAliases = {
      l = "ls -alh";
      ll = "ls -l";
      ls = "ls --color=tty";
    };

    programs.dircolors.enable = true;

  };

}
