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

  # Query across all NixOS hosts.
  #
  # Type: inputs -> { pred, map, first } -> value | [value] | null
  #
  # pred  = hostConfig -> bool       — filter which hosts to query
  # map   = hostname -> hostConfig -> value  — extract data from matching hosts
  # first = bool (default: false)    — true: return single result (or null);
  #                                    false: return list of results (nulls filtered)
  #
  # Examples:
  #
  #   # Find the tunnel gateway host's contact info
  #   queryHosts inputs {
  #     pred  = h: h.config.my.nixos.ssh.tunnel.enable or false;
  #     map   = _: h: {
  #       host = h.config.my.nixos.base.publicHost or null;
  #       port = lib.head (h.config.my.nixos.ssh.ports or [22]);
  #     };
  #     first = true;
  #   }
  #   # => { host = "example.com"; port = 2222; } | null
  #
  #   # Collect ports from all hosts proxying through this machine
  #   queryHosts inputs {
  #     pred = h: h.config.my.nixos.ssh.reverseProxy.enable or false;
  #     map  = _: h: h.config.my.nixos.ssh.reverseProxy.remotePort;
  #   }
  #   # => [ 29048 48230 ]
  queryHosts =
    inputs:
    {
      pred,
      map,
      first ? false,
    }:
    let
      all = inputs.self.nixosConfigurations or { };
      matching = lib.filterAttrs (_: h: pred h) all;
      mapped = lib.mapAttrsToList map matching;
    in
    if first then lib.head (mapped ++ [ null ]) else lib.filter (v: v != null) mapped;

}
