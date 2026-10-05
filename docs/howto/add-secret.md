# Add a secret

Secrets are stored encrypted in `secrets/secrets.yaml` with sops. See
[secrets](../features/secrets.md) for keys and how decryption works. Never
commit a decrypted secret.

## 1. Store the value

For a value with its own recipe, use it (`just set-password`,
`just set-wifi`, `just set-token`, `just set-ssh-key`). Otherwise edit the
file:

```sh
just secrets-edit
```

Use a path that says who uses it, such as `users/<user>/tokens/<service>`
or `<feature>/<name>`.

## 2. Declare it in the feature

In a NixOS aspect:

```nix
flake.modules.nixos.example =
  { config, ... }:
  {
    sops.secrets."example/key" = { };
    # decrypted to config.sops.secrets."example/key".path, under /run/secrets
  };
```

In a home-manager aspect the declaration is the same; it decrypts with the
admin key, under `~/.config/sops-nix/secrets/`.

Pass the path to the program; never put the value in the Nix store. If a
program needs the value inside a config file, use a sops template, as the
[wifi](../features/wifi.md) feature does.

A declared secret that is missing from `secrets/secrets.yaml` fails the
build, so a typo is caught before anything is activated.

## 3. A token for a command-line tool

Tokens are never exported in a shell. Wrap the tool with `wrapWithSecrets`
(`modules/flake/lib.nix`) so only its own process gets the variable:

```nix
{ inputs, ... }:
{
  flake.modules.homeManager.ballsten =
    { config, pkgs, ... }:
    {
      sops.secrets."users/ballsten/tokens/example" = { };
      home.packages = [
        (inputs.self.lib.wrapWithSecrets pkgs pkgs.example {
          EXAMPLE_TOKEN = config.sops.secrets."users/ballsten/tokens/example".path;
        })
      ];
    };
}
```

To set it with `just set-token`, add the service name to the recipe's
allowed list in the `Justfile`.

## 4. Document it

Add a row to [What is stored](../features/secrets.md#what-is-stored), and
list the key in the Secrets row of the feature's page.
