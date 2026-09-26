{ config, lib, pkgs, ... }:

let
  cfg = config.chomiamos.services.nix-ld;
in
{
  # =========================================================================
  # 🧪 COMPATIBILITÉ BINAIRES DYNAMIQUES (APPIMAGE & NIX-LD)
  # =========================================================================

  config = lib.mkIf cfg.enable {
    # Intégration AppImage
    programs.appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
        extraPkgs = pkgs: [
          pkgs.icu
          pkgs.libxcrypt-legacy
        ];
      };
    };

    # Loader nix-ld pour exécuter des binaires ELF Linux non-Nix pré-compilés
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        icu
        nss
        nspr
        openssl
        glib
        pcre2
        libevent
        # Support pour Playwright, Electron, Chromium et outils graphiques externes
        atk
        at-spi2-atk
        at-spi2-core
        dbus
        cups
        expat
        libxkbcommon
        alsa-lib
        mesa
        cairo
        pango
        libdrm
        systemd
        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxcb
        gtk3
      ];
    };
  };
}
