let
  kanan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDyMZKyptGPtS/osbdmDrhnn2J08Iiy/i+BrvqvyNBpJ";
  users = [ kanan ];

  akebi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINSF3y6vy+X6MJ6Nu8UBFQnTd/iFc+xyypCzEdn9UoT2";
  systems = [ akebi ];
in
{
  "maroka-password.age".publicKeys = users;

  # Akebi
  "shutoku-settings.age".publicKeys = users ++ systems;
  "tailscale-authkey.age".publicKeys = users ++ systems;
  "transmission-settings.age".publicKeys = users ++ systems;
  "vpn-wireguard.age".publicKeys = users ++ systems;
  "restic-env.age".publicKeys = users ++ systems;
  "restic-pass.age".publicKeys = users ++ systems;
  "restic-repo.age".publicKeys = users ++ systems;
}
