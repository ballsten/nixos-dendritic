# Enrol the TPM

Lets the TPM unlock the root LUKS volume at boot, so the machine boots
straight to the greeter. How it works is in
[secure-boot](../features/secure-boot.md#tpm-unlock).

Once Secure Boot is on (`bootctl status`: `enabled (user)`):

```sh
just tpm-enroll
```

It asks for the LUKS passphrase and replaces any earlier TPM key. Reboot to
check: the disk unlocks without a prompt.

To see the enrolled slots, or to remove the TPM key and go back to the
passphrase only:

```sh
sudo systemd-cryptenroll /dev/disk/by-partlabel/disk-main-luks
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-partlabel/disk-main-luks
```

## When to enrol again

After anything that changes PCR 7, the TPM refuses and the passphrase is
asked for instead. Run `just tpm-enroll` again once the change is done. See
[When it asks for the passphrase again](../features/secure-boot.md#when-it-asks-for-the-passphrase-again).
