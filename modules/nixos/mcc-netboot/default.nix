# client.nix is loaded only by server.nix's nixosSystem, not imported here.
{ ... }:

{
  imports = [ ./server.nix ];
}
