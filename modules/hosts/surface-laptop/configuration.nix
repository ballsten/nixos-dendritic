{ inputs, ... }:
{
  flake.modules.nixos.surface-laptop = {
    imports = with inputs.self.modules.nixos; [
      workstation
      ballsten
    ];

    networking.hostName = "surface-laptop";
    time.timeZone = "Australia/Sydney";
    system.stateVersion = "25.11";
  };
}
