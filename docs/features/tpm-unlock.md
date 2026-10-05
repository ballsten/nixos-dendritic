# tpm-unlock

Unlocks the root LUKS volume with the TPM, falling back to the passphrase.

| | |
|---|---|
| Module | `modules/features/tpm-unlock.nix` |
| Aspects | `nixos.tpm-unlock` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing (the key is sealed in the TPM and enrolled in the LUKS header) |
| Secrets | None |
| Recipes | `just tpm-enroll` |

Adds `tpm2-device=auto` and `tpm2-measure-pcr=yes` to `cryptroot` in the
initrd's crypttab. Until `just tpm-enroll` has run, or whenever the TPM
refuses, the initrd asks for the passphrase as before.

It depends on [secure-boot](secure-boot.md): the key is bound to PCR 7,
which records the Secure Boot state. How it works, when it asks for the
passphrase again, and how to remove it are all in
[secure-boot](secure-boot.md#tpm-unlock).
