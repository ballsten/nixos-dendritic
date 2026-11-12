{ inputs, ... }:
{
  flake.modules.nixos.tiki-rig = {
    imports = with inputs.self.modules.nixos; [
      workstation
      gaming
      poe-wheel-click
      flatpak
      roblox
      losslesscut
      ballsten
    ];

    networking.hostName = "tiki-rig";
    time.timeZone = "Australia/Sydney";
    system.stateVersion = "26.11";
  };
}
