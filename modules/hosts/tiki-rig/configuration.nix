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
    # TODO: set to the installer's release when installing.
    system.stateVersion = "26.11";
  };
}
