{ inputs, ... }:
{
  # Features shared by every desktop host. Hardware-specific and host-specific
  # settings (time zone, hostname) stay in modules/hosts/<host>/.
  flake.modules.nixos.workstation = {
    imports = with inputs.self.modules.nixos; [
      nix-settings
      home-manager
      secrets
      unfree
      immutable-users
      locale
      networkmanager
      wifi
      nordvpn
      ssh
      keyring
      desktop
      mic-noise-suppression
      theme
      brave
      prun
      lazygit
      xdg-user-dirs
      obsidian
      vesktop
      element
      calculator
      impermanence
      secure-boot
      tpm-unlock
      fwupd
    ];
  };
}
