{ inputs, ... }:
{
  # Outlook on the web in an app window of the Teams Chromium, sharing its
  # profile and sign-in, on the Work workspace next to Teams. Needs the teams
  # feature for that Chromium's policies (docs/features/outlook.md).
  flake.modules = {
    # Every home-manager user on the host gets the app.
    nixos.outlook.home-manager.sharedModules = [ inputs.self.modules.homeManager.outlook ];

    homeManager.outlook =
      { lib, pkgs, ... }:
      let
        # Started like teams (teams.nix): an app window, cookies encrypted
        # with the keyring.
        outlook = pkgs.writeShellApplication {
          name = "outlook";
          text = ''
            exec ${lib.getExe pkgs.chromium} \
              --password-store=gnome-libsecret \
              --app=https://outlook.cloud.microsoft/mail/ \
              "$@"
          '';
        };
      in
      {
        home.packages = [ outlook ];
        xdg.desktopEntries.outlook = {
          name = "Outlook";
          genericName = "Mail and calendar";
          exec = "outlook";
          icon = "internet-mail";
          categories = [
            "Network"
            "Email"
          ];
        };

        # On Teams' Work workspace; Mod+Alt+W starts whichever of the two
        # isn't running. Needs the app-workspaces feature.
        appWorkspaces.workspaces.Work.apps.outlook = {
          appId = "^chrome-outlook[.]cloud[.]microsoft__.*$";
          command = lib.getExe outlook;
        };
      };
  };
}
