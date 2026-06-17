{ pkgs, inputs, my, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs my; };
    backupCommand = "${pkgs.trash-cli}/bin/trash";
    sharedModules = [ ../home ];
  };

}
