{ config, ... }:
{
  age.secrets.tailscale-authkey.file = ../../../../secrets/tailscale-authkey.age;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets.tailscale-authkey.path;
  };
}
