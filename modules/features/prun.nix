_: {
  # Prosperous Universe browser extensions, force-installed in LibreWolf.
  # Needs the librewolf feature, which workstation imports. Logging in to
  # FIO stays manual.
  flake.modules.nixos.prun.librewolf.extensions = {
    # Refined PrUn: interface improvements and extra XIT commands.
    "{c35c3edc-0acc-4531-b01c-35b6bede69fb}" = "refined-prun";
    # FIO Client: uploads game data to fio.fnar.net.
    "{d7a1061c-6d18-48fb-a42c-3f1c73b0cdf9}" = "fio";
  };
}
