# ❄️ NixOS Modular System & Gaming Configuration

<p align="center">
  <img src="https://img.shields.io/badge/NixOS-26.05-5277C3?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS Version" />
  <img src="https://img.shields.io/badge/Flakes-Enabled-blueviolet?style=for-the-badge&logo=nix&logoColor=white" alt="Flakes Enabled" />
  <img src="https://img.shields.io/badge/Home--Manager-Integrated-green?style=for-the-badge&logo=nixos&logoColor=white" alt="Home Manager" />
  <img src="https://img.shields.io/badge/Theme-Catppuccin-flair?style=for-the-badge&color=f5c2e7" alt="Catppuccin Theme" />
  <img src="https://img.shields.io/badge/Gaming-Optimized-red?style=for-the-badge&logo=steam&logoColor=white" alt="Gaming Optimized" />
</p>

Une configuration **NixOS hyper-modulaire, déclarative et clé en main**, pensée pour le **Gaming haute performance**, la création de contenu (DaVinci Resolve, Godot Engine), le développement et l'intégration de services IA locaux (Ollama).

Grâce à son architecture pilotée par un fichier d'options centralisé (`vars.nix`), n'importe quel utilisateur peut adapter la totalité du système à son matériel et ses besoins en modifiant simplement quelques variables sans toucher au code Nix des modules !

---

## 📋 Table des Matières

