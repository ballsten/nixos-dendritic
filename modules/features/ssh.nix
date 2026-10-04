_: {
  flake.modules.nixos.ssh = {
    services.openssh.enable = true;

    # System-wide, so a wiped ~/.ssh/known_hosts doesn't prompt again.
    # Fingerprint SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU, as
    # published at docs.github.com.
    programs.ssh.knownHosts."github.com".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };
}
