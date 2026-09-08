# ❄️ ChomiamOS — Configuration NixOS Modulaire & Gaming

<p align="center">
  <img src="https://img.shields.io/badge/NixOS-26.05-5277C3?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS Version" />
  <img src="https://img.shields.io/badge/Flakes-Enabled-blueviolet?style=for-the-badge&logo=nix&logoColor=white" alt="Flakes Enabled" />
  <img src="https://img.shields.io/badge/Home--Manager-Integrated-green?style=for-the-badge&logo=nixos&logoColor=white" alt="Home Manager" />
  <img src="https://img.shields.io/badge/Jovian--NixOS-Decky--Loader-orange?style=for-the-badge&logo=steamdeck&logoColor=white" alt="Jovian NixOS" />
  <img src="https://img.shields.io/badge/Theme-Catppuccin%20Mocha-flair?style=for-the-badge&color=f5c2e7" alt="Catppuccin Theme" />
  <img src="https://img.shields.io/badge/Gaming-Optimized-red?style=for-the-badge&logo=steam&logoColor=white" alt="Gaming Optimized" />
</p>

Une distribution et configuration **NixOS hyper-modulaire, déclarative et clé en main**, optimisée pour le **Gaming compétitif haute performance**, la création de contenu (DaVinci Resolve, Godot, Blender), la virtualisation Windows (Virt-Manager / VirtIO) et les services IA locaux accélérés par GPU (Ollama + Open-WebUI).

