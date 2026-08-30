{ pkgs, vars, inputs, ... }:

let
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # =========================================================================
  # 👤 GESTION DES UTILISATEURS ET PAQUETS SYSTÈME / UTILISATEUR
  # =========================================================================

  # Compte Utilisateur Principal (basé sur vars.nix)
  users.users."${vars.user.username}" = {
    isNormalUser = true;
    description = vars.user.fullName;
    extraGroups = vars.user.extraGroups;
    shell = pkgs.${vars.user.shell};

    packages = with pkgs; [
      # 📺 Multimédia
      stremio-linux-shell
      vlc
      mpv

      # 💼 Productivité & Bureautique
      (google-chrome.override {
        commandLineArgs = "--ozone-platform=x11";
      })
      firefox
      discord
      onlyoffice-desktopeditors
      popsicle
      bazaar
      nil
      antigravity
      pkgs-unstable.pear-desktop

      # 🛠️ Outils CLI & Shell
      fzf
      grc
      btop
      fastfetch
      git
      fishPlugins.done
      fishPlugins.fzf-fish
      fishPlugins.forgit
      fishPlugins.hydro
      fishPlugins.grc

      # 🌐 Réseau
      tailscale
      localsend
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
    gnutar
    libarchive
    p7zip
    unrar
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
    killall
  ];
}
