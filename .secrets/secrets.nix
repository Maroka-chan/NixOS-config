let
  localhost = readFile /etc/ssh/ssh_host_ed25519_key.pub;
in
{
  "maroka_pass.age".publicKeys = [ localhost ];
}