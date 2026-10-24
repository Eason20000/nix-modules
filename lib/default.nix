{ lib, ... }:

{
  _module.args.my.lib = import ./my-lib.nix { inherit lib; };

}
