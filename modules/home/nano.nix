{ pkgs, ... }:

{
  home.file.".config/nano/nanorc".text = ''
    include "${pkgs.nano}/share/nano/*.nanorc"

    set afterends
    set atblanks
    set autoindent
    set guidestripe 80
    set indicator
    set jumpyscrolling
    set linenumbers
    set locking
    set mouse
    set nohelp
    set positionlog
    set softwrap
    set tabsize 2
    set tabstospaces
    bind ^F forward main
    bind ^B back main
    bind M-F formatter main
    bind M-B linter main
  '';

  home.packages = [ pkgs.nano ];

}
