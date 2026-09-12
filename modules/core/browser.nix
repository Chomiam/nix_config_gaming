{ config, pkgs, lib, ... }:

let
  selected = config.chomiamos.browser;
  pkgType = config.chomiamos.browserPackageType or "system";

  # Identifiant de l'application Flatpak Flathub (si géré via Flatpak)
  flatpakAppId =
    if selected == "zen" then "app.zen_browser.zen"
    else if selected == "librewolf" then "io.gitlab.librewolf-community"
    else if selected == "opera" then "com.opera.Opera"
    else if selected == "opera-gx" then "com.opera.opera-gx"
    else if pkgType == "flatpak" then (
      if selected == "chrome" then "com.google.Chrome"
      else if selected == "firefox" then "org.mozilla.firefox"
      else if selected == "brave" then "com.brave.Browser"
      else null
    )
    else null;

  # Paquet système Nix (si le navigateur est installé en mode système)
  pkg =
    if selected == "zen" || selected == "librewolf" || selected == "opera" || selected == "opera-gx" then null
    else if pkgType == "system" then (
      if selected == "chrome" then pkgs.google-chrome
      else if selected == "firefox" then pkgs.firefox
      else if selected == "brave" then pkgs.brave
      else null
    )
    else null;

  # Identifiant unique de l'application (utilisé pour les favoris de docks GNOME & COSMIC)
  cosmicId =
    if flatpakAppId != null then flatpakAppId
    else if selected == "chrome" then "google-chrome"
    else if selected == "firefox" then "firefox"
    else if selected == "brave" then "brave-browser"
    else "google-chrome";

  # Fichier .desktop associé
  desktopFile = "${cosmicId}.desktop";
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

  # Installation du paquet Nix si le navigateur est configuré en mode système
  users.users."${config.chomiamos.user.username}".packages = lib.optionals (pkg != null) [ pkg ];

  # Installation déclarative Flatpak si le navigateur est configuré en mode Flatpak
  services.flatpak.packages = lib.optionals (flatpakAppId != null) [ flatpakAppId ];
}
