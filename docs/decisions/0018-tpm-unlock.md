# 0018: TPM unlock bound to PCR 7 and PCR 15, without a PIN

- **Status:** Accepted, 2026-10-05
- **Issue:** #43
- **PR:** #47

## Context

Every boot needed the LUKS passphrase. With Secure Boot live
([0017](0017-secure-boot.md)), the TPM can release the disk key only to a
verified boot.

## Decision

The [tpm-unlock](../features/tpm-unlock.md) feature lets the initrd unlock
`cryptroot` with the TPM, with the passphrase as a fallback.
`just tpm-enroll` seals the key to:

- **PCR 7**, the Secure Boot state;
- **PCR 15 being all zeros.** `tpm2-measure-pcr=yes` records the volume
  key in PCR 15 right after unlocking, so the TPM refuses from then on.

**No TPM PIN** (decided 2026-10-05). A powered-off laptop boots to the
greeter, so the login password protects a stolen machine; a pulled SSD is
still useless on its own.

## Consequences

- PCR 15 blocks a swapped-in fake LUKS partition: our signed initrd would
  boot it with PCR 7 matching, but PCR 15 is no longer zero when it asks.
  Root on the running system can't get the key either.
- Kernel and NixOS updates don't change PCR 7. Secure Boot changes, key
  re-enrollment and `dbx` or firmware updates do, and need
  `just tpm-enroll` again.
- Enrolling is a manual step per host and per LUKS volume, so a reinstall
  needs it again.

## Alternatives considered

- **PCRs 0+2+7 or more:** break on every firmware update.
- **A TPM PIN:** stronger against a stolen machine, but a prompt at every
  boot, which is what this removes.
- **systemd's `fixate-volume-key=`:** pins the root volume too, but puts a
  per-machine hash in the repo.
- **lanzaboote's measured boot or systemd-pcrlock:** bind to more of the
  boot; left out.
