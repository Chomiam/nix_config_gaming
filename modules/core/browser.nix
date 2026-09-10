{ config, pkgs, lib, ... }:

let
  selected = config.chomiamos.browser;

  # Identifiant de l'application Flatpak Flathub (si géré via Flatpak)
  flatpakAppId =
    if selected == "opera" then "com.opera.Opera"
    else if selected == "opera-gx" then "com.opera.opera-gx"
    else if selected == "zen" then "app.zen_browser.zen"
    else null;

  # Identifiant unique de l'application (utilisé pour les favoris de docks GNOME & COSMIC)
  cosmicId =
    if selected == "chrome" then "google-chrome"
    else if selected == "firefox" then "firefox"
    else if selected == "brave" then "brave-browser"
    else if selected == "librewolf" then "librewolf"
    else if flatpakAppId != null then flatpakAppId
    else "google-chrome";

  # Fichier .desktop associé
  desktopFile = "${cosmicId}.desktop";

  # Paquet système Nix (si le navigateur est disponible dans Nixpkgs)
  pkg =
    if selected == "chrome" then pkgs.google-chrome
    else if selected == "firefox" then pkgs.firefox
    else if selected == "brave" then pkgs.brave
    else if selected == "librewolf" then pkgs.librewolf
    else null;
in
{
  # =========================================================================
  # 🌐 GESTIONNAIRE CENTRAL DU NAVIGATEUR WEB (NIXPKGS & FLATPAK DÉCLARATIF)
  # Exporte 'browserInfo' pour tous les modules (GNOME, COSMIC, Flatpak, etc.)
  # =========================================================================

  _module.args = {
    browserInfo = {
      inherit pkg cosmicId desktopFile flatpakAppId;
    };
  };

  # Installation du paquet Nix si le navigateur est géré via Nixpkgs
  users.users."${config.chomiamos.user.username}".packages = lib.optionals (pkg != null) [ pkg ];

  # Installation déclarative Flatpak si le navigateur est distribué via Flathub
  services.flatpak.packages = lib.optionals (flatpakAppId != null) [ flatpakAppId ];
}
