_: {
  flake.modules.nixos.immutable-users = {
    # Passwords come from sops (see users/); passwd changes do not persist.
    users.mutableUsers = false;
  };
}
