{ pkgs, vars, ... }:

{
  # =========================================================================
  # 🛡️ GESTION DU PARE-FEU & RÈGLES DE SÉCURITÉ RÉSEAU
  # =========================================================================

  networking.firewall = {
    enable = vars.firewall.enable or (if builtins.isBool (vars.firewall or false) then vars.firewall else false);

    # Ports TCP autorisés
    allowedTCPPorts = [
      53317 # LocalSend (Partage de fichiers local)
    ];

    # Ports UDP autorisés
    allowedUDPPorts = [
      53317 # LocalSend (Découverte d'appareils réseau local)
    ];

    # Plages de ports TCP autorisées
    allowedTCPPortRanges = [
      { from = 27015; to = 27030; } # Jeux Paradox (Stellaris) & Steam session
    ];

    # Plages de ports UDP autorisées
    allowedUDPPortRanges = [
      { from = 3000; to = 3010; }   # Moteur Clausewitz (Multi direct Paradox)
      { from = 27000; to = 27100; } # Jeux Paradox (Stellaris / Matchmaking P2P)
    ];
  };
}
