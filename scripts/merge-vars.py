#!/usr/bin/env python3
"""
merge-vars.py — Fusion intelligente et sécurisée de vars-defaults.nix dans vars.nix
Fait partie de ChomiamOS Gaming Edition.

Fonctionnement :
- Lit les variables de référence dans vars-defaults.nix (schéma officiel).
- Compare avec le vars.nix local de la machine.
- N'ÉCRASE JAMAIS les variables définies par l'utilisateur (username, fullName, desktopEnv, gpuDriver, etc.).
- Injecte UNIQUEMENT les variables ou sous-blocs absents avec leur valeur par défaut et leurs commentaires.
- Valide la syntaxe Nix avant toute écriture.
- Écriture atomique sécurisée.
"""

import sys
import os
import re
import shutil
import subprocess

# Couleurs ANSI pour affichage terminal
RESET = "\033[0m"
BOLD = "\033[1m"
GREEN = "\033[1;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[1;34m"
MAGENTA = "\033[1;35m"
CYAN = "\033[1;36m"
RED = "\033[1;31m"

def find_matching_brace(text, open_idx):
    """Trouve l'indice de l'accolade fermante '}' correspondant à '{' à open_idx."""
    depth = 0
    in_str = False
    escape = False
    for idx in range(open_idx, len(text)):
        ch = text[idx]
        if escape:
            escape = False
            continue
        if ch == '\\':
            escape = True
            continue
        if ch == '"':
            in_str = not in_str
            continue
        if not in_str:
            if ch == '{':
                depth += 1
            elif ch == '}':
                depth -= 1
                if depth == 0:
                    return idx
    return -1

def extract_items(text):
    """
    Extrait les assignations clé = valeur à l'intérieur d'un bloc d'attributs Nix { ... }.
    Retourne un dict: key -> { 'key', 'comment', 'full_text', 'is_block', 'block_content' }
    """
    text_content = text.strip()
    if text_content.startswith('{'):
        text_content = text_content[1:]
    if text_content.endswith('}'):
        text_content = text_content[:-1]

    items = {}
    lines = text_content.splitlines(keepends=True)
    i = 0
    current_comment = []

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if not stripped:
            if current_comment:
                current_comment.append(line)
            i += 1
            continue

        if stripped.startswith('#'):
            current_comment.append(line)
            i += 1
            continue

        m = re.match(r'^([a-zA-Z0-9_-]+)\s*=\s*(.*)', stripped)
        if m:
            key = m.group(1)
            comment_str = "".join(current_comment)
            current_comment = []

            accum = [line]
            brace_count = line.count('{') - line.count('}')
            paren_count = line.count('(') - line.count(')')
            bracket_count = line.count('[') - line.count(']')

            def ends_statement(l):
                s = l.strip()
                return s.endswith(';')

            if not (brace_count == 0 and bracket_count == 0 and paren_count == 0 and ends_statement(line)):
                i += 1
                while i < len(lines):
                    l = lines[i]
                    accum.append(l)
                    brace_count += l.count('{') - l.count('}')
                    bracket_count += l.count('[') - l.count(']')
                    paren_count += l.count('(') - l.count(')')
                    if brace_count == 0 and bracket_count == 0 and paren_count == 0 and ends_statement(l):
                        break
                    i += 1

            full_item = "".join(accum)
            is_block = '{' in full_item and '}' in full_item
            block_content = ""
            if is_block:
                first_b = full_item.find('{')
                last_b = find_matching_brace(full_item, first_b)
                if first_b != -1 and last_b != -1 and last_b > first_b:
                    block_content = full_item[first_b+1:last_b]

            items[key] = {
                'key': key,
                'comment': comment_str,
                'full_text': full_item,
                'is_block': is_block,
                'block_content': block_content
            }
        else:
            current_comment = []
        i += 1

    return items

