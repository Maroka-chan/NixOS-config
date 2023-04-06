{
    virtualisation.arion = {
        backend = "docker"; # or "docker"
        projects.jellyfin.settings = {
            # Specify you project here, or import it from a file.
            # NOTE: This does NOT use ./arion-pkgs.nix, but defaults to NixOS' pkgs.
            imports = [ ./arion-compose.nix ];
        };
    };
}