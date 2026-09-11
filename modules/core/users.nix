{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.chomiamos.user;
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  # =========================================================================
  # 👤 GESTION DES UTILISATEURS ET PAQUETS SYSTÈME / UTILISATEUR
  # =========================================================================

  # Compte Utilisateur Principal (configuré via chomiamos.user)
  users.users."${cfg.username}" = {
    isNormalUser = true;
    description = cfg.fullName;
    extraGroups = cfg.extraGroups;
    shell = pkgs.${cfg.shell};
    initialHashedPassword = lib.mkIf (cfg.initialHashedPassword != null) cfg.initialHashedPassword;

    packages = with pkgs; [
      # 💼 Productivité & Bureautique
      onlyoffice-desktopeditors
      popsicle
      bazaar
      nil

      # 🛠️ Outils CLI & Shell
      fzf
      grc
      btop
      fastfetch
      git
      gh

      # 🌐 Réseau
      wireguard-tools
    ]
    ++ lib.optional (config.chomiamos.services.antigravity.enable) pkgs-unstable.antigravity-ide
    ++ lib.optional (config.chomiamos.services.pearDesktop.enable) pkgs-unstable.pear-desktop
    ++ lib.optional (config.chomiamos.services.kdenlive.enable) pkgs.kdePackages.kdenlive
    ++ lib.optional (config.chomiamos.services.goverlay.enable) pkgs.goverlay
    ++ lib.optional (config.chomiamos.services.audacity.enable) pkgs.audacity
    ++ lib.optional (config.chomiamos.services.ardour.enable) pkgs.ardour
    ++ lib.optional (config.chomiamos.discordClient == "discord") pkgs.discord
    ++ lib.optional (config.chomiamos.services.stremio.enable) pkgs.stremio-linux-shell
    ++ lib.optional (config.chomiamos.services.vlc.enable) pkgs.vlc
    ++ lib.optional (config.chomiamos.services.mpv.enable) pkgs.mpv
    ++ lib.optional (config.chomiamos.services.tailscale.enable) pkgs.tailscale
    ++ lib.optional (config.chomiamos.services.localsend.enable) pkgs.localsend
    ++ lib.optional (config.chomiamos.services.motrix.enable) pkgs.motrix
    ++ lib.optionals (cfg.shell == "fish") [
      fishPlugins.done
      fishPlugins.fzf-fish
      fishPlugins.forgit
      fishPlugins.hydro
      fishPlugins.grc
    ];
  };

  # Activation du démon Tailscale
  services.tailscale.enable = config.chomiamos.services.tailscale.enable;



  # Activation dynamique du Shell choisi & Lancement de Fastfetch
  programs.fish = lib.mkIf (cfg.shell == "fish") {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      if status is-interactive
        fastfetch
      end
    '';
  };

  programs.zsh = lib.mkIf (cfg.shell == "zsh") {
    enable = true;
    interactiveShellInit = ''
      if [[ -o interactive ]]; then
        fastfetch
      fi
    '';
    ohMyZsh = {
      enable = true;
      theme = "catppuccin";
      plugins = [ "git" ];
      custom = "${./catppuccin-zsh}";
      preLoaded = ''
        export CATPPUCCIN_FLAVOR="mocha"
        export CATPPUCCIN_SHOW_TIME=true
        export CATPPUCCIN_SHOW_HOSTNAME="never"
      '';
    };
  };

  programs.bash = lib.mkIf (cfg.shell == "bash") {
    interactiveShellInit = ''
      fastfetch
    '';
  };

  # Paquets Système Utilitaires
  environment.systemPackages = with pkgs; [
    # 🖥️ Interface & Rendu GTK
    adw-gtk3
    libadwaita
    libappindicator-gtk3

    # 📦 Compression & Archives
    cabextract
    ctrtool
    gnutar
    innoextract
    libarchive
    p7zip
    unrar
    unshield
    unzip

    # 🔤 Polices d'écriture
    font-awesome
    noto-fonts

    # 🛠️ Outils Système
    nh
    fuse3
    python3
    curl
    wget
    libva-utils
    libxcb
    pcre2
    libevent
    killall

    # 🎮 Tableau de bord officiel ChomiamOS (Rust / Slint)
    inputs.chomiamos-dashboard.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # 🛠️ Outil CLI 'nh' (Nix Helper) avec chemin flake par défaut
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };

  # 🔒 Configuration globale Git pour autoriser /etc/nixos et protéger les fichiers machine
  programs.git = {
    enable = true;
    config = {
      safe.directory = [
        "/etc/nixos"
        "/etc/nixos/*"
        "/etc/nixos/.git"
      ];
      merge = {
        ours = {
          driver = "true";
        };
      };
      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "/etc/nixos/.git-allowed-signers";
        };
      };
    };
  };

  # 🔑 Droits d'accès et modification pour l'utilisateur sur /etc/nixos et son répertoire personnel
  system.activationScripts.etcNixosPermissions = lib.stringAfter [ "users" "groups" ] ''
    if [ -d /etc/nixos ]; then
      chown -R ${cfg.username}:users /etc/nixos
      chmod -R u+rwX,g+rwX /etc/nixos
      # Garantir que git utilise le merge driver 'ours' localement et la vérification des signatures
      if [ -d /etc/nixos/.git ]; then
        ${pkgs.git}/bin/git -C /etc/nixos config merge.ours.driver true || true
        ${pkgs.git}/bin/git -C /etc/nixos config gpg.format ssh || true
        ${pkgs.git}/bin/git -C /etc/nixos config gpg.ssh.allowedSignersFile /etc/nixos/.git-allowed-signers || true
      fi
    fi
    if [ -d "/home/${cfg.username}" ]; then
      chown -R ${cfg.username}:users "/home/${cfg.username}"
      chmod u+rwx "/home/${cfg.username}"
    fi
  '';

  # 🛡️ Sauvegarde permanente et inviolable du vars.nix et hardware-configuration.nix
  system.activationScripts.etcNixosBackup = lib.stringAfter [ "users" "groups" ] ''
    # 1. Sauvegarde et sécurisation de vars.nix
    if [ -f /etc/nixos/vars.nix ]; then
      # Si vars.nix est corrompu par des marqueurs de conflit Git, tenter restauration d'urgence
      if grep -qE '^(<{7}|={7}|>{7})' /etc/nixos/vars.nix 2>/dev/null; then
        if [ -f /etc/nixos/.vars.nix.backup ]; then
          echo "⚠️ Détection de conflits Git dans vars.nix ! Restauration automatique depuis la sauvegarde..."
          cp -f /etc/nixos/.vars.nix.backup /etc/nixos/vars.nix
        fi
      fi

      # Sauvegarder uniquement si la sauvegarde n'existe pas encore ou si elle est saine
      if [ ! -f /etc/nixos/.vars.nix.backup ]; then
        cp -f /etc/nixos/vars.nix /etc/nixos/.vars.nix.backup
        chmod 0600 /etc/nixos/.vars.nix.backup
      else
        BACKUP_USER=$(grep -oP 'username\s*=\s*"\K[^"]+' /etc/nixos/.vars.nix.backup 2>/dev/null || true)
        CURRENT_USER=$(grep -oP 'username\s*=\s*"\K[^"]+' /etc/nixos/vars.nix 2>/dev/null || true)
        # Ne jamais écraser un compte utilisateur personnalisé par le compte générique
        if [ -n "$CURRENT_USER" ] && { [ "$BACKUP_USER" = "$CURRENT_USER" ] || [ "$BACKUP_USER" = "chomiam" ]; }; then
          cp -f /etc/nixos/vars.nix /etc/nixos/.vars.nix.backup
          chmod 0600 /etc/nixos/.vars.nix.backup
        fi
      fi
    fi

    # 2. Sauvegarde de hardware-configuration.nix
    if [ -f /etc/nixos/hosts/desktop/hardware-configuration.nix ]; then
      if [ ! -f /etc/nixos/.hardware-configuration.nix.backup ]; then
        cp -f /etc/nixos/hosts/desktop/hardware-configuration.nix /etc/nixos/.hardware-configuration.nix.backup
        chmod 0600 /etc/nixos/.hardware-configuration.nix.backup
      fi
    fi
  '';

  systemd.tmpfiles.rules = [
    "Z /etc/nixos 0775 ${cfg.username} users - -"
  ];
}
