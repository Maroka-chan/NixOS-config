{ inputs, config, lib, username, ... }:
{
  programs.fuse.userAllowOther = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs username; };
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
