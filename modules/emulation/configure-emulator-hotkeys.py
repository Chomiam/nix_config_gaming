#!/usr/bin/env python3
"""
ChomiamOS - Script déclaratif d'harmonisation des raccourcis et plein écran des émulateurs.
S'exécute lors de l'activation système pour garantir que chaque émulateur dispose de configurations
valides, sans erreurs de syntaxe, et multi-manettes (SDL-0 à SDL-3).
"""

import glob
import os
import struct
import sys

def update_retroarch(retroarch_cfg):
    if not os.path.exists(retroarch_cfg):
        return
    settings = {
        "video_fullscreen": '"true"',
        "input_joypad_driver": '"sdl2"',
        "input_enable_hotkey_btn": '"4"',
        "input_exit_emulator_btn": '"6"',
        "input_menu_toggle_btn": '"2"',
        "input_menu_toggle_gamepad_combo": '"2"',
        "input_save_state_btn": '"10"',
        "input_load_state_btn": '"9"',
        "input_state_slot_increase_btn": '"14"',
        "input_state_slot_decrease_btn": '"13"',
        "input_reset_btn": '"1"',
        "input_pause_toggle_btn": '"0"',
        "input_hold_fast_forward_btn": '"10"',
        "input_toggle_fast_forward_btn": '"10"',
    }
    with open(retroarch_cfg, "r") as f:
        lines = f.readlines()
    new_lines = []
    found_keys = set()
    for line in lines:
        updated = False
        for k, v in settings.items():
            if line.startswith(f"{k} =") or line.startswith(f"{k}="):
                new_lines.append(f"{k} = {v}\n")
                found_keys.add(k)
                updated = True
                break
        if not updated:
            new_lines.append(line)
    for k, v in settings.items():
        if k not in found_keys:
            new_lines.append(f"{k} = {v}\n")
    with open(retroarch_cfg, "w") as f:
        f.writelines(new_lines)


def update_ini_multi_lines(filepath, section_name, hotkeys_dict, section_overrides=None):
    if not os.path.exists(filepath):
        return
    with open(filepath, "r") as f:
        lines = f.readlines()
    
    new_lines = []
    in_cur_section = None
    keys_to_replace = set(hotkeys_dict.keys())
    
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            in_cur_section = stripped[1:-1]
            new_lines.append(line)
            continue
        
        if in_cur_section == section_name:
            is_key_line = False
            for k in keys_to_replace:
                if line.startswith(f"{k} =") or line.startswith(f"{k}="):
                    is_key_line = True
                    break
            if is_key_line:
                continue
        elif section_overrides and in_cur_section in section_overrides:
            sec_settings = section_overrides[in_cur_section]
            matched = False
            for k, v in sec_settings.items():
                if line.startswith(f"{k} =") or line.startswith(f"{k}="):
                    new_lines.append(f"{k} = {v}\n")
                    matched = True
                    break
            if matched:
                continue
        new_lines.append(line)
    
    # Trouver l'index de la section
    target_idx = -1
    for i, line in enumerate(new_lines):
        if line.strip() == f"[{section_name}]":
            target_idx = i
            break
    
    if target_idx == -1:
        new_lines.append(f"\n[{section_name}]\n")
        target_idx = len(new_lines) - 1
    
    # Insérer les lignes multi-valeurs propres
    insert_lines = []
    for k, values in hotkeys_dict.items():
        for val in values:
            insert_lines.append(f"{k} = {val}\n")
    
    new_lines[target_idx+1:target_idx+1] = insert_lines
    
    with open(filepath, "w") as f:
        f.writelines(new_lines)


def update_simple_ini_keys(filepath, section_name, key_values):
    if not os.path.exists(filepath):
        return
    with open(filepath, "r") as f:
        lines = f.readlines()
    new_lines = []
    in_cur_section = None
    found_keys = set()
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            in_cur_section = stripped[1:-1]
            new_lines.append(line)
            continue
        if in_cur_section == section_name:
            updated = False
            for k, v in key_values.items():
                if line.startswith(f"{k} =") or line.startswith(f"{k}="):
                    new_lines.append(f"{k} = {v}\n")
                    found_keys.add(k)
                    updated = True
                    break
            if not updated:
                new_lines.append(line)
        else:
            new_lines.append(line)
    
    target_idx = -1
    for i, line in enumerate(new_lines):
        if line.strip() == f"[{section_name}]":
            target_idx = i
            break
    
    if target_idx == -1:
        new_lines.append(f"\n[{section_name}]\n")
        target_idx = len(new_lines) - 1
    
    missing = []
    for k, v in key_values.items():
        if k not in found_keys:
            missing.append(f"{k} = {v}\n")
    new_lines[target_idx+1:target_idx+1] = missing
    with open(filepath, "w") as f:
        f.writelines(new_lines)


