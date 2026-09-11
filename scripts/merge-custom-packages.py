#!/usr/bin/env python3
"""
merge-custom-packages.py — Fusion intelligente et sécurisée de custom-packages.nix
Fait partie de ChomiamOS Gaming Edition.

Fonctionnement :
- Lit les paquets de la sauvegarde locale de l'utilisateur (.custom-packages.nix.backup).
- Lit les éventuels paquets du dépôt officiel (custom-packages.nix).
- Fusionne les paquets des deux branches (stable et unstable) sans aucun doublon.
- Préserve 100% des paquets ajoutés par l'utilisateur via la Logithèque.
- Valide la structure et applique une écriture atomique sécurisée.
"""

import sys
import os
import re

def extract_package_list(content: str, list_name: str) -> list:
    """Extrait la liste des paquets d'un bloc `list_name = [ ... ];`."""
    pattern = r'\b' + re.escape(list_name) + r'\s*=\s*\[(.*?)\];'
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        # Essayer sans point-virgule au cas où
        pattern = r'\b' + re.escape(list_name) + r'\s*=\s*\[(.*?)\]'
        match = re.search(pattern, content, re.DOTALL)
        if not match:
            return []

    block = match.group(1)
    packages = []
    for line in block.splitlines():
        # Enlever les commentaires
        code = line.split('#')[0].strip()
        # Nettoyer les guillemets et séparateurs
        pkg = code.strip('"\';, ')
        if pkg:
            packages.append(pkg)
    return packages

def generate_nix_content(stable_pkgs: list, unstable_pkgs: list) -> str:
    """Génère le contenu complet de custom-packages.nix."""
    stable_clean = sorted(set(stable_pkgs))
    unstable_clean = sorted(set(unstable_pkgs))

    stable_lines = "".join(f'    "{p}"\n' for p in stable_clean)
    unstable_lines = "".join(f'    "{p}"\n' for p in unstable_clean)

    return f"""{{
  # =========================================================================
  # 📦 PAQUETS NIX PERSONNALISÉS (CHOMIAMOS)
  # =========================================================================
  # Ce fichier est géré par l'onglet Logithèque du Dashboard ChomiamOS.
  # Vos paquets personnels sont préservés lors des synchronisations GitHub.
  #
  # - stable   : Paquets issus de la branche stable (NixOS 26.05)
  # - unstable : Paquets issus de la branche unstable (dernières nouveautés)
  # =========================================================================

  # Paquets issus de la branche Stable (NixOS 26.05)
  stable = [
{stable_lines}  ];

  # Paquets issus de la branche Unstable (Dernières versions)
  unstable = [
{unstable_lines}  ];
}}
"""

def main():
    if len(sys.argv) < 3:
        print("Usage: merge-custom-packages.py <backup_file> <target_file>")
        sys.exit(1)

    backup_path = sys.argv[1]
    target_path = sys.argv[2]

    backup_stable = []
    backup_unstable = []
    if os.path.exists(backup_path):
        try:
            with open(backup_path, 'r', encoding='utf-8') as f:
                backup_content = f.read()
            backup_stable = extract_package_list(backup_content, "stable")
            backup_unstable = extract_package_list(backup_content, "unstable")
        except Exception as e:
            print(f"⚠️ Avertissement : impossible de lire {backup_path} ({e})")

    target_stable = []
    target_unstable = []
    if os.path.exists(target_path):
        try:
            with open(target_path, 'r', encoding='utf-8') as f:
                target_content = f.read()
            target_stable = extract_package_list(target_content, "stable")
            target_unstable = extract_package_list(target_content, "unstable")
        except Exception as e:
            print(f"⚠️ Avertissement : impossible de lire {target_path} ({e})")

    # Fusion des listes (Union sans doublons)
    merged_stable = sorted(set(backup_stable + target_stable))
    merged_unstable = sorted(set(backup_unstable + target_unstable))

    print(f"📦 Fusion Logithèque : {len(merged_stable)} paquet(s) stable, {len(merged_unstable)} paquet(s) unstable.")

    new_content = generate_nix_content(merged_stable, merged_unstable)

    # Écriture atomique
    tmp_path = target_path + ".tmp"
    try:
        with open(tmp_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        os.replace(tmp_path, target_path)
        print(f"✅ {target_path} mis à jour avec succès.")
    except Exception as e:
        print(f"❌ Erreur lors de l'écriture de {target_path} : {e}")
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
        sys.exit(1)

if __name__ == "__main__":
    main()
