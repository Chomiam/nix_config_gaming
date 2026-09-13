{ config, pkgs, lib, ... }:

let
  cfg = config.chomiamos.services.omniroute;
in
{
  # =========================================================================
  # 🚀 PASSERELLE IA OMNIROUTE (CONTENEUR OCI VIA PODMAN)
  # Routeur universel d'API IA (Claude, OpenAI, Gemini, DeepSeek, GLM, Grok...)
  # Solution ultra-légère sans modèles locaux lourds à charger en VRAM/RAM.
  # Dashboard Web & API OpenAI-compatible accessibles sur http://localhost:20128
  # =========================================================================

  config = lib.mkIf cfg.enable {
    # Active automatiquement le runtime Podman nécessaire au conteneur
    chomiamos.services.podman.enable = true;

    # Déploiement déclaratif du conteneur OCI OmniRoute
    virtualisation.oci-containers.containers.omniroute = {
      image = cfg.image;
      autoStart = true;
      ports = [
        (if cfg.openFirewall then "${toString cfg.port}:20128" else "127.0.0.1:${toString cfg.port}:20128")
      ];
      volumes = [
        "omniroute-data:/app/data"
      ];
      environment = {
        PORT = "20128";
        OMNIROUTE_MEMORY_MB = toString cfg.memoryMb;
      };
      extraOptions = [
        "--stop-timeout=40"
      ];
    };

    # Ouverture du port dans le pare-feu si demandé
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    # Raccourci vers le Dashboard Web d'OmniRoute dans le menu d'applications
    environment.systemPackages = [
      (pkgs.makeDesktopItem {
        name = "omniroute";
        desktopName = "OmniRoute";
        comment = "Passerelle IA universelle (350+ fournisseurs, proxy API & WebUI)";
        exec = "xdg-open http://localhost:${toString cfg.port}";
        icon = "network-server";
        categories = [ "Development" "Network" ];
      })
    ];
  };
}
