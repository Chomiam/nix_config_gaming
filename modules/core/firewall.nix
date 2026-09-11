{ config, pkgs, lib, ... }:

let
  userFirewallPath = ../../firewall-user.nix;
in
{
  imports = lib.optional (builtins.pathExists userFirewallPath) userFirewallPath;

  # =========================================================================
  # 🛡️ GESTION DU PARE-FEU SYSTÈME & RÈGLES PAR DÉFAUT CHOMIAMOS
  # =========================================================================

  networking.firewall = {
    enable = config.chomiamos.firewall.enable;

    # Ports TCP autorisés par défaut pour le système
    allowedTCPPorts = [
      53317 # LocalSend (Partage de fichiers local)
      8080  # OpenWebUI (Interface web IA locale)
      8888  # SearXNG (Moteur de recherche méta privé)
    ];

    # Ports UDP autorisés par défaut pour le système
    allowedUDPPorts = [
      53317 # LocalSend (Découverte d'appareils réseau local)
    ];

    # Plages de ports TCP autorisées par défaut
    allowedTCPPortRanges = [
    ];

    # Plages de ports UDP autorisées par défaut
    allowedUDPPortRanges = [
    ];
  };
}