def main():
    if len(sys.argv) < 2:
        sys.exit(1)
    home_dir = sys.argv[1]
    
    # 1. RetroArch
    retroarch_cfg = os.path.join(home_dir, ".config/retroarch/retroarch.cfg")
    update_retroarch(retroarch_cfg)
    
    # 2. DuckStation (PS1)
    duck_cfg = os.path.join(home_dir, ".local/share/duckstation/settings.ini")
    duck_hotkeys = {
        "PowerOff": [
            "Keyboard/Escape",
            "SDL-0/Back & SDL-0/Start",
            "SDL-0/Guide & SDL-0/Start",
            "SDL-1/Back & SDL-1/Start",
            "SDL-1/Guide & SDL-1/Start",
            "SDL-2/Back & SDL-2/Start",
            "SDL-3/Back & SDL-3/Start",
        ],
        "OpenPauseMenu": [
            "Keyboard/Escape",
            "SDL-0/Guide",
            "SDL-0/LeftStick & SDL-0/RightStick",
            "SDL-0/Back & SDL-0/X",
            "SDL-0/Back & SDL-0/Y",
            "SDL-1/Guide",
            "SDL-1/LeftStick & SDL-1/RightStick",
            "SDL-1/Back & SDL-1/X",
            "SDL-1/Back & SDL-1/Y",
            "SDL-2/Guide",
            "SDL-3/Guide",
        ],
        "SaveSelectedSaveState": [
            "Keyboard/F2",
            "SDL-0/Back & SDL-0/RightShoulder",
            "SDL-0/Guide & SDL-0/RightShoulder",
            "SDL-1/Back & SDL-1/RightShoulder",
            "SDL-2/Back & SDL-2/RightShoulder",
            "SDL-3/Back & SDL-3/RightShoulder",
        ],
        "LoadSelectedSaveState": [
            "Keyboard/F1",
            "SDL-0/Back & SDL-0/LeftShoulder",
            "SDL-0/Guide & SDL-0/LeftShoulder",
            "SDL-1/Back & SDL-1/LeftShoulder",
            "SDL-2/Back & SDL-2/LeftShoulder",
            "SDL-3/Back & SDL-3/LeftShoulder",
        ],
        "SelectNextSaveStateSlot": [
            "Keyboard/F4",
            "SDL-0/Back & SDL-0/DPadRight",
            "SDL-1/Back & SDL-1/DPadRight",
            "SDL-2/Back & SDL-2/DPadRight",
            "SDL-3/Back & SDL-3/DPadRight",
        ],
        "SelectPreviousSaveStateSlot": [
            "Keyboard/F3",
            "SDL-0/Back & SDL-0/DPadLeft",
            "SDL-1/Back & SDL-1/DPadLeft",
            "SDL-2/Back & SDL-2/DPadLeft",
            "SDL-3/Back & SDL-3/DPadLeft",
        ],
        "FastForward": [
            "Keyboard/Tab",
            "SDL-0/Back & SDL-0/+RightTrigger",
            "SDL-1/Back & SDL-1/+RightTrigger",
        ],
        "TogglePause": [
            "Keyboard/Space",
            "SDL-0/Back & SDL-0/A",
            "SDL-1/Back & SDL-1/A",
        ],
    }
    update_ini_multi_lines(duck_cfg, "Hotkeys", duck_hotkeys, {"Main": {"ConfirmPowerOff": "false", "StartFullscreen": "true"}})
    
    # 3. PCSX2 (PS2)
    pcsx2_cfg = os.path.join(home_dir, ".config/PCSX2/inis/PCSX2.ini")
    pcsx2_hotkeys = {
        "ShutdownVM": [
            "Keyboard/Escape",
            "SDL-0/Back & SDL-0/Start",
            "SDL-0/Guide & SDL-0/Start",
            "SDL-1/Back & SDL-1/Start",
            "SDL-1/Guide & SDL-1/Start",
            "SDL-2/Back & SDL-2/Start",
            "SDL-3/Back & SDL-3/Start",
        ],
        "OpenPauseMenu": [
            "Keyboard/Escape",
            "SDL-0/Guide",
            "SDL-0/LeftStick & SDL-0/RightStick",
            "SDL-0/Back & SDL-0/FaceWest",
            "SDL-0/Back & SDL-0/FaceNorth",
            "SDL-1/Guide",
            "SDL-1/LeftStick & SDL-1/RightStick",
            "SDL-1/Back & SDL-1/FaceWest",
            "SDL-1/Back & SDL-1/FaceNorth",
            "SDL-2/Guide",
            "SDL-3/Guide",
        ],
        "SaveStateToSlot": [
            "Keyboard/F1",
            "SDL-0/Back & SDL-0/RightShoulder",
            "SDL-0/Guide & SDL-0/RightShoulder",
            "SDL-1/Back & SDL-1/RightShoulder",
            "SDL-2/Back & SDL-2/RightShoulder",
            "SDL-3/Back & SDL-3/RightShoulder",
        ],
        "LoadStateFromSlot": [
            "Keyboard/F3",
            "SDL-0/Back & SDL-0/LeftShoulder",
            "SDL-0/Guide & SDL-0/LeftShoulder",
            "SDL-1/Back & SDL-1/LeftShoulder",
            "SDL-2/Back & SDL-2/LeftShoulder",
            "SDL-3/Back & SDL-3/LeftShoulder",
        ],
        "NextSaveStateSlot": [
            "Keyboard/F2",
            "SDL-0/Back & SDL-0/DPadRight",
            "SDL-1/Back & SDL-1/DPadRight",
            "SDL-2/Back & SDL-2/DPadRight",
            "SDL-3/Back & SDL-3/DPadRight",
        ],
        "PreviousSaveStateSlot": [
            "Keyboard/Shift & Keyboard/F2",
            "SDL-0/Back & SDL-0/DPadLeft",
            "SDL-1/Back & SDL-1/DPadLeft",
            "SDL-2/Back & SDL-2/DPadLeft",
            "SDL-3/Back & SDL-3/DPadLeft",
        ],
        "TogglePause": [
            "Keyboard/Space",
            "SDL-0/Back & SDL-0/FaceSouth",
            "SDL-1/Back & SDL-1/FaceSouth",
        ],
        "ToggleTurbo": [
            "Keyboard/Tab",
            "SDL-0/Back & SDL-0/+RightTrigger",
            "SDL-1/Back & SDL-1/+RightTrigger",
        ],
    }
    update_ini_multi_lines(pcsx2_cfg, "Hotkeys", pcsx2_hotkeys, {"UI": {"ConfirmShutdown": "false", "StartFullscreen": "true"}})
    
    # 4. Dolphin (GameCube & Wii)
    dolphin_cfg = os.path.join(home_dir, ".config/dolphin-emu/Dolphin.ini")
    update_simple_ini_keys(dolphin_cfg, "General", {"ConfirmOnStop": "False"})
    update_simple_ini_keys(dolphin_cfg, "Display", {"Fullscreen": "True", "RenderToMain": "True"})
    
    # 5. PPSSPP (PSP)
    ppsspp_cfg = os.path.join(home_dir, ".config/ppsspp/PSP/SYSTEM/ppsspp.ini")
    update_simple_ini_keys(ppsspp_cfg, "General", {"ConfirmOnQuit": "False"})
    
    # 6. Eden (Switch)
    eden_cfg = os.path.join(home_dir, ".config/eden/qt-config.ini")
    update_simple_ini_keys(eden_cfg, "UI", {"fullscreen": "true", "confirm_stop": "false"})

    # 7. Raccourcis Steam (Empêcher l'injection de l'overlay et LD_PRELOAD sur ES-DE sous Gamescope)
    update_steam_shortcuts(home_dir)


