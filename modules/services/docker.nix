{ config, lib, ... }:

let
  cfg = config.chomiamos.services.docker;
in
{
  # =========================================================================
  # 🐳 VIRTUALISATION & DOCKER
  # =========================================================================

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";
  };
}