Cette configuration fonctionne à la fois comme un **système autonome personnalisable** via un unique fichier [vars.nix](file:///etc/nixos/vars.nix), et comme un **module Flake réutilisable** (`nixosModules.default`) pouvant être importé par d'autres utilisateurs dans leur propre environnement NixOS.

---

## 📋 Table des Matières

- [1. 🌟 Philosophie & Architecture Modulaire](#1--philosophie--architecture-modulaire)
- [2. 🕹️ Fonctionnalités Principales](#2-️-fonctionnalités-principales)
  - [2.1. Gaming & Steam Decky Loader](#21-gaming--steam-decky-loader)
  - [2.2. Gestion Matérielle Multi-GPU & Noyaux Optimisés](#22-gestion-matérielle-multi-gpu--noyaux-optimisés)
  - [2.3. Virtualisation KVM & Pilotes VirtIO Windows](#23-virtualisation-kvm--pilotes-virtio-windows)
  - [2.4. Partage Réseau Windows (Samba & WSDD)](#24-partage-réseau-windows-samba--wsdd)
  - [2.5. Environnements de Bureau (GNOME & COSMIC Desktop)](#25-environnements-de-bureau-gnome--cosmic-desktop)
  - [2.6. Compatibilité Binaire (Nix-LD, AppImage, Flatpak)](#26-compatibilité-binaire-nix-ld-appimage-flatpak)
  - [2.7. Suite IA Locale Privée & RAG (Ollama, WebUI, SearXNG)](#27-suite-ia-locale-privée--rag-ollama-webui-searxng)
  - [2.8. Support SimRacing (Pilotes Volants Linux)](#28-support-simracing-pilotes-volants-linux)
- [3. 📂 Structure du Répertoire](#3--structure-du-répertoire)
- [4. ⚙️ Guide de Configuration Rapide (`vars.nix`)](#4-️-guide-de-configuration-rapide-varsnix)
- [5. 📦 Utilisation comme Module Externe (Partage Flake)](#5--utilisation-comme-module-externe-partage-flake)
- [6. 🛠️ Installation & Commandes Usuelles](#6-️-installation--commandes-usuelles)

---

## 1. 🌟 Philosophie & Architecture Modulaire

La configuration repose sur une séparation nette entre le **socle technique modulaire** et la **définition de la machine** :

1. **Espace d'Options Déclaratif (`chomiamos.*`)** : Tous les modules sont définis selon le système d'options natif de NixOS (`options.nix`). Chaque fonctionnalité (Samba, Docker, Decky Loader, DaVinci Resolve, profil GPU) est activable ou désactivable de manière indépendante avec typage strict et valeurs par défaut.
2. **Imports Inconditionnels & `lib.mkIf`** : Élimination des imports conditionnels au profit d'une évaluation modulaire propre, assurant une introspection complète du système et une compatibilité maximale avec les outils NixOS.
3. **Double Accès (Simplicité vs Flexibilité)** :
   - Pour une utilisation locale directe : réglez vos préférences en 1 minute dans [vars.nix](file:///etc/nixos/vars.nix).
   - Pour une utilisation avancée ou multi-machines : configurez directement les options déclaratives `chomiamos.*`.
4. **Noyaux et Hybridation Stable / Unstable** : Le socle système s'appuie sur la branche stable **NixOS 26.05**, couplée dynamiquement à `nixpkgs-unstable` pour les paquets nécessitant une fraîcheur absolue (`MangoHud`, `COSMIC Desktop`, `Blender`, `Godot Engine`, `ProtonPlus`).

---

## 2. 🕹️ Fonctionnalités Principales

### 2.1. Gaming & Steam Decky Loader
- **Client Steam FHS & Overlays** : Intégration native de `MangoHud`, `GovErlay`, `GameMode` (Feral Interactive avec renice automatique) et `GameScope` (compositeur Wayland HDR/FSR).
- **Decky Loader (Jovian-NixOS)** : Intégration du module officiel Jovian-NixOS et activation automatique du débogage CEF à distance (`.cef-enable-remote-debugging`) pour l'injection transparente de plugins dans Steam.
- **Serveur Sunshine** : Streaming local ultra-faible latence vers Moonlight (compatible HDR/4K).
- **Launchers & Compatibilité Windows** : `Heroic Games Launcher` (avec wrappers MangoHud/GameMode préconfigurés), `Lutris`, `ProtonPlus`, `Ludusavi` (sauvegardes de jeux), `UMU-Launcher`, `Winetricks` et `Protontricks`.
- **Accès Cloud Gaming** : Raccourci déclaratif dédié pour NVIDIA GeForce NOW.

### 2.2. Gestion Matérielle Multi-GPU & Noyaux Optimisés
Un réglage unique bascule l'ensemble du profil GPU et du noyau Linux adapté :
- **AMD Radeon (`"amd"`)** : Noyau `linuxPackages_zen` optimisé, Mesa RADV Vulkan 32/64-bit, OpenCL ROCm (`rocmPackages.clr.icd`) et VA-API matériel.
- **NVIDIA Moderne (`"nvidia"`)** : Noyau `linuxPackages_xanmod` stable, pilote propriétaire stable, modesetting Wayland, accélération NVDEC/NVENC.
- **NVIDIA Legacy (`"nvidia-legacy"`)** : Support dédié des générations antérieures à la GTX 1650 (séries 10xx, 9xx...) avec le pilote legacy 470 et noyau XanMod stable.
- **Intel Arc / iGPU (`"intel"`)** : Noyau `linuxPackages_xanmod_latest`, pilote `intel-media-driver` et runtime compute OpenCL/OneAPI.

### 2.3. Virtualisation KVM & Pilotes VirtIO Windows
- **Virt-Manager & Libvirt** : Daemon `libvirtd` optimisé avec émulation TPM 2.0 (`swtpm`), partage de dossiers hôte/invité haute performance (`virtiofsd`) et redirection USB SPICE.
- **Pilotes VirtIO Déclaratifs** :
  - `virtio-win.iso` : Dernière image VirtIO moderne pour Windows 10, 11 et Windows Server.
  - `virtio-win-win7.iso` : Image certifiée v0.1.173 compatible Windows 7 (SHA-1/SHA-2).
  - Disponibles directement dans `/etc/virtio-win.iso` et exposés dans le pool par défaut `/var/lib/libvirt/images`.

### 2.4. Partage Réseau Windows (Samba & WSDD)
- Serveur Samba (SMB2/SMB3) partageant automatiquement le dossier utilisateur et la racine `/home`.
- Découverte réseau Windows sans configuration via le daemon `samba-wsdd`.
- Pare-feu ouvert automatiquement sur les ports nécessaires.

### 2.5. Environnements de Bureau (GNOME & COSMIC Desktop)
- **GNOME Shell** : Thème dark moderne, accent purple, extensions productivité (`Dash to Dock`, `Blur my Shell`, `AppIndicator`, `Vitals`, `Clipboard Indicator`, `ArcMenu`).
- **Modèles de Documents** : Génération déclarative automatique des modèles de fichiers dans `~/Modèles` (`.docx`, `.xlsx`, `.pptx`, `.sh`, `.txt`) pour créer un document bureautique en un clic droit.
- **COSMIC Desktop 1.5+** : Bureau Wayland nouvelle génération écrit en Rust, tiré directement de `nixpkgs-unstable` avec correctifs XKB et applets communautaires (`minimon-applet`, `clipboard-manager`).

### 2.6. Compatibilité Binaire (Nix-LD, AppImage, Flatpak)
- **Nix-LD** : Exécutez n'importe quel binaire Linux compilé dynamiquement sans patcher avec `patchelf`.
- **AppImage** : Support transparent d'`appimage-run` avec binfmt.
- **Flatpak Déclaratif** : Gestion déclarative via `nix-flatpak` connecté au dépôt Flathub officiel.

### 2.7. Suite IA Locale Privée & RAG (Ollama, WebUI, SearXNG)
- **Ollama** : Accélération GPU automatique (ROCm sur AMD, CUDA sur Nvidia), support des microarchitectures GPU récentes (`rocmOverrideGfx`), gestion dynamique du déchargement VRAM (`keepAlive`).
- **Open-WebUI** : Interface de chat moderne connectée à Ollama et SearXNG pour la recherche Web locale (RAG).
- **SearXNG** : Métamoteur de recherche local respectueux de la vie privée.

### 2.8. Support SimRacing (Pilotes Volants Linux)
- Modules noyau Force Feedback : `new-lg4ff` (Logitech G25/G27/G29/G920), `hid-fanatecff` (Fanatec CSL/DD/ClubSport), `hid-tmff2` et `hid-t150` (Thrustmaster T150/T300/T248/T500/TS-PC), `universal-pidff`.
- Règles udev et interface graphique **Oversteer** pour régler le débattement et la force.

---

## 3. 📂 Structure du Répertoire

```text
/etc/nixos/
├── flake.nix                       # Point d'entrée Flakes & Export des modules
├── flake.lock                      # Verrouillage exact des dépendances
├── vars.nix                        # ⚙️ Fichier unique de personnalisation utilisateur
├── configuration.nix               # Passerelle par défaut pour compatibilité nixos-rebuild
├── README.md                       # Documentation officielle
│
├── hosts/                          # Déclarations des machines (Hôtes)
│   └── desktop/
│       ├── configuration.nix       # Assemblage hôte & Liaison options <-> vars.nix
│       ├── hardware-configuration.nix # Spécifique à la machine (généré par NixOS)
│       └── mount.nix               # Points de montage disque spécifiques
│
├── modules/                        # 📦 Cœur du framework modulaire Chomiamos
│   ├── default.nix                 # Point d'entrée global des modules
│   ├── options.nix                 # ⚙️ Déclaration du namespace déclaratif 'chomiamos.*'
│   │
│   ├── core/                       # Socle système (Users, Firewall, Sysctl, Browser)
│   │   ├── default.nix
│   │   ├── users.nix
│   │   ├── firewall.nix
│   │   ├── browser.nix
│   │   └── sysctl-gaming.nix
│   │
│   ├── hardware/                   # Pilotes GPU et périphériques matériels
│   │   ├── default.nix
│   │   ├── amd.nix
│   │   ├── nvidia.nix
│   │   ├── nvidia-legacy.nix
│   │   ├── intel.nix
│   │   └── steering-wheels.nix
│   │
│   ├── desktop/                    # Environnements graphiques
│   │   ├── default.nix
│   │   ├── gnome.nix
│   │   ├── cosmic.nix
│   │   └── templates/              # Modèles bureautiques par défaut (.docx, .xlsx, .pptx)
│   │
│   ├── gaming/                     # Suite Gaming & Jovian-NixOS
│   │   ├── default.nix
│   │   └── decky-loader.nix
│   │
│   └── services/                   # Services et applications activables
│       ├── default.nix             # Import unifié de tous les services
│       ├── samba.nix               # Partage SMB/CIFS & WSDD
│       ├── virt-manager.nix        # KVM / QEMU / VirtIO ISOs
│       ├── docker.nix              # Daemon Docker & OCI
│       ├── flatpak.nix             # Nix-Flatpak & Flathub
│       ├── nix-ld.nix              # Compatibilité binaires externes
│       ├── obs.nix                 # OBS Studio & plugins capture
│       ├── neovim.nix              # Neovim & Snacks/Grug-Far
│       ├── blender.nix             # Blender 3D (unstable)
│       ├── godot.nix               # Godot Engine (unstable)
│       ├── davinci-resolve.nix     # DaVinci Resolve Free / Studio
│       └── ai-suite.nix            # Ollama, Open-WebUI & SearXNG
│
└── home/                           # Profils utilisateur Home-Manager & Thématisation
    ├── default.nix
    ├── apps.nix                    # Applications bureautiques & terminal
    ├── kitty.nix                   # Terminal Kitty GPU-accéléré
    ├── fastfetch.nix               # Fastfetch personnalisé
    ├── gtk-theme.nix               # Thème GTK
    └── catppuccin.nix              # Thème Catppuccin Mocha
```

---

## 4. ⚙️ Guide de Configuration Rapide (`vars.nix`)

Toutes les options principales se modifient directement dans [vars.nix](file:///etc/nixos/vars.nix) :

```nix
# Nom d'hôte et utilisateur
hostName = "chomiamos";
user.username = "chomiam";
user.fullName = "Axel Valens";

# Carte Graphique ("amd" | "nvidia" | "nvidia-legacy" | "intel")
gpuDriver = "amd";

# Environnement Graphique ("gnome" | "cosmic" | "both")
desktopEnv = "gnome";

# Navigateur ("chrome" | "firefox" | "zen" | "librewolf" | "opera" | "opera-gx")
browser = "chrome";

# Gaming & Decky Loader
gaming = {
  enable = true;
  deckyLoader = true;
  geforceNow = true;
};

# Virtualisation Virt-Manager / KVM (true | false)
virtualisation.enable = true;

# Prise en charge des volants SimRacing (true | false)
steeringWheelSupport = true;

# Logiciels de création (Blender, Godot, DaVinci Resolve)
blender = true;
godot = true;
davinciResolve = "none"; # "none" | "free" | "studio"

# Suite IA Locale (Ollama + WebUI + SearXNG)
aiSuite.enable = false;
```

---

## 5. 📦 Utilisation comme Module Externe (Partage Flake)

Grâce à l'export `nixosModules.default` dans [flake.nix](file:///etc/nixos/flake.nix), n'importe quel utilisateur peut intégrer ChomiamOS comme une dépendance dans son propre `flake.nix` :

```nix
# Le flake.nix d'une autre machine :
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    chomiamos.url = "github:Chomiam/nix_config_gaming";
  };

  outputs = { self, nixpkgs, chomiamos, ... }: {
    nixosConfigurations.mon-pc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        chomiamos.nixosModules.default
        {
          chomiamos = {
            user.username = "mon_pseudo";
            hardware.gpu = "nvidia";
            desktop.env = "gnome";
            gaming.enable = true;
            gaming.deckyLoader = true;
            services.virtualisation.enable = true;
          };
        }
      ];
    };
  };
}
```

---

## 6. 🛠️ Installation & Commandes Usuelles

### 1. Cloner la configuration
```bash
sudo git clone https://github.com/Chomiam/nix_config_gaming.git /etc/nixos
cd /etc/nixos
```

### 2. Personnaliser `vars.nix`
```bash
nano vars.nix
```

### 3. Vérifier et appliquer
```bash
# Vérifier la validité de la configuration
nix flake check

# Tester la configuration sans redémarrer
sudo nixos-rebuild test --flake .#

# Appliquer pour le prochain démarrage et redémarrer
sudo nixos-rebuild boot --flake .# && sudo reboot
```

### 4. Maintenance & Nettoyage
```bash
# Mettre à jour toutes les dépendances Flake
nix flake update

# Nettoyer les anciennes générations du magasin Nix
sudo nix-collect-garbage -d
```

---

<p align="center">
  <i>Développé avec ❄️ NixOS — Conçu pour la performance, la modularité et le confort de jeu.</i>
</p>
