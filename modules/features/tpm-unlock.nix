_: {
  # Unlock the root LUKS volume (cryptroot, from each host's disk.nix) with
  # the TPM once a key is enrolled with `just tpm-enroll`; until then, and
  # whenever the TPM refuses, it falls back to the passphrase.
  #
  # The key is bound to PCR 7 (Secure Boot state, see the secure-boot
  # feature) and to PCR 15 being zero. Measuring the volume key into PCR 15
  # after unlocking means a system booted from any other volume, or this
  # one once it's running, can't get the key from the TPM again. See
  # docs/secure-boot.md.
  flake.modules.nixos.tpm-unlock = {
    boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = [
      "tpm2-device=auto"
      "tpm2-measure-pcr=yes"
    ];
  };
}
