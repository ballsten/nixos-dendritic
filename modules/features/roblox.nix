{ inputs, ... }:
{
  # Roblox through Sober, which runs Roblox's Android client natively. The
  # Windows client doesn't run under Wine. Sober is only published on
  # Flathub, so a host that imports roblox also imports flatpak. See
  # docs/features/roblox.md.
  flake.modules = {
    nixos.roblox = {
      services.flatpak.packages = [ "org.vinegarhq.Sober" ];
      # Every home-manager user on the host keeps their Sober data.
      home-manager.sharedModules = [ inputs.self.modules.homeManager.roblox ];
    };

    # Login, settings and the Roblox client Sober downloads.
    homeManager.roblox.home.persistence."/persist".directories = [ ".var/app/org.vinegarhq.Sober" ];
  };
}
