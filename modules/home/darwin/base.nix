{ pkgs, ... }:

{
  # GNU ls, required by the shared `ls --color=tty` aliases: macOS' BSD ls
  # does not understand --color.
  home.packages = [ pkgs.coreutils ];
}
