_: {
  flake.modules.nixos.wifi =
    { config, ... }:
    let
      inherit (config.sops) placeholder;
    in
    {
      sops = {
        secrets."wifi/home/ssid" = { };
        secrets."wifi/home/psk" = { };

        templates."wifi.env".content = ''
          HOME_SSID=${placeholder."wifi/home/ssid"}
          HOME_PSK=${placeholder."wifi/home/psk"}
        '';
      };

      networking.networkmanager.ensureProfiles = {
        environmentFiles = [ config.sops.templates."wifi.env".path ];
        profiles.home = {
          connection = {
            id = "home";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$HOME_SSID";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$HOME_PSK";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };
}
