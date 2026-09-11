{ config, lib, pkgs, inputs, ... }:

let
  wallpapersPkg = inputs.chomiamos-wallpapers.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  # =========================================================================
  # 🎨 FONDS D'ÉCRAN OFFICIELS CHOMIAMOS
  # Rendus disponibles nativement pour tous les environnements de bureau :
  # - GNOME & Cinnamon : XML dans share/gnome-background-properties
  # - KDE Plasma : Paquets structurés dans share/wallpapers
  # - COSMIC Desktop : Images dans share/backgrounds/cosmic
  # - Chemin universel : /run/current-system/sw/share/backgrounds/chomiamos
  #                     et /etc/backgrounds/chomiamos
  # =========================================================================

  environment.systemPackages = [ wallpapersPkg ];

  # Déploiement dans /etc/backgrounds/chomiamos pour compatibilité descendante
  # et accès statique rapide pour tous les gestionnaires de connexion / scripts
  environment.etc."backgrounds/chomiamos".source = "${wallpapersPkg}/share/backgrounds/chomiamos";
}
