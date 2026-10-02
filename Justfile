# List available recipes
default:
    @just --list

# Format all Nix files
fmt:
    nix fmt

# Regenerate flake.nix (must produce no diff), then run flake checks
check:
    nix run .#write-flake
    git diff --exit-code flake.nix
    nix flake check

# Build a host's system closure without activating it
build host:
    nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel

# Regenerate flake.nix and lock any added or removed inputs
lock:
    nix run .#write-flake
    nix flake lock

# Create your admin age key if missing, then print its public key
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

# Print a host's age recipient, from this machine or via ssh-keyscan
host-key target="local":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{target}}" = local ]; then
        ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
    else
        ssh-keyscan -q -t ed25519 "{{target}}" | cut -d' ' -f2- | ssh-to-age
    fi

# Add a host as a secrets recipient and re-encrypt
enrol-host name target="local":
    #!/usr/bin/env bash
    set -euo pipefail
    export NAME="{{name}}" KEY="$({{just_executable()}} host-key {{target}})"
    if grep -q "$KEY" .sops.yaml; then
        echo "{{name}} is already enrolled" >&2
        exit 0
    fi
    yq -i '.creation_rules[0].key_groups[0].age += [strenv(KEY)] | .creation_rules[0].key_groups[0].age[-1] line_comment = strenv(NAME)' .sops.yaml
    sops updatekeys --yes secrets/secrets.yaml
    echo "Enrolled {{name}} ($KEY)" >&2

# Edit the encrypted secrets file
secrets-edit:
    sops secrets/secrets.yaml

# Set a user's login password (stored as a hash in secrets)
set-password user="ballsten":
    #!/usr/bin/env bash
    set -euo pipefail
    [[ "{{user}}" =~ ^[a-z_][a-z0-9_-]*$ ]] || { echo "Invalid user name: {{user}} (usage: just set-password [user])" >&2; exit 1; }
    hash="$(mkpasswd -m yescrypt)"
    printf %s "$hash" | jq -Rs . | sops set --value-stdin secrets/secrets.yaml '["users"]["{{user}}"]["password"]'
    echo "Password for {{user}} updated; rebuild to apply." >&2

# Set the SSID and PSK of a Wi-Fi network in secrets
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
set-token service user="ballsten":
    #!/usr/bin/env bash
    set -euo pipefail
    [[ "{{service}}" =~ ^(github)$ ]] || { echo "Unknown service: {{service}} (usage: just set-token github [user])" >&2; exit 1; }
    [[ "{{user}}" =~ ^[a-z_][a-z0-9_-]*$ ]] || { echo "Invalid user name: {{user}}" >&2; exit 1; }
    if [ -t 0 ]; then read -rsp "{{service}} token: " token; echo; else read -r token; fi
    [ -n "$token" ] || { echo "Empty token; nothing changed." >&2; exit 1; }
    printf %s "$token" | jq -Rs . | sops set --value-stdin secrets/secrets.yaml '["users"]["{{user}}"]["tokens"]["{{service}}"]'
    echo "{{service}} token for {{user}} updated; rebuild to apply." >&2
