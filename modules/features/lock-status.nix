{ inputs, ... }:
{
  # Reports the screen lock on org.gnome.ScreenSaver, from logind's
  # LockedHint. Noctalia's org.freedesktop.ScreenSaver has no GetActive, so
  # without this Chromium's Idle Detection API never sees a lock and Teams
  # stays Available. Needs the desktop feature for Noctalia's lock.
  flake.modules = {
    # Every home-manager user on the host gets the service.
    nixos.lock-status.home-manager.sharedModules = [ inputs.self.modules.homeManager.lock-status ];

    homeManager.lock-status =
      { lib, pkgs, ... }:
      let
        lock-status =
          pkgs.writers.writePython3Bin "lock-status"
            {
              libraries = [ pkgs.python3Packages.dbus-next ];
              # dbus-next takes D-Bus signatures as annotations ("b"), which
              # pyflakes reads as undefined names.
              flakeIgnore = [ "F821" ];
            }
            ''
              import asyncio

              from dbus_next import BusType, RequestNameReply
              from dbus_next.aio import MessageBus
              from dbus_next.service import ServiceInterface, method, signal

              LOGIN1 = "org.freedesktop.login1"


              class ScreenSaver(ServiceInterface):
                  def __init__(self):
                      super().__init__("org.gnome.ScreenSaver")
                      self.locked = False

                  @method()
                  def GetActive(self) -> "b":
                      return self.locked

                  @signal()
                  def ActiveChanged(self) -> "b":
                      return self.locked

                  def set_locked(self, locked):
                      if locked != self.locked:
                          self.locked = locked
                          self.ActiveChanged()


              async def login1(bus, path):
                  node = await bus.introspect(LOGIN1, path)
                  return bus.get_proxy_object(LOGIN1, path, node)


              async def main():
                  system = await MessageBus(bus_type=BusType.SYSTEM).connect()

                  # A user service isn't in the session, so ask logind for
                  # the user's graphical one.
                  user = await login1(system, "/org/freedesktop/login1/user/self")
                  _, session_path = await user.get_interface(
                      "org.freedesktop.login1.User"
                  ).get_display()
                  session = await login1(system, session_path)

                  screensaver = ScreenSaver()

                  def on_changed(_interface, changed, _invalidated):
                      if "LockedHint" in changed:
                          screensaver.set_locked(changed["LockedHint"].value)

                  session.get_interface(
                      "org.freedesktop.DBus.Properties"
                  ).on_properties_changed(on_changed)
                  screensaver.locked = await session.get_interface(
                      "org.freedesktop.login1.Session"
                  ).get_locked_hint()

                  bus = await MessageBus().connect()
                  bus.export("/org/gnome/ScreenSaver", screensaver)
                  reply = await bus.request_name("org.gnome.ScreenSaver")
                  if reply != RequestNameReply.PRIMARY_OWNER:
                      raise SystemExit(f"org.gnome.ScreenSaver is taken: {reply}")

                  await bus.wait_for_disconnect()


              asyncio.run(main())
            '';
      in
      {
        # Chromium picks its lock service when it starts, so this has to be
        # running before Brave is (docs/features/lock-status.md).
        systemd.user.services.lock-status = {
          Unit = {
            Description = "Screen lock state on org.gnome.ScreenSaver";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            Type = "dbus";
            BusName = "org.gnome.ScreenSaver";
            ExecStart = lib.getExe lock-status;
            Restart = "on-failure";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
  };
}
