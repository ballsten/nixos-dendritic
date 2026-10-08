_: {
  # Prosperous Universe browser extensions, force-installed in Brave. Needs
  # the brave feature, which workstation imports. Logging in to FIO stays
  # manual.
  flake.modules.nixos.prun.brave.extensions = [
    # Refined PrUn: interface improvements and extra XIT commands.
    "coabeheneafgglpakallmkienlidgaof"
    # FIO Client: uploads game data to fio.fnar.net.
    "honhnhpbngledkpkocmeihfgkfmocmkh"
  ];
}
