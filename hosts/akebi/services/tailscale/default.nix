{ pkgs, config, ... }:
{
  sops.secrets = {
    tailscale_authkey = {};
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscale_authkey.path;
  };
}
