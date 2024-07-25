{ pkgs, config, ... }:
{
  services.nfs = {
    server.enable = true;
    server.exports = ''
      /data/media 192.168.1.0/24(ro,sync,fsid=0,no_subtree_check,insecure)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
