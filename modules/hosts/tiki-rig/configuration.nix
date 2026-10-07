{ inputs, ... }:
{
  flake.modules.nixos.tiki-rig = {
    imports = with inputs.self.modules.nixos; [
      workstation
      gaming
      ballsten
    ];

    networking.hostName = "tiki-rig";
    time.timeZone = "Australia/Sydney";
    system.stateVersion = "26.11";
  };
}