- [1. 🌟 Vue d'ensemble & Philosophie](#1--vue-densemble--philosophie)
- [2. 📂 Structure du Répertoire](#2--structure-du-répertoire)
- [3. ⚙️ Guide de Personnalisation (`vars.nix`)](#3-️-guide-de-personnalisation-varsnix)
  - [3.1. Options Générales & Profil](#31-options-générales--profil)
  - [3.2. Sélection du Pilote GPU](#32-sélection-du-pilote-gpu)
  - [3.3. Choix du Bureau](#33-choix-du-bureau)
  - [3.4. Suite Gaming & Support SimRacing](#34-suite-gaming--support-simracing)
  - [3.5. Logiciels de Création (DaVinci Resolve, Godot)](#35-logiciels-de-création-davinci-resolve-godot)
  - [3.6. Suite IA Locale (Ollama, Open-WebUI, SearXNG)](#36-suite-ia-locale-ollama-open-webui-searxng)
- [4. 🚀 Fonctionnement des Points Clés](#4--fonctionnement-des-points-clés)
  - [4.1. 🎮 Suite Gaming & Sandbox Steam FHS](#41--suite-gaming--sandbox-steam-fhs)
  - [4.2. 🔴🟢🔵 Gestionnaire Matériel Dynamique (AMD / NVIDIA / Intel)](#42---gestionnaire-matériel-dynamique-amd--nvidia--intel)
  - [4.3. 🏎️ Support Avancé du SimRacing (Drivers Volants)](#43--support-avancé-du-simracing-drivers-volants)
  - [4.4. 🤖 Stack IA Locale Réseau-Isolée & Accélération GPU](#44--stack-ia-locale-réseau-isolée--accélération-gpu)
  - [4.5. 🎨 Intégration Home-Manager & Thème Catppuccin](#45--intégration-home-manager--thème-catppuccin)
- [5. 🛠️ Guide d'Installation & Utilisation](#5-️-guide-dinstallation--utilisation)

---

## 1. 🌟 Vue d'ensemble & Philosophie

Cette configuration repose sur trois piliers majeurs :

1. **Centralisation Totale (`vars.nix`)** : Pas besoin de chercher dans des dizaines de fichiers `.nix` pour changer de pilote graphique, installer Godot ou activer le pare-feu. Tout se règle dans un unique fichier d'options documenté.
2. **Hybridation Stable / Unstable** : Le cœur du système s'appuie sur la branche stable **NixOS 26.05**, tandis que les paquets nécessitant une réactivité maximale (comme `MangoHud`, `GovErlay` ou le bureau `COSMIC Desktop`) sont tirés dynamiquement de `nixpkgs-unstable`.
3. **Optimisations système Gaming & Kernel** : Intégration du noyau `linuxPackages_zen` pour AMD ou `linuxPackages_xanmod` pour NVIDIA/Intel, ajustement des paramètres réseau et mémoire `sysctl` pour réduire la latence et maximiser la stabilité sous Proton / Wine.

---

## 2. 📂 Structure du Répertoire

```text
/etc/nixos/
├── flake.nix                  # Point d'entrée de la configuration Flakes NixOS
├── flake.lock                 # Verrouillage exact des révisions de paquets
├── vars.nix                   # ⚙️ Fichier unique de configuration et options utilisateur
├── configuration.nix          # Import par défaut pour compatibilité nixos-rebuild
├── hardware-configuration.nix # Spécifique à la machine (généré par nixos-generate-config)
├── README.md                  # Documentation complète du projet
├── hosts/                     # Déclarations des hôtes système
│   └── desktop/               # Module machine principale (mounts, configuration hôte)
├── modules/                   # Modules système modulaires
│   ├── core/                  # Configuration système (Users, Firewall, Sysctl Gaming)
│   ├── desktop/               # Environnements de bureau (GNOME, COSMIC Desktop)
│   ├── gaming/                # Suite Gaming (Steam, GameMode, GameScope, MangoHud, Launchers)
│   ├── hardware/              # Pilotes GPU (AMD, NVIDIA, NVIDIA Legacy, Intel) & Volants
│   └── services/              # Services optionnels (Ollama/IA, DaVinci Resolve, Neovim, Flatpak)
└── home/                      # Configuration utilisateur Home Manager & Thématisation Catppuccin
    ├── apps.nix               # Applications utilisateur & utilitaires
    ├── kitty.nix              # Émulateur de terminal Kitty avec sous-processus optimisés
    ├── fastfetch.nix          # Configuration personnalisée du neofetch/fastfetch
    └── catppuccin.nix         # Intégration globale du thème Catppuccin
```

---

## 3. ⚙️ Guide de Personnalisation (`vars.nix`)

Le fichier `vars.nix` à la racine de la configuration contient toutes les options nécessaires pour adapter le système à **votre** machine.

### 3.1. Options Générales & Profil

| Option | Valeur par défaut | Description |
| :--- | :--- | :--- |
| `hostName` | `"chomiamos"` | Nom d'hôte de la machine sur le réseau. |
| `timeZone` | `"Europe/Paris"` | Fuseau horaire du système. |
| `defaultLocale` | `"fr_FR.UTF-8"` | Langue principale et encodage du système. |
| `user.username` | `"chomiam"` | Nom du compte utilisateur principal. |
| `user.fullName` | `"Axel Valens"` | Nom complet de l'utilisateur. |
| `browser` | `"chrome"` | Choix du navigateur principal (`"chrome"`, `"firefox"`, `"librewolf"` via Nixpkgs ; `"opera"`, `"opera-gx"`, `"zen"` via Flatpak Flathub). |
| `firewall` | `false` | Activer (`true`) ou désactiver (`false`) le pare-feu système. |

### 3.2. Sélection du Pilote GPU

Réglez `gpuDriver` selon votre carte graphique :

```nix
gpuDriver = "amd"; # Options : "amd" | "nvidia" | "nvidia-legacy" | "intel"
```

- `"amd"` : Cartes AMD Radeon (RADV Vulkan, ROCm OpenCL, Kernel Linux Zen).
- `"nvidia"` : Cartes NVIDIA récentes (GTX 1650 / RTX et plus récentes) avec pilotes récents et Kernel XanMod.
- `"nvidia-legacy"` : Cartes NVIDIA anciennes générations (séries 10xx, 9xx...) avec pilotes legacy (470/390) et Kernel XanMod.
- `"intel"` : Puces Intel iGPU ou dGPU ARC avec accélérateur `intel-media-driver` et Kernel XanMod.

### 3.3. Choix du Bureau

```nix
desktopEnv = "gnome"; # Options : "gnome" | "cosmic" | "both"
```

- `"gnome"` : Environnement GNOME complet avec extensions optimisées.
- `"cosmic"` : Le tout nouveau bureau COSMIC Desktop (composité Wayland moderne en Rust).
- `"both"` : Installe et rend accessibles les deux environnements au moment du login.

### 3.4. Suite Gaming & Support SimRacing

```nix
gaming = {
  enable = true;          # Active la suite Gaming (Steam, GameMode, GameScope, Lutris, Heroic...)
  geforceNow = true;       # Active l'accès rapide GeForce NOW
  mountGamesDisk = true;   # Active le montage automatique des disques secondaires dédiés aux jeux
};

steeringWheelSupport = true; # Active la prise en charge des volants de course (Fanatec, Thrustmaster, Logitech)
```

### 3.5. Logiciels de Création (DaVinci Resolve, Blender, Godot)

```nix
davinciResolve = "none"; # Options : "none" | "free" | "studio"
blender = true;          # Active l'installation de Blender 3D (nixpkgs-unstable)
godot = true;            # Active l'installation de Godot Engine 4 (nixpkgs-unstable)
```

### 3.6. Suite IA Locale (Ollama, Open-WebUI, SearXNG)

```nix
aiSuite = {
  enable = false;           # Active la suite complète Ollama + Open-WebUI + SearXNG
  rocmOverrideGfx = "12.0.1";# Support des GPU AMD spécifiques pour ROCm (ex: RX 7000, RX 9000)
  keepAlive = "0s";        # Libération instantanée de la VRAM GPU après génération
  openWebUiPort = 8080;
  searxPort = 8888;
};
```

---

## 4. 🚀 Fonctionnement des Points Clés

### 4.1. 🎮 Suite Gaming & Sandbox Steam FHS
Sur NixOS, Steam s'exécute dans une Sandbox isolée (FHS Environment). Afin de garantir l'injection parfaite des overlays de performances comme **MangoHud** ou **GovErlay** (tirés de `nixpkgs-unstable`), la configuration inclut directement MangoHud dans `programs.steam.extraPackages`.

Ainsi, que vous lanciez un jeu via **Steam**, **Lutris** ou **Heroic Games Launcher**, les bibliothèques Vulkan 32-bit et 64-bit de MangoHud sont automatiquement détectées !

### 4.2. 🔴🟢🔵 Gestionnaire Matériel Dynamique (AMD / NVIDIA / Intel)
Le module `modules/hardware/default.nix` lit la variable `vars.gpuDriver` et charge de manière totalement conditionnelle le pilote adapté :
- Activation des bibliothèques Vulkan 32-bit (`hardware.graphics.enable32Bit = true`).
- Injection automatique des noyaux optimisés (`linuxPackages_zen` pour AMD, `linuxPackages_xanmod` pour NVIDIA/Intel).
- Support OpenCL / ROCm prêt à l'emploi.

### 4.3. 🏎️ Support Avancé du SimRacing (Drivers Volants)
Lorsque `steeringWheelSupport = true` est activé dans `vars.nix`, le système compile et charge automatiquement les pilotes du noyau Linux pour volants de retour de force :
- `new-lg4ff` (Logitech G25/G27/G29/G920)
- `hid-fanatecff` (Bases Fanatec CSL/DD/ClubSport)
- `hid-tmff2` & `hid-t150` (Thrustmaster T150/T300/T500/TS-PC)
- Installation automatique d'**Oversteer** pour le réglage précis de la rotation et du retour de force.

### 4.4. 🤖 Stack IA Locale Réseau-Isolée & Accélération GPU
La suite IA inclut **Ollama** avec accélération GPU (CUDA sur NVIDIA, ROCm sur AMD avec override de microarchitecture configurable), une interface Web élégante **Open-WebUI**, ainsi que le moteur de recherche respectueux de la vie privée **SearXNG** préconfiguré comme métamoteur de recherche local.

### 4.5. 🎨 Intégration Home-Manager & Thème Catppuccin
L'environnement utilisateur est géré par **Home-Manager**. Tous les utilitaires de terminal (Kitty, Fastfetch, Fish, Shell) ainsi que les éléments GTK adoptent automatiquement la palette de couleurs **Catppuccin Mocha**.

---

## 5. 🛠️ Guide d'Installation & Utilisation

### 1. Clonage de la configuration
```bash
sudo git clone https://github.com/Chomiam/nix_config_gaming.git /etc/nixos
cd /etc/nixos
```

### 2. Personnalisation du fichier `vars.nix`
Éditez le fichier `vars.nix` selon votre matériel et vos préférences :
```bash
nano vars.nix
```

### 3. Application de la configuration
Préparez la configuration pour le prochain démarrage puis redémarrez la machine (recommandé pour charger proprement les pilotes noyau, serveurs d'affichage et modules GPU) :
```bash
sudo nixos-rebuild boot --flake .# && sudo reboot
```

---

<p align="center">
  <i>Développé avec ❄️ NixOS — Conçu pour la performance et le confort de jeu.</i>
</p>
