{ config, pkgs, inputs, ... }:

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

    packages = with pkgs; [
      # 📺 Multimédia
      stremio-linux-shell
      vlc
      mpv

      # 💼 Productivité & Bureautique
      discord
      onlyoffice-desktopeditors
      popsicle
      bazaar
      nil
      pkgs-unstable.antigravity-ide
      pkgs-unstable.pear-desktop

      # 🛠️ Outils CLI & Shell
      fzf
      grc
      btop
      fastfetch
      git
      gh
      fishPlugins.done
      fishPlugins.fzf-fish
      fishPlugins.forgit
      fishPlugins.hydro
      fishPlugins.grc

      # 🌐 Réseau
      tailscale
      localsend
      wireguard-tools
      motrix
    ];
  };

  # Activation du Shell Fish & Lancement de Fastfetch au démarrage
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      if status is-interactive
        fastfetch
      end
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
  ];
}
