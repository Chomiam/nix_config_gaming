"""
update-es-de - Gestionnaire de vérification et mise à jour
de l'AppImage ES-DE pour ChomiamOS.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import urllib.request

GITLAB_API_URL = (
    "https://gitlab.com/api/v4/projects/"
    "es-de%2Femulationstation-de/releases"
)
DEFAULT_JSON_PATH = "/etc/nixos/pkgs/es-de/version.json"


def clean_version(v: str) -> str:
    return re.sub(r"^v", "", v.strip())


def get_current_info(json_path: str) -> dict:
    if not os.path.exists(json_path):
        return {"version": "0.0.0", "url": "", "hash": ""}
    try:
        with open(json_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"⚠️ Impossible de lire {json_path}: {e}", file=sys.stderr)
        return {"version": "0.0.0", "url": "", "hash": ""}


def fetch_latest_release() -> tuple[str, str]:
    """Récupère la dernière version et l'URL de l'AppImage x64."""
    req = urllib.request.Request(
        GITLAB_API_URL,
        headers={"User-Agent": "ChomiamOS-ESDE-Updater/1.0"},
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        data = json.loads(resp.read().decode())

    for release in data:
        tag = clean_version(release.get("tag_name", ""))
        links = release.get("assets", {}).get("links", [])
        for link in links:
            name = link.get("name", "")
            # On cible l'AppImage x86_64 standard (hors SteamDeck ou arm64)
            is_match = (
                name == "ES-DE_x64.AppImage"
                or (
                    name.endswith(".AppImage")
                    and "x64" in name
                    and "SteamDeck" not in name
                )
            )
            if is_match:
                url = link.get("direct_asset_url") or link.get("url")
                return tag, url

    raise RuntimeError(
        "Aucune AppImage x64 trouvée dans les dernières releases GitLab"
    )


def compute_nix_hash(url: str) -> str:
    """Télécharge et calcule le hash SRI compatible Nix."""
    print(f"📦 Calcul de l'empreinte cryptographique Nix pour {url}...")
    res = subprocess.run(
        ["nix-prefetch-url", url],
        capture_output=True,
        text=True,
        check=True,
    )
    nix32_hash = res.stdout.strip()
    sri_res = subprocess.run(
        [
            "nix",
            "hash",
            "convert",
            "--to",
            "sri",
            "--hash-algo",
            "sha256",
            nix32_hash,
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    return sri_res.stdout.strip()


def parse_version_tuple(v: str) -> tuple[int, ...]:
    clean = clean_version(v)
    parts = []
    for p in re.split(r"[-.+]", clean):
        try:
            parts.append(int(p))
        except ValueError:
            break
    return tuple(parts)


def main():
    parser = argparse.ArgumentParser(
        description="Vérification et mise à jour d'ES-DE pour ChomiamOS"
    )
    parser.add_argument(
        "--json-path",
        default=DEFAULT_JSON_PATH,
        help="Chemin vers version.json",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Vérifie seulement si une màj est disponible",
    )
    parser.add_argument(
        "--update",
        action="store_true",
        help="Met à jour version.json avec la dernière version",
    )
    parser.add_argument(
        "--switch",
        action="store_true",
        help="Lance nh os switch après mise à jour",
    )
    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Sortie minimale",
    )
    args = parser.parse_args()

    current = get_current_info(args.json_path)
    current_ver = clean_version(current.get("version", "0.0.0"))

    try:
        latest_ver, latest_url = fetch_latest_release()
    except Exception as e:
        if not args.quiet:
            print(
                f"❌ Erreur lors de la vérification GitLab: {e}",
                file=sys.stderr,
            )
        sys.exit(1)

    curr_tuple = parse_version_tuple(current_ver)
    latest_tuple = parse_version_tuple(latest_ver)
    update_available = latest_tuple > curr_tuple

    if args.check:
        if update_available:
            if not args.quiet:
                print(
                    f"🔔 Mise à jour disponible pour ES-DE : v{latest_ver} "
                    f"(version installée : v{current_ver})"
                )
            sys.exit(10)
        else:
            if not args.quiet:
                print(f"✅ ES-DE est à jour (version v{current_ver})")
            sys.exit(0)

    if not update_available and not args.update:
        if not args.quiet:
            print(
                "✅ ES-DE est déjà sur la version la plus récente : "
                f"v{current_ver}"
            )
        sys.exit(0)

    # Procédure de mise à jour
    print(f"🚀 Mise à jour d'ES-DE : v{current_ver} -> v{latest_ver}")
    try:
        new_hash = compute_nix_hash(latest_url)
        new_data = {
            "version": latest_ver,
            "url": latest_url,
            "hash": new_hash,
        }
        with open(args.json_path, "w", encoding="utf-8") as f:
            json.dump(new_data, f, indent=2)
            f.write("\n")
        print(
            f"✅ Fichier {args.json_path} mis à jour avec succès "
            f"(hash: {new_hash})"
        )
    except Exception as e:
        print(f"❌ Échec de la mise à jour : {e}", file=sys.stderr)
        sys.exit(2)

    if args.switch:
        print("🔄 Application des changements via nh os switch...")
        subprocess.run(["nh", "os", "switch"], check=False)


if __name__ == "__main__":
    main()
