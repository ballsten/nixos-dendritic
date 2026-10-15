{ inputs, ... }:
{
  # gnome-keyring as the Secret Service, where Element, Brave and other apps
  # keep their keys. The greeter's PAM stack (greetd includes login) unlocks
  # the "login" keyring with the login password, creating it on first login.
  flake.modules = {
    nixos.keyring = {
      services.gnome = {
        gnome-keyring.enable = true;
        # Its SSH agent is on by default with gnome-keyring. ssh uses the key
        # from sops directly (docs/features/secrets.md#ssh-key), so leave it
        # off rather than change how ssh finds keys.
        gcr-ssh-agent.enable = false;
      };
      # To see stored secrets and change the keyring's password, which doesn't
      # follow the login password (docs/features/keyring.md).
      programs.seahorse.enable = true;

      home-manager.sharedModules = [ inputs.self.modules.homeManager.keyring ];
    };

    # The keyrings themselves. gnome-keyring saves by writing a new file and
    # renaming it over the old one, so the directory is persisted.
    homeManager.keyring.home.persistence."/persist".directories = [
      ".local/share/keyrings"
    ];
  };
}
