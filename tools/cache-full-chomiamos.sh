#!/usr/bin/env bash
# =============================================================================
# 🚀 ChomiamOS — Script Modulaire de Pré-Mise en Cache Cachix
# Cible : Cache binaire "chomiamos" (https://chomiamos.cachix.org)
# Permet de mettre en cache tous les choix multiples (KDE, COSMIC, Cinnamon,
# GNOME, DaVinci Resolve, Émulateurs, Slicers, Outils Créatifs, etc.)
# =============================================================================

set -euo pipefail

CACHE_NAME="chomiamos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

ensure_cachix() {
  if ! command -v cachix &>/dev/null; then
    echo -e "${YELLOW}📦 Cachix non trouvé dans le PATH, activation temporaire via nixpkgs...${NC}"
    export PATH="$(nix-build --no-out-link '<nixpkgs>' -A cachix)/bin:$PATH"
  fi
  echo -e "${CYAN}▶ Vérification de l'accès au cache Cachix '${CACHE_NAME}'...${NC}"
  cachix doctor >/dev/null 2>&1 || {
    echo -e "${RED}⚠️ Erreur d'authentification Cachix. Vérifiez ~/.config/cachix/cachix.dhall ou définissez CACHIX_AUTH_TOKEN.${NC}"
    exit 1
  }
  echo -e "${GREEN}✓ Authentification Cachix validée pour '${CACHE_NAME}'.${NC}"
}

build_and_push() {
  local target="$1"
  local desc="$2"

  echo ""
  echo -e "${BLUE}=================================================================${NC}"
  echo -e "${BOLD}🔨 [BUILD & CACHIX PUSH] ${desc}${NC}"
  echo -e "${CYAN}Cible : ${target}${NC}"
  echo -e "${BLUE}=================================================================${NC}"

  cachix watch-exec "$CACHE_NAME" -- nix build \
    "$target" \
    --accept-flake-config \
    --impure \
    --fallback \
    --print-build-logs

  echo -e "${GREEN}✓ Cible mise en cache avec succès : ${desc}${NC}"
}

build_davinci() {
  echo ""
  echo -e "${RED}=================================================================${NC}"
  echo -e "${BOLD}${RED}⚠️  ATTENTION : QUOTA DE STOCKAGE CACHIX (DAVINCI RESOLVE)${NC}"
  echo -e "${RED}=================================================================${NC}"
  echo -e "DaVinci Resolve est un logiciel propriétaire volumineux (~2.5 Go archive, > 5.5 Go décompressé)."
  echo -e "Si votre compte Cachix est un compte gratuit (limité à 5 Go), ce push va"
  echo -e "${BOLD}saturer immédiatement votre quota total de stockage Cachix${NC}."
  echo ""
  read -rp "Voulez-vous tout de même continuer le build et le push de DaVinci Resolve ? [o/N] " confirm
  if [[ "$confirm" =~ ^[oOyY]$ ]]; then
    build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.davinci.free" "DaVinci Resolve (Version Gratuite)"
  else
    echo -e "${YELLOW}Poussée de DaVinci Resolve annulée. Le cache conserve son quota libre.${NC}"
  fi
}

show_menu() {
  clear 2>/dev/null || true
  echo -e "${PURPLE}=================================================================${NC}"
  echo -e "${BOLD}🚀 ChomiamOS — Gestionnaire de Cache Binaire Cachix ($CACHE_NAME)${NC}"
  echo -e "${PURPLE}=================================================================${NC}"
  echo -e "Sélectionnez le composant ou la variante de bureau à mettre en cache :"
  echo ""
  echo -e "  ${CYAN}[1]${NC} 🖥️  Bureau KDE Plasma 6 (Toplevel système complet)"
  echo -e "  ${CYAN}[2]${NC} 🖥️  Bureau COSMIC Desktop 1.5+ (Toplevel système complet)"
  echo -e "  ${CYAN}[3]${NC} 🖥️  Bureau Cinnamon (Toplevel système complet)"
  echo -e "  ${CYAN}[4]${NC} 🖥️  Bureau GNOME (Toplevel système complet)"
  echo -e "  ${CYAN}[5]${NC} 🖥️  Les 4 Bureaux (KDE + COSMIC + Cinnamon + GNOME)"
  echo ""
  echo -e "  ${CYAN}[6]${NC} 🕹️  Pack Rétrogaming & Émulateurs (DuckStation, Eden, Dolphin, PCSX2...)"
  echo -e "  ${CYAN}[7]${NC} 🎨  Pack Création 3D & Vidéo (Blender, Godot, Kdenlive, OBS...)"
  echo -e "  ${CYAN}[8]${NC} 🌐  Pack Navigateurs Web (Chrome, Firefox, LibreWolf)"
  echo -e "  ${CYAN}[9]${NC} 🛠️  Pack Outils & Gaming (Dashboard, Oversteer, Steam, Lutris...)"
  echo -e "  ${CYAN}[10]${NC} 🎬  DaVinci Resolve (Version Gratuite - ⚠️ > 5 Go)"
  echo ""
  echo -e "  ${GREEN}[11]${NC} 🚀  Configuration 'Full' (Toutes options système activées)"
  echo -e "  ${GREEN}[12]${NC} 📦  Pack Global All-in-One (Tous les paquets système hors DaVinci)"
  echo ""
  echo -e "  ${RED}[0]${NC}  ❌ Quitter"
  echo -e "${PURPLE}=================================================================${NC}"
  echo ""
  read -rp "Votre choix [0-12] : " choice

  case "$choice" in
    1) build_and_push "$FLAKE_DIR#nixosConfigurations.kde.config.system.build.toplevel" "ChomiamOS - KDE Plasma 6" ;;
    2) build_and_push "$FLAKE_DIR#nixosConfigurations.cosmic.config.system.build.toplevel" "ChomiamOS - COSMIC Desktop" ;;
    3) build_and_push "$FLAKE_DIR#nixosConfigurations.cinnamon.config.system.build.toplevel" "ChomiamOS - Cinnamon Desktop" ;;
    4) build_and_push "$FLAKE_DIR#nixosConfigurations.gnome.config.system.build.toplevel" "ChomiamOS - GNOME Desktop" ;;
    5)
      build_and_push "$FLAKE_DIR#nixosConfigurations.kde.config.system.build.toplevel" "ChomiamOS - KDE Plasma 6"
      build_and_push "$FLAKE_DIR#nixosConfigurations.cosmic.config.system.build.toplevel" "ChomiamOS - COSMIC Desktop"
      build_and_push "$FLAKE_DIR#nixosConfigurations.cinnamon.config.system.build.toplevel" "ChomiamOS - Cinnamon Desktop"
      build_and_push "$FLAKE_DIR#nixosConfigurations.gnome.config.system.build.toplevel" "ChomiamOS - GNOME Desktop"
      ;;
    6) build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.allEmulators" "Pack Émulateurs" ;;
    7) build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.allCreation" "Pack Création 3D & Vidéo" ;;
    8) build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.allBrowsers" "Pack Navigateurs" ;;
    9) build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.allSystemTools" "Pack Outils Système & Gaming" ;;
    10) build_davinci ;;
    11) build_and_push "$FLAKE_DIR#nixosConfigurations.full.config.system.build.toplevel" "Configuration Complète ChomiamOS Full" ;;
    12) build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.allPackages" "Pack Global All-in-One (Sans DaVinci)" ;;
    0) echo "Au revoir !"; exit 0 ;;
    *) echo -e "${RED}Choix invalide.${NC}"; exit 1 ;;
  esac
}

