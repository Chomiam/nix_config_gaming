{ config, pkgs, ... }:

{
  # =========================================================================
  # 🛡️ RÈGLES DE PARE-FEU PERSONNALISÉES (CHOMIAMOS)
  # Ce fichier est géré par l'onglet Pare-feu du Dashboard ChomiamOS.
  # Vous pouvez également y ajouter ou supprimer des règles manuellement.
  # =========================================================================

  networking.firewall = {
    # Ports TCP personnalisés autorisés
    allowedTCPPorts = [
    ];

    # Ports UDP personnalisés autorisés
    allowedUDPPorts = [
    ];

    # Plages de ports TCP personnalisées autorisées
    allowedTCPPortRanges = [
    ];

    # Plages de ports UDP personnalisées autorisées
    allowedUDPPortRanges = [
    ];
  };
}
