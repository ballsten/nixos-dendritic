# List available recipes
[private]
default:
    @just --list --unsorted

# ---------------------------------------------------------------------------
# nix: format, check, lock and build the flake
# ---------------------------------------------------------------------------

# Format all Nix files
[group("nix")]
fmt:
    nix fmt

# Lint Nix files, GitHub workflows and docs coverage (also run by nix flake check)
[group("nix")]
lint:
    statix check .
    deadnix --fail .
    actionlint
    check-docs

# Regenerate flake.nix (must produce no diff), then run flake checks
[group("nix")]
check:
    nix run .#write-flake
    git diff --exit-code flake.nix
    nix flake check

# Regenerate flake.nix and lock any added or removed inputs
[group("nix")]
lock:
    nix run .#write-flake
    nix flake lock

# Update all inputs, or those named, and list the ones that moved
[group("nix")]
update *inputs:
    #!/usr/bin/env bash
    set -euo pipefail
    old="$(mktemp)"
    trap 'rm -f "$old"' EXIT
    cp flake.lock "$old"
    nix run .#write-flake
    nix flake update {{inputs}}
    # A Markdown table of the direct inputs whose lock changed, for the PR.
    jq -nr --slurpfile old "$old" --slurpfile new flake.lock '
        def locked($lock; $name): $lock[0].nodes[$lock[0].nodes.root.inputs[$name]].locked;
        def show: "\((.rev // .narHash[7:])[:7]) (\(.lastModified // 0 | todate[:10]))";
        [$new[0].nodes.root.inputs | to_entries[] | select(.value | type == "string") | .key
            | {name: ., old: locked($old; .), new: locked($new; .)}
            | select(.old.narHash != .new.narHash)]
        | if length == 0 then "No inputs changed."
          else "| Input | Old | New |", "|---|---|---|",
               (.[] | "| \(.name) | \(.old | show) | \(.new | show) |")
          end'

# Build a host's system closure without activating it
[group("nix")]
build host:
    nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel

# ---------------------------------------------------------------------------
# rebuild: apply a host's configuration with nixos-rebuild (defaults to this
# machine's hostname)
# ---------------------------------------------------------------------------

# Activate a host's configuration now, without adding a boot entry
[group("rebuild")]
test host="":
    @{{just_executable()}} _rebuild test "{{host}}"

# Activate a host's configuration now and make it the boot default
[group("rebuild")]
switch host="":
    @{{just_executable()}} _rebuild switch "{{host}}"

# Make a host's configuration the boot default without activating it
[group("rebuild")]
boot host="":
    @{{just_executable()}} _rebuild boot "{{host}}"

[private]
_rebuild action host:
    #!/usr/bin/env bash
    set -euo pipefail
    host="{{host}}"
    host="${host:-$(hostname)}"
    [ -d "modules/hosts/$host" ] || { echo "Unknown host: $host (see modules/hosts/)" >&2; exit 1; }
    nixos-rebuild {{action}} --flake ".#$host" --sudo

# ---------------------------------------------------------------------------
# keys: age keys and secrets recipients
# ---------------------------------------------------------------------------

# Create your admin age key if missing, then print its public key
[group("keys")]
admin-key:
    #!/usr/bin/env bash
    set -euo pipefail
    f="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
    if [ ! -f "$f" ]; then
        mkdir -p "$(dirname "$f")"
        (umask 077; age-keygen -o "$f" 2>/dev/null)
        echo "Created $f. Back it up somewhere safe." >&2
    fi
    age-keygen -y "$f"

# Print a host's age recipient (target: local, a hostname, an age1 key or a .pub file)
[group("keys")]
host-key target="local":
    #!/usr/bin/env bash
    set -euo pipefail
    target="{{target}}"
    # The local sshd serves the host key without root; the key file is root-only.
    [ "$target" = local ] && target=localhost
    case "$target" in
        age1*) key="$target" ;;
        *.pub)
            [ -r "$target" ] || { echo "Cannot read $target" >&2; exit 1; }
            key="$(ssh-to-age < "$target")"
            ;;
        *) key="$(ssh-keyscan -q -t ed25519 "$target" | cut -d' ' -f2- | ssh-to-age)" ;;
    esac
    [[ "$key" =~ ^age1[02-9ac-hj-np-z]{58}$ ]] || { echo "Not an age recipient from $target: $key" >&2; exit 1; }
    echo "$key"

# Add a host as a secrets recipient and re-encrypt (target as for host-key)
[group("keys")]
enrol-host name target="local":
    #!/usr/bin/env bash
    set -euo pipefail
    export NAME="{{name}}" KEY="$({{just_executable()}} host-key "{{target}}")"
    if grep -q "$KEY" .sops.yaml; then
        echo "{{name}} is already enrolled" >&2
        exit 0
    fi
    yq -i '.creation_rules[0].key_groups[0].age += [strenv(KEY)] | .creation_rules[0].key_groups[0].age[-1] line_comment = strenv(NAME)' .sops.yaml
    sops updatekeys --yes secrets/secrets.yaml
    echo "Enrolled {{name}} ($KEY)" >&2

