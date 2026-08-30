{ pkgs, ... }:

{
  # =========================================================================
  # 🛡️ GESTION DU PARE-FEU & RÈGLES DE SÉCURITÉ RÉSEAU
  # =========================================================================

  networking.firewall = {
    enable = true;

    # Ports TCP autorisés
    allowedTCPPorts = [
      53317 # LocalSend (Partage de fichiers local)
    ];

    # Ports UDP autorisés
    allowedUDPPorts = [
      53317 # LocalSend (Découverte d'appareils réseau local)
    ];
  };
}
