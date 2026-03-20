let
  deployment_user = "deploy";
in {
  users.users."${deployment_user}" = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "media"
      "cdrom"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACND2J9fKAkmtqdpo2EWs5XO0TAD0xoaoe902h1+PQI albmj@BMJ-Desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoh9yw4eTB5eATKle5N1iWGL/MhYmFpvTm94q3oI8pN albmj@BMJ-Duo"
    ];
  };

  # Allow the deployment user to run any command as root without a password
  security.sudo.extraRules = [
    {
      users = ["${deployment_user}"];
      commands = [
        {
          command = "ALL";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
}
