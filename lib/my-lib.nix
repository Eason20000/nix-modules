{ lib }:

rec {
  # Is this osConfig from a NixOS host?
  isNixOS = osConfig: osConfig.my ? nixos;

  # Is this osConfig from a Darwin host?
  isDarwin = osConfig: osConfig.my ? darwin;

  # Safely get a NixOS module's entire option set. Returns {} if not NixOS.
  nixos = osConfig: name: (osConfig.my.nixos or { }).${name} or { };

  # Safely get a NixOS module's enable flag. Returns false if not NixOS.
  on = osConfig: name: (nixos osConfig name).enable or false;

  # Safely get a Darwin module's entire option set. Returns {} if not Darwin.
  darwin = osConfig: name: (osConfig.my.darwin or { }).${name} or { };

  # Safely get a Darwin module's enable flag. Returns false if not Darwin.
  darwinOn = osConfig: name: (darwin osConfig name).enable or false;

}
