{inputs, ...}: {
  users.users.sshfs = {
    isNormalUser = true;
    extraGroups = ["media"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACND2J9fKAkmtqdpo2EWs5XO0TAD0xoaoe902h1+PQI albmj@BMJ-Desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoh9yw4eTB5eATKle5N1iWGL/MhYmFpvTm94q3oI8pN albmj@BMJ-Duo"
    ];
  };
}
