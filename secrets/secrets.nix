let
  kanan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDyMZKyptGPtS/osbdmDrhnn2J08Iiy/i+BrvqvyNBpJ";
  aisaka = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqzG8P89pW2HiMb7zfJgp22t968eHuOsheYEHtuhshl";
  v00334 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrhSFMeWW2HpfqKJVFPmclyrEXrmw4ayisDSxiJWb8l";
  users = [ kanan aisaka ];

  akebi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINSF3y6vy+X6MJ6Nu8UBFQnTd/iFc+xyypCzEdn9UoT2";
  systems = [ akebi ];
in
{
  "maroka-password.age".publicKeys = users;
  "v00334-password.age".publicKeys = [ v00334 ];

  # Akebi
  "shutoku-settings.age".publicKeys = users ++ systems;
  "tailscale-authkey.age".publicKeys = users ++ systems;
  "transmission-settings.age".publicKeys = users ++ systems;
  "vpn-wireguard.age".publicKeys = users ++ systems;
  "restic-env.age".publicKeys = users ++ systems;
  "restic-pass.age".publicKeys = users ++ systems;
  "restic-repo.age".publicKeys = users ++ systems;
  "lego-env.age".publicKeys = users ++ systems;
}
