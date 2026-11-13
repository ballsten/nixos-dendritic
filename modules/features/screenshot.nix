{ inputs, ... }:
{
  # Screenshots with Noctalia's built-in capture, on Print and Mod+Shift+S.
  # Each one goes on the clipboard, ready to paste into Obsidian or a chat,
  # and is saved to ~/Pictures. Needs the desktop feature for Umbriel and
  # Noctalia; nothing extra is installed.
  flake.modules = {
    # Every home-manager user on the host gets the keybinds.
    nixos.screenshot.home-manager.sharedModules = [ inputs.self.modules.homeManager.screenshot ];

    homeManager.screenshot = {
      programs = {
        # Noctalia's defaults already copy and save. They are set here so
        # a change in a later release can't quietly stop either.
        noctalia.settings.shell.screenshot = {
          copy_to_clipboard = true;
          save_to_file = true;
        };

        umbriel.settings.keybinds =
          let
            shot = command: {
              action = "spawn noctalia msg ${command}";
              repeat = false;
            };
          in
          {
            # Drag out a region. Mod+Shift+S is for keyboards with no
            # Print key, such as the Surface Type Cover.
            "Print" = shot "screenshot-region";
            "Mod+Shift+S" = shot "screenshot-region";
            # Region, then draw arrows, boxes and text on it before copying.
            "Mod+Shift+A" = shot "screenshot-annotate";
            "Mod+Print" = shot "screenshot-window";
            "Shift+Print" = shot "screenshot-fullscreen";
          };
      };
    };
  };
}
