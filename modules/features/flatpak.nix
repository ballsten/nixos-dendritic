{ inputs, ... }:
{
  # Has no inputs of its own.
  flake-file.inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";

  # Flatpak with the Flathub remote, for apps only published there (such as
  # Sober in roblox). Features add apps with services.flatpak.packages; the
  # flatpak-managed-install service installs them at boot. The list is
  # declarative: apps installed by hand are removed. See
  # docs/features/flatpak.md.
  flake.modules.nixos.flatpak = {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.flatpak = {
      enable = true;
      uninstallUnmanaged = true;
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };

    # Installed apps and runtimes; without it they would be downloaded again
    # on every boot.
    environment.persistence."/persist".directories = [ "/var/lib/flatpak" ];
  };
}
