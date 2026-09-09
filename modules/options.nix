{ lib, config, ... }:

let
  cfg = config.chomiamos;
in
{
  # =========================================================================
  # ⚙️ ESPACE D'OPTIONS DÉCLARATIF CHOMIAMOS
  # =========================================================================
  options.chomiamos = {
    # Hôte & Système
    hostName = lib.mkOption {
      type = lib.types.str;
      default = "chomiamos";
      description = "Nom d'hôte de la machine (Hostname).";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Paris";
      description = "Fuseau horaire du système.";
    };

    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "fr_FR.UTF-8";
      description = "Paramètres régionaux par défaut.";
    };

    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "26.05";
      description = "Version de l'état système NixOS / Home Manager.";
    };

    firewall = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Activation du pare-feu système et filtrage des ports.";
      };
    };

    # Utilisateur Principal
    user = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "chomiam";
        description = "Nom d'utilisateur principal du système.";
      };

      fullName = lib.mkOption {
        type = lib.types.str;
        default = "Axel Valens";
        description = "Nom complet de l'utilisateur principal.";
      };

      homeDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/home/${cfg.user.username}";
        description = "Répertoire personnel de l'utilisateur.";
      };

      shell = lib.mkOption {
        type = lib.types.enum [ "fish" "zsh" "bash" ];
        default = "fish";
        description = "Shell interactif par défaut de l'utilisateur (fish, zsh ou bash).";
      };

      initialHashedPassword = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Mot de passe initial hashé de l'utilisateur principal.";
      };

      extraGroups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "networkmanager"
          "wheel"
          "docker"
          "video"
        ];
        description = "Groupes supplémentaires attribués à l'utilisateur.";
      };
    };

    # Matériel & Graphisme
    hardware = {
      gpu = lib.mkOption {
        type = lib.types.enum [ "amd" "nvidia" "nvidia-legacy" "intel" "vm" "none" ];
        default = "amd";
        description = "Sélection du pilote graphique principal et optimisations noyau associées.";
      };

      steeringWheels = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Support des volants & périphériques de simracing (Oversteer, drivers kernel).";
        };
      };
    };

    # Environnement Graphique & Navigateur
    desktop = {
      env = lib.mkOption {
        type = lib.types.enum [ "gnome" "cosmic" "both" "none" ];
        default = "gnome";
        description = "Environnement de bureau à charger (GNOME, COSMIC Desktop, les deux, ou aucun).";
      };
    };

    browser = lib.mkOption {
      type = lib.types.enum [ "chrome" "firefox" "zen" "librewolf" "opera" "opera-gx" ];
      default = "chrome";
      description = "Navigateur web par défaut du système.";
    };

    discordClient = lib.mkOption {
      type = lib.types.enum [ "discord" "equibop" "vesktop" "none" ];
      default = "discord";
      description = "Client Discord à installer (discord système, equibop flatpak, vesktop flatpak ou none).";
    };


    # Gaming & Divertissement
    gaming = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Active la suite complète gaming (GameMode, GameScope, Sunshine, Wine/Proton).";
      };

      launchers = {
        steam = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active le client Steam et ses optimisations intégrées.";
        };

        lutris = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe Lutris pour la gestion et l'installation de jeux.";
        };

        heroic = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe Heroic Games Launcher (Epic Games, GOG, Amazon Prime).";
        };

        faugus = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe Faugus Launcher (tiré de nixpkgs-unstable).";
        };
      };

      deckyLoader = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Active Decky Loader pour Steam via Jovian-NixOS.";
      };

      geforceNow = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Active le client cloud-gaming NVIDIA GeForce NOW.";
      };

      mountGamesDisk = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Activer le montage du disque de jeux secondaire.";
      };
    };

    # Suite d'Émulation & Rétrogaming
    emulation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Active la suite d'émulation et de rétrogaming.";
      };

      frontend = lib.mkOption {
        type = lib.types.enum [ "none" "es-de" ];
        default = "es-de";
        description = "Frontend graphique d'émulation (ex: es-de pour EmulationStation Desktop Edition).";
      };

      es-de = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Active EmulationStation Desktop Edition (ES-DE) AppImage.";
        };

        autoCheckUpdates = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Vérifier automatiquement les mises à jour d'ES-DE lors des opérations de mise à jour système.";
        };
      };

      retroarch = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active RetroArch avec son pack complet de cœurs 2D et Arcade recommandés.";
        };
      };

      standalone = {
        eden = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active l'émulateur Nintendo Switch Eden (standalone unstable).";
        };

        dolphin = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active l'émulateur GameCube et Wii Dolphin (standalone unstable).";
        };

        pcsx2 = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active l'émulateur PlayStation 2 PCSX2 (standalone unstable).";
        };

        ppsspp = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active l'émulateur PlayStation Portable PPSSPP (standalone unstable).";
        };

        melonds = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active l'émulateur Nintendo DS melonDS (standalone unstable).";
        };

        mgba = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active l'émulateur Game Boy / GBC / GBA mGBA (standalone Qt unstable).";
        };

        azahar = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active l'émulateur Nintendo 3DS Azahar (standalone Qt unstable).";
        };

        rpcs3 = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Active l'émulateur PlayStation 3 RPCS3 (standalone unstable).";
        };
      };
    };

    # Services Système & Applications
    services = {
      virtualisation = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active la virtualisation (KVM / QEMU, libvirtd, Virt-Manager, VirtIO).";
        };
      };

      samba = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active le partage réseau Samba (SMB/CIFS) et WSDD.";
        };
      };

      docker = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active le daemon Docker et le backend OCI.";
        };
      };

      nix-ld = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active nix-ld et appimage pour exécuter des binaires précompilés.";
        };
      };

      flatpak = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active la gestion déclarative Flatpak (nix-flatpak) et le dépôt Flathub.";
        };
      };

      obs = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active OBS Studio et ses plugins de capture.";
        };
      };

      neovim = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active Neovim configuré avec plugins de base.";
        };
      };

      blender = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active Blender 3D (tiré de nixpkgs-unstable).";
        };
      };

      godot = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active Godot Engine (tiré de nixpkgs-unstable).";
        };
      };

      # 🌐 Réseau & Partage
      tailscale = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Active le service et le client Tailscale VPN.";
        };
      };

      localsend = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe l'application de partage local LocalSend.";
        };
      };

      motrix = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe le gestionnaire de téléchargements Motrix.";
        };
      };

      # 📺 Multimédia
      stremio = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe le centre multimédia et streaming Stremio.";
        };
      };

      vlc = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe le lecteur multimédia VLC.";
        };
      };

      mpv = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe le lecteur vidéo MPV.";
        };
      };

      antigravity = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe l'environnement de développement et IDE Antigravity.";
        };
      };

      pearDesktop = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe l'application de bureau Pear Desktop.";
        };
      };

      kdenlive = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Installe l'éditeur vidéo non-linéaire libre Kdenlive.";
        };
      };

      davinciResolve = {
        version = lib.mkOption {
          type = lib.types.enum [ "none" "free" "studio" ];
          default = "none";
          description = "Version de DaVinci Resolve à installer (none, free ou studio).";
        };
      };

      aiSuite = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Active la suite IA locale (Ollama + Open-WebUI + SearXNG).";
        };

        rocmOverrideGfx = lib.mkOption {
          type = lib.types.str;
          default = "12.0.1";
          description = "Architecture ROCm cible pour GPU AMD Radeon.";
        };

        keepAlive = lib.mkOption {
          type = lib.types.str;
          default = "0s";
          description = "Durée de rétention du modèle Ollama en VRAM.";
        };

        openWebUiPort = lib.mkOption {
          type = lib.types.port;
          default = 8080;
          description = "Port HTTP de l'interface Open-WebUI.";
        };

        searxPort = lib.mkOption {
          type = lib.types.port;
          default = 8888;
          description = "Port HTTP du métamoteur SearXNG.";
        };
      };
    };
  };
}
