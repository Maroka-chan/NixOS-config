{...}: {
  services.jellyfin = {
    enable = false;
    group = "media";
    openFirewall = true;
  };
}