def insert_missing_in_block(block_text, def_items, user_items, indent=2):
    """
    Parcourt récursivement les clés de def_items.
    Si une clé manque dans user_items, elle est injectée dans block_text.
    Si la clé existe et est un sous-bloc (ex: gaming = { ... };), la recherche récursive s'applique aux sous-clés.
    """
    added = []
    current_block_text = block_text

    open_brace_idx = current_block_text.find('{')
    if open_brace_idx == -1:
        return current_block_text, added

    close_brace_idx = find_matching_brace(current_block_text, open_brace_idx)
    if close_brace_idx == -1:
        return current_block_text, added

    prefix = current_block_text[:open_brace_idx+1]
    body = current_block_text[open_brace_idx+1:close_brace_idx]
    suffix = current_block_text[close_brace_idx:]

    for key, dinfo in def_items.items():
        if key not in user_items:
            chunk = ""
            ind = " " * indent
            if dinfo['comment'].strip():
                chunk += "\n" + ind + dinfo['comment'].strip().replace("\n", "\n" + ind) + "\n"
            else:
                chunk += "\n"
            chunk += ind + dinfo['full_text'].strip().replace("\n", "\n" + ind) + "\n"
            body = body.rstrip() + chunk
            added.append(key)
        else:
            uinfo = user_items[key]
            if dinfo['is_block'] and uinfo['is_block']:
                sub_def = extract_items(dinfo['block_content'])
                sub_user = extract_items(uinfo['block_content'])
                m = re.search(rf'(\b{re.escape(key)}\s*=\s*)', body)
                if m:
                    key_idx = m.end()
                    sub_open = body.find('{', key_idx - 1)
                    if sub_open != -1:
                        sub_close = find_matching_brace(body, sub_open)
                        if sub_close != -1:
                            sub_full = body[m.start():sub_close+1]
                            new_sub, sub_added = insert_missing_in_block(
                                sub_full, sub_def, sub_user, indent=indent+2
                            )
                            if sub_added:
                                body = body[:m.start()] + new_sub + body[sub_close+1:]
                                for sa in sub_added:
                                    added.append(f"{key}.{sa}")

    return prefix + body + "\n" + (" " * max(0, indent - 2)) + suffix, added

def merge_vars(defaults_path, user_path):
    if not os.path.exists(defaults_path):
        print(f"{YELLOW}⚠️ Fichier de référence {defaults_path} introuvable. Fusion ignorée.{RESET}")
        return 0

    if not os.path.exists(user_path):
        print(f"{BLUE}ℹ️ {user_path} absent. Initialisation depuis {defaults_path}...{RESET}")
        shutil.copyfile(defaults_path, user_path)
        print(f"{GREEN}✅ {user_path} créé avec succès.{RESET}")
        return 0

    with open(defaults_path, 'r', encoding='utf-8') as f:
        defaults_text = f.read()

    with open(user_path, 'r', encoding='utf-8') as f:
        user_text = f.read()

    def_items = extract_items(defaults_text)
    user_items = extract_items(user_text)

    merged_text, added_keys = insert_missing_in_block(user_text, def_items, user_items, indent=2)

    if not added_keys:
        print(f"{GREEN}✅ Toutes les variables système ({len(def_items)}) sont déjà présentes dans {os.path.basename(user_path)}.{RESET}")
        return 0

    print(f"{CYAN}✨ Fusion détectée : {len(added_keys)} nouvelle(s) variable(s) ou option(s) à ajouter :{RESET}")
    for k in added_keys:
        print(f"   {GREEN}+ {k}{RESET}")

    # Validation de la syntaxe Nix
    tmp_path = user_path + ".merge.tmp"
    with open(tmp_path, 'w', encoding='utf-8') as f:
        f.write(merged_text)

    # Test avec nix-instantiate
    test_proc = subprocess.run(
        ["nix-instantiate", "--parse", tmp_path],
        capture_output=True,
        text=True
    )
    if test_proc.returncode != 0:
        print(f"{RED}❌ Erreur de syntaxe Nix détectée lors de la fusion ! Abandon pour sécurité.{RESET}")
        print(test_proc.stderr)
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
        return 1

    # Remplacement atomique
    os.replace(tmp_path, user_path)
    print(f"{GREEN}🛡️ {os.path.basename(user_path)} mis à jour avec succès (vos paramètres existants ont été préservés).{RESET}\n")
    return 0

if __name__ == "__main__":
    def_file = sys.argv[1] if len(sys.argv) > 1 else "/etc/nixos/vars-defaults.nix"
    usr_file = sys.argv[2] if len(sys.argv) > 2 else "/etc/nixos/vars.nix"
    sys.exit(merge_vars(def_file, usr_file))
