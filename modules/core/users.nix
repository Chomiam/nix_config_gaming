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
      wireguard-tools
    ]
    ++ lib.optional (config.chomiamos.discordClient == "discord") pkgs.discord
    ++ lib.optional (config.chomiamos.services.stremio.enable) pkgs.stremio-linux-shell
    ++ lib.optional (config.chomiamos.services.vlc.enable) pkgs.vlc
    ++ lib.optional (config.chomiamos.services.mpv.enable) pkgs.mpv
    ++ lib.optional (config.chomiamos.services.tailscale.enable) pkgs.tailscale
    ++ lib.optional (config.chomiamos.services.localsend.enable) pkgs.localsend
    ++ lib.optional (config.chomiamos.services.motrix.enable) pkgs.motrix;
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
      fastfetch
    '';
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
  ];
}
