#!/usr/bin/env python3
"""
ChomiamOS - Démon Universel de Raccourcis Manette pour l'Émulation
Fournit des raccourcis standardisés (Arrêt, Sauvegarde, Chargement, Slots, Menu)
compatibles avec TOUTES les manettes (Xbox, PlayStation, Switch Pro, 8BitDo, génériques)
pour l'ensemble des émulateurs autonomes et RetroArch.
"""

import os
import sys
import time
import signal
import asyncio
import subprocess
from evdev import InputDevice, UInput, ecodes, list_devices

# Profils de touches par émulateur pour l'injection clavier
EMULATOR_PROFILES = {
    "pcsx2-qt": {
        "save": [ecodes.KEY_F1],
        "load": [ecodes.KEY_F3],
        "next_slot": [ecodes.KEY_F2],
        "prev_slot": [ecodes.KEY_LEFTSHIFT, ecodes.KEY_F2],
        "menu": [ecodes.KEY_ESC],
        "turbo": [ecodes.KEY_TAB],
    },
    "pcsx2": {
        "save": [ecodes.KEY_F1],
        "load": [ecodes.KEY_F3],
        "next_slot": [ecodes.KEY_F2],
        "prev_slot": [ecodes.KEY_LEFTSHIFT, ecodes.KEY_F2],
        "menu": [ecodes.KEY_ESC],
        "turbo": [ecodes.KEY_TAB],
    },
    "duckstation-qt": {
        "save": [ecodes.KEY_F2],
        "load": [ecodes.KEY_F1],
        "next_slot": [ecodes.KEY_F4],
        "prev_slot": [ecodes.KEY_F3],
        "menu": [ecodes.KEY_ESC],
        "turbo": [ecodes.KEY_TAB],
    },
    "duckstation": {
        "save": [ecodes.KEY_F2],
        "load": [ecodes.KEY_F1],
        "next_slot": [ecodes.KEY_F4],
        "prev_slot": [ecodes.KEY_F3],
        "menu": [ecodes.KEY_ESC],
        "turbo": [ecodes.KEY_TAB],
    },
    "dolphin-emu": {
        "save": [ecodes.KEY_F1],
        "load": [ecodes.KEY_F8],
        "next_slot": [ecodes.KEY_F3],
        "prev_slot": [ecodes.KEY_F2],
        "menu": [ecodes.KEY_ESC],
        "turbo": [ecodes.KEY_TAB],
    },
    "dolphin": {
        "save": [ecodes.KEY_F1],
        "load": [ecodes.KEY_F8],
        "next_slot": [ecodes.KEY_F3],
        "prev_slot": [ecodes.KEY_F2],
        "menu": [ecodes.KEY_ESC],
        "turbo": [ecodes.KEY_TAB],
    },
    "ppssppsdl": {
        "save": [ecodes.KEY_F2],
        "load": [ecodes.KEY_F4],
        "next_slot": [ecodes.KEY_F3],
        "prev_slot": [ecodes.KEY_F2],
        "menu": [ecodes.KEY_ESC],
        "turbo": [ecodes.KEY_TAB],
    },
    "ppsspp": {
        "save": [ecodes.KEY_F2],
        "load": [ecodes.KEY_F4],
        "next_slot": [ecodes.KEY_F3],
        "prev_slot": [ecodes.KEY_F2],
        "menu": [ecodes.KEY_ESC],
        "turbo": [ecodes.KEY_TAB],
    },
    "rpcs3": {
        "menu": [ecodes.KEY_ESC],
    },
    "net.rpcs3.rpcs3": {
        "menu": [ecodes.KEY_ESC],
    },
    "xemu": {
        "menu": [ecodes.KEY_ESC],
    },
    "app.xemu.xemu": {
        "menu": [ecodes.KEY_ESC],
    },
    "cemu": {
        "menu": [ecodes.KEY_ESC],
        "save": [ecodes.KEY_F1],
        "load": [ecodes.KEY_F2],
    },
    "eden": {
        "menu": [ecodes.KEY_ESC],
        "save": [ecodes.KEY_F2],
        "load": [ecodes.KEY_F1],
    },
    "ryujinx": {
        "menu": [ecodes.KEY_ESC],
    },
    "melonds": {
        "save": [ecodes.KEY_F1],
        "load": [ecodes.KEY_F2],
        "menu": [ecodes.KEY_ESC],
    },
    "mgba-qt": {
        "save": [ecodes.KEY_F1],
        "load": [ecodes.KEY_F2],
        "menu": [ecodes.KEY_ESC],
    },
    "mgba": {
        "save": [ecodes.KEY_F1],
        "load": [ecodes.KEY_F2],
        "menu": [ecodes.KEY_ESC],
    },
    "xenia": {
        "menu": [ecodes.KEY_F11],
    },
    "xenia_canary": {
        "menu": [ecodes.KEY_F11],
    },
    "retroarch": {
        "menu": [ecodes.KEY_F1],
        "save": [ecodes.KEY_F2],
        "load": [ecodes.KEY_F4],
        "next_slot": [ecodes.KEY_F7],
        "prev_slot": [ecodes.KEY_F6],
    },
}

