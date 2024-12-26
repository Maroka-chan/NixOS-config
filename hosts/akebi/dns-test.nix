{ pkgs, lib, ... }:
{
  systemd.services.dnstest = {
    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };

    script = let
      vpn-test = pkgs.writeShellApplication {
        name = "vpn-test";

        runtimeInputs = with pkgs; [util-linux unixtools.ping coreutils curl bash libressl netcat-gnu openresolv dig];

        text = ''
          cd "$(mktemp -d)"

          # Print resolv.conf
          echo "/etc/resolv.conf contains:"
          cat /etc/resolv.conf

          # Query resolvconf
          echo "resolvconf output:"
          resolvconf -l
          echo ""

          # Get ip
          echo "Getting IP:"
          curl -s ipinfo.io

          echo -ne "DNS leak test:"
          curl -s https://raw.githubusercontent.com/macvk/dnsleaktest/b03ab54d574adbe322ca48cbcb0523be720ad38d/dnsleaktest.sh -o dnsleaktest.sh
          chmod +x dnsleaktest.sh
          ./dnsleaktest.sh

          echo "resolv:"
          ls /etc/resolv.conf
        '';
      };
    in "${vpn-test}/bin/vpn-test";
  };

  systemd.services.dnspeep = {
    vpnConfinement = {
      enable = true;
      vpnNamespace = "wg";
    };

    script = let
      dnspeep = pkgs.callPackage pkgs.rustPlatform.buildRustPackage rec {
        pname = "dnspeep";
        version = "0.1.3";

        src = pkgs.fetchFromGitHub {
          owner = "jvns";
          repo = "dnspeep";
          rev = "v${version}";
          sha256 = "sha256-QpUbHiMDQFRCTVyjrO9lfQQ62Z3qanv0j+8eEXjE3n4=";
        };

        cargoLock = {
          lockFile = "${src}/Cargo.lock";
          allowBuiltinFetchGit = true;
        };

        buildInputs = with pkgs; [
          libpcap
        ];
        LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
      };
      vpn-test = pkgs.writeShellApplication {
        name = "vpn-test";

        runtimeInputs = with pkgs; [coreutils curl openresolv dnspeep];

        text = ''
          dnspeep
        '';
      };
    in "${vpn-test}/bin/vpn-test";

    requires = ["network-online.target"];
  };
}
