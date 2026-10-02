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
