{ inputs, ... }:
{
  # Element, the Matrix client. Its settings are left to the app; only its
  # state is persisted. The key to its local message database goes in
  # gnome-keyring: needs the keyring feature, which workstation imports.
  flake.modules = {
    # Every home-manager user on the host gets it.
    nixos.element.home-manager.sharedModules = [ inputs.self.modules.homeManager.element ];

    homeManager.element =
      { pkgs, ... }:
      {
        programs.element-desktop = {
          enable = true;
          # Electron doesn't recognise Umbriel and would use its built-in
          # key instead of the keyring (docs/features/keyring.md). Wrapped
          # rather than overriding commandLineArgs, which would rebuild
          # Element locally instead of using the binary cache.
          package = pkgs.symlinkJoin {
            inherit (pkgs.element-desktop) name meta;
            paths = [ pkgs.element-desktop ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/element-desktop \
                --add-flags --password-store=gnome-libsecret
            '';
          };
        };
        # Login, session and encryption keys, the message database and
        # settings.
        home.persistence."/persist".directories = [ ".config/Element" ];
      };
  };
}