# Initialisation du clavier virtuel uinput
virtual_kbd = None
try:
    virtual_kbd = UInput({
        ecodes.EV_KEY: [
            ecodes.KEY_ESC,
            ecodes.KEY_TAB,
            ecodes.KEY_SPACE,
            ecodes.KEY_LEFTSHIFT,
            ecodes.KEY_F1,
            ecodes.KEY_F2,
            ecodes.KEY_F3,
            ecodes.KEY_F4,
            ecodes.KEY_F5,
            ecodes.KEY_F6,
            ecodes.KEY_F7,
            ecodes.KEY_F8,
            ecodes.KEY_F9,
            ecodes.KEY_F10,
            ecodes.KEY_F11,
            ecodes.KEY_F12,
        ]
    }, name="ChomiamOS-Universal-Hotkeys")
except Exception as err:
    sys.stderr.write(f"⚠️ Avertissement UInput: {err}\n")


def send_keys(keys):
    if not virtual_kbd:
        return
    for k in keys:
        virtual_kbd.write(ecodes.EV_KEY, k, 1)
    virtual_kbd.syn()
    time.sleep(0.04)
    for k in reversed(keys):
        virtual_kbd.write(ecodes.EV_KEY, k, 0)
    virtual_kbd.syn()


def notify(title, message):
    try:
        subprocess.Popen(
            ["notify-send", "-t", "1800", "-i", "org.es_de.frontend", title, message],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except Exception:
        pass


def get_running_emulators():
    found = []
    for pid_entry in os.scandir("/proc"):
        if not pid_entry.name.isdigit():
            continue
        pid = int(pid_entry.name)
        try:
            exe = os.readlink(f"/proc/{pid}/exe")
            exe_base = os.path.basename(exe).lower().lstrip(".")
            if exe_base.endswith("-wrapped"):
                exe_base = exe_base[:-8]
            for emu in EMULATOR_PROFILES:
                if emu in exe_base:
                    found.append((pid, emu))
                    break
        except Exception:
            try:
                with open(f"/proc/{pid}/cmdline", "r", errors="ignore") as f:
                    cmd = f.read().lower()
                for emu in EMULATOR_PROFILES:
                    if emu in cmd:
                        found.append((pid, emu))
                        break
            except Exception:
                pass
    return found


def stop_active_emulators():
    running = get_running_emulators()
    if not running:
        return False
    
    notify("🎮 ChomiamOS", "Arrêt de l'émulation en cours...")
    for pid, _ in running:
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
    
    # Vérification et arrêt forcé de secours après 0.6s si le processus résiste
    time.sleep(0.6)
    for pid, _ in running:
        try:
            os.kill(pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    return True


# Anti-rebond (debounce) pour éviter les déclenchements répétés trop rapides
last_action_times = {}


def handle_action(action_name, cooldown=0.3):
    now = time.time()
    if now - last_action_times.get(action_name, 0.0) < cooldown:
        return
    last_action_times[action_name] = now

    running = get_running_emulators()
    if not running:
        return
    
    primary_emu = running[0][1]
    emu_config = EMULATOR_PROFILES.get(primary_emu, {})
    keys = emu_config.get(action_name)
    
    if keys:
        send_keys(keys)
        if action_name == "save":
            notify("🎮 ChomiamOS", "💾 Sauvegarde rapide effectuée")
        elif action_name == "load":
            notify("🎮 ChomiamOS", "📂 Chargement rapide effectué")
        elif action_name == "next_slot":
            notify("🎮 ChomiamOS", "▶ Slot suivant sélectionné")
        elif action_name == "prev_slot":
            notify("🎮 ChomiamOS", "◀ Slot précédent sélectionné")
    elif action_name == "menu":
        send_keys([ecodes.KEY_ESC])


def is_gamepad(device):
    try:
        caps = device.capabilities()
        if ecodes.EV_KEY not in caps:
            return False
        keys = caps[ecodes.EV_KEY]
        gamepad_indicators = [
            ecodes.BTN_GAMEPAD,
            ecodes.BTN_SOUTH,
            ecodes.BTN_A,
            ecodes.BTN_START,
            ecodes.BTN_SELECT,
            ecodes.BTN_MODE,
        ]
        return any(btn in keys for btn in gamepad_indicators)
    except Exception:
        return False


async def monitor_gamepad(path):
    try:
        dev = InputDevice(path)
        print(f"🎮 Manette détectée et surveillée : {dev.name} ({path})")
    except Exception:
        return

    hotkey_pressed = False
    thumbl_pressed = False
    thumbr_pressed = False
    guide_press_time = 0.0
    guide_used_as_chord = False

    try:
        async for ev in dev.async_read_loop():
            # 1. Gestion des événements boutons
            if ev.type == ecodes.EV_KEY:
                # Bouton SELECT (Back / Share / Minus)
                if ev.code == ecodes.BTN_SELECT:
                    hotkey_pressed = (ev.value != 0)
                
                # Bouton MODE (Guide / Home / PS / Xbox)
                elif ev.code == ecodes.BTN_MODE:
                    if ev.value == 1:
                        hotkey_pressed = True
                        guide_press_time = time.time()
                        guide_used_as_chord = False
                    elif ev.value == 0:
                        hotkey_pressed = False
                        # Si Guide a été relâché rapidement sans être utilisé en combo, ouvrir le menu pause
                        if not guide_used_as_chord and (time.time() - guide_press_time < 0.6):
                            handle_action("menu")
                
                # Combo L3 + R3 (indépendant du hotkey)
                elif ev.code == ecodes.BTN_THUMBL:
                    thumbl_pressed = (ev.value != 0)
                    if thumbl_pressed and thumbr_pressed:
                        handle_action("menu")
                elif ev.code == ecodes.BTN_THUMBR:
                    thumbr_pressed = (ev.value != 0)
                    if thumbl_pressed and thumbr_pressed:
                        handle_action("menu")
                
                # Actions combinées avec Hotkey (Select ou Guide maintenu)
                elif hotkey_pressed and ev.value == 1:
                    guide_used_as_chord = True
                    
                    # Select + Start = Arrêt immédiat de l'émulateur
                    if ev.code == ecodes.BTN_START:
                        stop_active_emulators()
                    
                    # Select + R1 / RB = Sauvegarde rapide
                    elif ev.code == ecodes.BTN_TR:
                        handle_action("save")
                    
                    # Select + L1 / LB = Chargement rapide
                    elif ev.code == ecodes.BTN_TL:
                        handle_action("load")
                    
                    # Select + X ou Select + Y = Menu Pause
                    elif ev.code in (ecodes.BTN_NORTH, ecodes.BTN_WEST):
                        handle_action("menu")
                    
                    # Select + D-Pad boutons physiques (si mappés en touches)
                    elif hasattr(ecodes, "BTN_DPAD_RIGHT") and ev.code == ecodes.BTN_DPAD_RIGHT:
                        handle_action("next_slot")
                    elif hasattr(ecodes, "BTN_DPAD_LEFT") and ev.code == ecodes.BTN_DPAD_LEFT:
                        handle_action("prev_slot")
                    
                    # Select + R2 (si bouton numérique) = Turbo / Avance rapide
                    elif ev.code == ecodes.BTN_TR2:
                        handle_action("turbo")
            
            # 2. Gestion des axes (D-Pad analogique / Hat switch et gâchettes analogiques)
            elif ev.type == ecodes.EV_ABS and hotkey_pressed:
                # D-Pad Droite / Gauche via ABS_HAT0X
                if ev.code == ecodes.ABS_HAT0X:
                    guide_used_as_chord = True
                    if ev.value == 1:
                        handle_action("next_slot")
                    elif ev.value == -1:
                        handle_action("prev_slot")
                
                # Gâchette droite R2 / RT analogique via ABS_RZ ou ABS_Z
                elif ev.code in (ecodes.ABS_RZ, ecodes.ABS_Z) and ev.value > 128:
                    guide_used_as_chord = True
                    handle_action("turbo")

    except OSError:
        print(f"🔌 Manette déconnectée : {path}")


async def device_scanner():
    active_paths = set()
    while True:
        try:
            current_devices = set(list_devices())
            new_devices = current_devices - active_paths
            
            for path in new_devices:
                try:
                    dev = InputDevice(path)
                    if is_gamepad(dev):
                        active_paths.add(path)
                        asyncio.create_task(monitor_wrapper(path, active_paths))
                except Exception:
                    pass
        except Exception:
            pass
        await asyncio.sleep(2)


async def monitor_wrapper(path, active_paths):
    try:
        await monitor_gamepad(path)
    finally:
        active_paths.discard(path)


async def main():
    print("🚀 ChomiamOS Gamepad Hotkeys Daemon démarré avec succès.")
    await device_scanner()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
