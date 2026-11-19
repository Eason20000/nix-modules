{
  lib,
  writeShellApplication,
  libstatgrab,
  coreutils,
  gawk,
}:

writeShellApplication {
  name = "system-status";

  runtimeInputs = [
    libstatgrab
    coreutils
    gawk
  ];

  text = builtins.readFile ./system-status.sh;

  meta = {
    description = "One-shot CPU, memory and network line for tmux";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "system-status";
  };
}
