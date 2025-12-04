{
  lib,
  runCommand,
  jq,
  curl,
  cacert,
}:
lib.fetchers.withNormalizedHash { } (
  {
    gh_username,
    outputHash,
    outputHashAlgo,
    recursiveHash ? false,
    postFetch ? "",
  }:
  runCommand gh_username
    {
      nativeBuildInputs = [
        jq
        curl
      ];

      inherit outputHash outputHashAlgo;
      outputHashMode = if recursiveHash then "recursive" else "flat";

      preferLocalBuild = true;

      # Provide CA certificates
      SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    }
    ''
      AVATAR_URL=$(curl https://api.github.com/users/${gh_username} | jq -r '.avatar_url')
      curl -o $out "$AVATAR_URL"

      ${postFetch}
    ''
)