# Mode ligne de commande
if [ $# -gt 0 ]; then
  ensure_cachix
  case "$1" in
    --kde) build_and_push "$FLAKE_DIR#nixosConfigurations.kde.config.system.build.toplevel" "ChomiamOS - KDE Plasma 6" ;;
    --cosmic) build_and_push "$FLAKE_DIR#nixosConfigurations.cosmic.config.system.build.toplevel" "ChomiamOS - COSMIC Desktop" ;;
    --cinnamon) build_and_push "$FLAKE_DIR#nixosConfigurations.cinnamon.config.system.build.toplevel" "ChomiamOS - Cinnamon Desktop" ;;
    --gnome) build_and_push "$FLAKE_DIR#nixosConfigurations.gnome.config.system.build.toplevel" "ChomiamOS - GNOME Desktop" ;;
    --all-desktops)
      build_and_push "$FLAKE_DIR#nixosConfigurations.kde.config.system.build.toplevel" "ChomiamOS - KDE Plasma 6"
      build_and_push "$FLAKE_DIR#nixosConfigurations.cosmic.config.system.build.toplevel" "ChomiamOS - COSMIC Desktop"
      build_and_push "$FLAKE_DIR#nixosConfigurations.cinnamon.config.system.build.toplevel" "ChomiamOS - Cinnamon Desktop"
      build_and_push "$FLAKE_DIR#nixosConfigurations.gnome.config.system.build.toplevel" "ChomiamOS - GNOME Desktop"
      ;;
    --emulators) build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.allEmulators" "Pack Émulateurs" ;;
    --creation) build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.allCreation" "Pack Création 3D & Vidéo" ;;
    --browsers) build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.allBrowsers" "Pack Navigateurs" ;;
    --tools) build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.allSystemTools" "Pack Outils Système & Gaming" ;;
    --davinci) build_davinci ;;
    --full) build_and_push "$FLAKE_DIR#nixosConfigurations.full.config.system.build.toplevel" "Configuration Complète ChomiamOS Full" ;;
    --all) build_and_push "$FLAKE_DIR#packages.x86_64-linux.cache-matrix.allPackages" "Pack Global All-in-One (Sans DaVinci)" ;;
    --help|-h)
      echo "Usage: $0 [OPTION]"
      echo "Options:"
      echo "  --kde            Mettre en cache le bureau KDE Plasma 6"
      echo "  --cosmic         Mettre en cache le bureau COSMIC Desktop"
      echo "  --cinnamon       Mettre en cache le bureau Cinnamon"
      echo "  --gnome          Mettre en cache le bureau GNOME"
      echo "  --all-desktops   Mettre en cache les 4 bureaux"
      echo "  --emulators      Mettre en cache la suite Émulateurs"
      echo "  --creation       Mettre en cache les outils 3D & Vidéo"
      echo "  --browsers       Mettre en cache les navigateurs"
      echo "  --tools          Mettre en cache les outils système & gaming"
      echo "  --davinci        Mettre en cache DaVinci Resolve (avec avertissement)"
      echo "  --full           Mettre en cache la configuration système 'full'"
      echo "  --all            Mettre en cache le pack complet hors DaVinci"
      exit 0
      ;;
    *)
      echo -e "${RED}Option inconnue: $1${NC}. Utilisez --help pour la liste des options."
      exit 1
      ;;
  esac
  exit 0
fi

# Mode interactif
ensure_cachix
show_menu
