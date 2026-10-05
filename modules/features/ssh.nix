_: {
  flake.modules.nixos.ssh = {
    services.openssh = {
      enable = true;
      # Read straight from /persist, not a bind mount into /etc: sops
      # decrypts with this key during activation, which can run before the
      # bind mounts exist. sops' sshKeyPaths defaults to these keys.
      hostKeys = [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    # System-wide, so a wiped ~/.ssh/known_hosts doesn't prompt again.
    # Fingerprint SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU, as
    # published at docs.github.com.
    programs.ssh.knownHosts."github.com".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };
}
