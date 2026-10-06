_: {
  # Firmware updates from LVFS, including the UEFI revocation list (dbx).
  # With Secure Boot on, lanzaboote's module signs fwupd's EFI capsule
  # updater with our keys, so nothing else is needed here. See
  # docs/features/fwupd.md.
  flake.modules.nixos.fwupd = {
    # Also enables fwupd-refresh.timer, which only downloads metadata.
    services.fwupd.enable = true;

    # Update history and pending capsule updates, which must survive the
    # reboot that applies them, and the downloaded metadata.
    environment.persistence."/persist".directories = [ "/var/lib/fwupd" ];
  };
}
