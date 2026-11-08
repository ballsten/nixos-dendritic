{ inputs, ... }:
{
  # Microsoft Teams in a Chromium used for nothing else. Teams needs the Idle
  # Detection API for its presence, which LibreWolf doesn't have
  # (docs/features/teams.md). Signing in stays manual.
  flake.modules = {
    nixos.teams = {
      # Chromium only reads managed policies from /etc, so these are
      # system-wide. The module installs no browser, only the policies.
      programs.chromium = {
        enable = true;
        extraOpts =
          let
            # Teams, its sign-in, and the Microsoft 365 sites files and
            # links in Teams open (SharePoint, OneDrive, Office, Outlook).
            # Each entry covers its subdomains.
            microsoft = [
              "cloud.microsoft"
              "microsoft.com"
              "microsoft365.com"
              "microsoftonline.com"
              "msauth.net"
              "msftauth.net"
              "office.com"
              "office.net"
              "office365.com"
              "officeapps.live.com"
              "live.com"
              "onenote.com"
              "outlook.com"
              "sharepoint.com"
              "skype.com"
              "windows.net"
            ];
          in
          {
            # Every other site is blocked, so this browser can't drift into
            # general use; open other links in LibreWolf.
            URLBlocklist = [ "*" ];
            URLAllowlist = microsoft ++ [
              "about:blank"
              "chrome://*"
            ];

            # Chromium blocks the Idle Detection API on every site. Teams
            # uses it to stay Available while we're active outside its
            # window (docs/features/teams.md#presence).
            IdleDetectionAllowedForUrls = [
              "https://teams.microsoft.com"
              "https://teams.cloud.microsoft"
            ];

            # No extensions, no Google account or sync, and no saved
            # passwords or autofill: passwords live in Bitwarden.
            ExtensionInstallBlocklist = [ "*" ];
            BrowserSignin = 0;
            SyncDisabled = true;
            PasswordManagerEnabled = false;
            AutofillAddressEnabled = false;
            AutofillCreditCardEnabled = false;

            # Google's background services: metrics, Safe Browsing lookups,
            # search suggestions, spelling and translation, error-page
            # suggestions and prefetching. Safe Browsing guards little with
            # only Microsoft sites allowed.
            MetricsReportingEnabled = false;
            UrlKeyedAnonymizedDataCollectionEnabled = false;
            SafeBrowsingProtectionLevel = 0;
            DefaultSearchProviderEnabled = false;
            SearchSuggestEnabled = false;
            SpellCheckServiceEnabled = false;
            TranslateEnabled = false;
            AlternateErrorPagesEnabled = false;
            NetworkPredictionOptions = 2;

            # LibreWolf is the default browser; don't offer to replace it.
            DefaultBrowserSettingEnabled = false;
            # Nothing keeps running once the window is closed.
            BackgroundModeEnabled = false;
          };
      };

      # Every home-manager user on the host gets the app.
      home-manager.sharedModules = [ inputs.self.modules.homeManager.teams ];
    };

    homeManager.teams =
      { lib, pkgs, ... }:
      let
        # Teams as an app window: no tabs or address bar. Chromium itself
        # isn't put on PATH, so this is its only way in. It doesn't
        # recognise Umbriel and would encrypt its cookies with a built-in
        # key instead of the keyring (docs/features/keyring.md).
        teams = pkgs.writeShellApplication {
          name = "teams";
          text = ''
            exec ${lib.getExe pkgs.chromium} \
              --password-store=gnome-libsecret \
              --app=https://teams.cloud.microsoft \
              "$@"
          '';
        };
      in
      {
        home.packages = [ teams ];
        xdg.desktopEntries.teams = {
          name = "Teams";
          genericName = "Chat and meetings";
          exec = "teams";
          icon = "teams";
          categories = [
            "Network"
            "Chat"
          ];
        };

        # Sign-in, cookies and site permissions (camera, microphone,
        # notifications).
        home.persistence."/persist".directories = [ ".config/chromium" ];

        # The Work workspace, toggled with Mod+Alt+W, which Outlook shares
        # (outlook.nix). Needs the app-workspaces feature. Chromium names an
        # app window after its URL and profile.
        appWorkspaces.workspaces.Work = {
          key = "W";
          apps.teams = {
            appId = "^chrome-teams[.]cloud[.]microsoft__.*$";
            command = lib.getExe teams;
          };
        };
      };
  };
}
