{ config, pkgs, lib, ... }:

let
  cfg = config.chomiamos.services.podman;
in
{
  # =========================================================================
  # 🦭 VIRTUALISATION & CONTENEURS PODMAN
  # =========================================================================

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    virtualisation.oci-containers.backend = "podman";

    environment.systemPackages = with pkgs; [
      podman-compose
    ];

    # Compatibilité ascendante : définition du groupe docker pour les utilisateurs
    users.groups.docker = {};
  };
}
