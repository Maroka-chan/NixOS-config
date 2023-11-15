{ pkgs, config, ... }:
{
  services.syncthing = {
    enable = true;
    # Set up devices
  };
}