# Bind this machine's root LUKS volume to its TPM, replacing any old binding
[group("keys")]
tpm-enroll:
    #!/usr/bin/env bash
    set -euo pipefail
    dev="$(sudo cryptsetup status cryptroot | awk '$1 == "device:" { print $2 }')"
    [ -n "$dev" ] || { echo "cryptroot is not open" >&2; exit 1; }
    # PCR 7: Secure Boot state. PCR 15 still zero: no volume unlocked yet
    # (see modules/features/tpm-unlock.nix).
    sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto \
        --tpm2-pcrs="7+15:sha256=0000000000000000000000000000000000000000000000000000000000000000" "$dev"

# ---------------------------------------------------------------------------
# secrets: edit and set values in secrets/secrets.yaml
# ---------------------------------------------------------------------------

# Edit the encrypted secrets file
[group("secrets")]
secrets-edit:
    sops secrets/secrets.yaml

# Set a user's login password (stored as a hash in secrets)
[group("secrets")]
set-password user="ballsten":
    #!/usr/bin/env bash
    set -euo pipefail
    [[ "{{user}}" =~ ^[a-z_][a-z0-9_-]*$ ]] || { echo "Invalid user name: {{user}} (usage: just set-password [user])" >&2; exit 1; }
    hash="$(mkpasswd -m yescrypt)"
    printf %s "$hash" | jq -Rs . | sops set --value-stdin secrets/secrets.yaml '["users"]["{{user}}"]["password"]'
    echo "Password for {{user}} updated; rebuild to apply." >&2

# Set the SSID and PSK of a Wi-Fi network in secrets
[group("secrets")]
set-wifi network="home":
    #!/usr/bin/env bash
    set -euo pipefail
    [[ "{{network}}" =~ ^[a-z0-9_-]+$ ]] || { echo "Invalid network name: {{network}} (usage: just set-wifi [network])" >&2; exit 1; }
    read -rp "SSID: " ssid
    read -rsp "PSK: " psk; echo
    printf %s "$ssid" | jq -Rs . | sops set --value-stdin secrets/secrets.yaml '["wifi"]["{{network}}"]["ssid"]'
    printf %s "$psk" | jq -Rs . | sops set --value-stdin secrets/secrets.yaml '["wifi"]["{{network}}"]["psk"]'
    echo "Wi-Fi {{network}} updated; rebuild to apply." >&2

# Set an API token (github) in secrets; reads stdin if piped
[group("secrets")]
set-token service user="ballsten":
    #!/usr/bin/env bash
    set -euo pipefail
    [[ "{{service}}" =~ ^(github)$ ]] || { echo "Unknown service: {{service}} (usage: just set-token github [user])" >&2; exit 1; }
    [[ "{{user}}" =~ ^[a-z_][a-z0-9_-]*$ ]] || { echo "Invalid user name: {{user}}" >&2; exit 1; }
    if [ -t 0 ]; then read -rsp "{{service}} token: " token; echo; else read -r token; fi
    [ -n "$token" ] || { echo "Empty token; nothing changed." >&2; exit 1; }
    printf %s "$token" | jq -Rs . | sops set --value-stdin secrets/secrets.yaml '["users"]["{{user}}"]["tokens"]["{{service}}"]'
    echo "{{service}} token for {{user}} updated; rebuild to apply." >&2

# Store a user's SSH private key in secrets (default ~/.ssh/id_ed25519)
[group("secrets")]
set-ssh-key key="~/.ssh/id_ed25519" user="ballsten":
    #!/usr/bin/env bash
    set -euo pipefail
    [[ "{{user}}" =~ ^[a-z_][a-z0-9_-]*$ ]] || { echo "Invalid user name: {{user}} (usage: just set-ssh-key [key] [user])" >&2; exit 1; }
    key="{{key}}"; key="${key/#\~/$HOME}"
    [ -r "$key" ] || { echo "Cannot read $key" >&2; exit 1; }
    [ "$(head -1 "$key")" = "-----BEGIN OPENSSH PRIVATE KEY-----" ] || { echo "$key is not an OpenSSH private key" >&2; exit 1; }
    # The key is decrypted for ssh without a prompt, so it must have no passphrase.
    ssh-keygen -y -P "" -f "$key" >/dev/null 2>&1 || { echo "$key has a passphrase; remove it with ssh-keygen -p first" >&2; exit 1; }
    jq -Rs . < "$key" | sops set --value-stdin secrets/secrets.yaml '["users"]["{{user}}"]["ssh"]["id_ed25519"]'
    echo "SSH key for {{user}} updated; rebuild to apply." >&2
