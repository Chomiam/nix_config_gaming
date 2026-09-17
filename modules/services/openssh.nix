{ config, lib, ... }:

let
  cfg = config.chomiamos.services.openssh;
in
{
  # =========================================================================
  # 🔒 SERVICE OPENSSH (ACCÈS À DISTANCE SÉCURISÉ)
  # =========================================================================

  config = lib.mkIf cfg.enable {
    users.groups.sftp-users = {};

    services.openssh = {
      enable = true;
      openFirewall = cfg.openFirewall;
      ports = cfg.ports;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;
        PermitRootLogin = lib.mkDefault "prohibit-password";
        X11Forwarding = false;
      };
      extraConfig = ''
        # Inclusion des règles de partage sFTP générées par le Dashboard
        Include /etc/nixos/sftp-sshd*.conf
      '';
    };
  };
}