def parse_vdf(b, pos=0):
    res = []
    while pos < len(b):
        t = b[pos]
        pos += 1
        if t == 8:
            break
        k_end = b.find(b"\x00", pos)
        key = b[pos:k_end].decode("utf-8", "ignore")
        pos = k_end + 1
        if t == 0:
            val, pos = parse_vdf(b, pos)
            res.append([t, key, val])
        elif t == 1:
            v_end = b.find(b"\x00", pos)
            val = b[pos:v_end].decode("utf-8", "ignore")
            pos = v_end + 1
            res.append([t, key, val])
        elif t == 2:
            val = struct.unpack("<i", b[pos:pos+4])[0]
            pos += 4
            res.append([t, key, val])
        else:
            raise ValueError(f"Unknown type {t} at {pos}")
    return res, pos


def serialize_vdf(items):
    out = bytearray()
    for t, key, val in items:
        out.append(t)
        out.extend(key.encode("utf-8") + b"\x00")
        if t == 0:
            out.extend(serialize_vdf(val))
            out.append(8)
        elif t == 1:
            out.extend(val.encode("utf-8") + b"\x00")
        elif t == 2:
            out.extend(struct.pack("<i", val))
    return bytes(out)


def update_steam_shortcuts(home_dir):
    pattern = os.path.join(home_dir, ".local/share/Steam/userdata/*/config/shortcuts.vdf")
    paths = glob.glob(pattern)
    for vdf_path in paths:
        try:
            with open(vdf_path, "rb") as f:
                orig = f.read()
            tree, _ = parse_vdf(orig)
            modified = False
            for top in tree:
                if top[1] == "shortcuts":
                    for entry in top[2]:
                        subitems = entry[2]
                        app_name = None
                        for item in subitems:
                            if item[1] == "AppName":
                                app_name = item[2]
                        if app_name == "ES-DE":
                            for item in subitems:
                                if item[1] == "Exe":
                                    local_es_de = f'"{home_dir}/.local/bin/es-de"'
                                    if item[2] != local_es_de:
                                        item[2] = local_es_de
                                        modified = True
                                elif item[1] == "LaunchOptions":
                                    if item[2] != 'LD_PRELOAD="" %command%':
                                        item[2] = 'LD_PRELOAD="" %command%'
                                        modified = True
                                elif item[1] == "AllowOverlay":
                                    if item[2] != 0:
                                        item[2] = 0
                                        modified = True
            if modified:
                new_data = serialize_vdf(tree) + b"\x08"
                with open(vdf_path, "wb") as f:
                    f.write(new_data)
                print(f"✅ Raccourci Steam ES-DE optimisé dans {vdf_path}")
        except Exception as e:
            print(f"⚠️ Impossible de mettre à jour {vdf_path} : {e}")


if __name__ == "__main__":
    main()
