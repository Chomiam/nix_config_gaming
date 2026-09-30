{ config, lib, pkgs, ... }:

let
  cfg = config.chomiamos.services.playwright;

  playwrightDriver157 = pkgs.stdenv.mkDerivation rec {
    pname = "playwright-driver";
    version = "1.57.0";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/playwright-core/-/playwright-core-${version}.tgz";
      hash = "sha256-jSlC9XXht3K66L0sTXH5BVv2WBvHnXABsrJ3M1uJ7yo=";
    };
    installPhase = ''
      mkdir -p $out/package
      cp -r * $out/package/
      ln -s ${pkgs.nodejs}/bin/node $out/node
      chmod +x $out/package/cli.js
    '';
  };

  # Ensemble complet des navigateurs Playwright avec tous les alias de révision (1200, 1217, 1243)
  playwrightBrowsersWithAliases = pkgs.runCommand "playwright-browsers-with-aliases" {} ''
    mkdir -p $out
    cp -rs --no-preserve=mode,ownership ${pkgs.playwright-driver.browsers}/* $out/
    # Aliases de compatibilité pour playwright-go et playwright-core (révision 1200 pour v1.57)
    ln -s $out/chromium-1217 $out/chromium-1200
    ln -s $out/chromium-1217 $out/chromium-1243
    ln -s $out/chromium_headless_shell-1217 $out/chromium_headless_shell-1200
    ln -s $out/chromium_headless_shell-1217 $out/chromium_headless_shell-1243
  '';
in
{
  # =========================================================================
  # 🎭 MODULE PLAYWRIGHT & BROWSER SUBAGENT POUR CHOMIAMOS / ANTIGRAVITY
  # Activé uniquement si config.chomiamos.services.playwright.enable = true
  # =========================================================================

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      playwrightBrowsersWithAliases
      playwrightDriver157
      pkgs.google-chrome
    ];

    environment.sessionVariables = {
      CHROME_PATH = "${pkgs.google-chrome}/bin/google-chrome";
      PLAYWRIGHT_BROWSERS_PATH = "${playwrightBrowsersWithAliases}";
      PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
      PLAYWRIGHT_NODEJS_PATH = "${pkgs.nodejs}/bin/node";
      PLAYWRIGHT_DRIVER_PATH = "${playwrightDriver157}";
    };

    # Déploie automatiquement les liens de compatibilité FHS dans /usr/bin
    # pour résoudre le bug classique de path sous NixOS (scripts et outils attendant /usr/bin/google-chrome)
    systemd.tmpfiles.rules = [
      "L+ /usr/bin/google-chrome - - - - ${pkgs.google-chrome}/bin/google-chrome"
      "L+ /usr/bin/google-chrome-stable - - - - ${pkgs.google-chrome}/bin/google-chrome-stable"
      "L+ /usr/bin/chromium - - - - ${pkgs.google-chrome}/bin/google-chrome"
      "L+ /usr/bin/chromium-browser - - - - ${pkgs.google-chrome}/bin/google-chrome"
    ];

    # Déploie automatiquement le driver Playwright 1.57.0 et lie les binaires Chromium patchés
    systemd.user.tmpfiles.rules = [
      "L+ %h/.cache/ms-playwright-go/1.57.0 - - - - ${playwrightDriver157}"
      "L+ %h/.cache/ms-playwright/chromium-1200 - - - - ${playwrightBrowsersWithAliases}/chromium-1217"
      "L+ %h/.cache/ms-playwright/chromium-1217 - - - - ${playwrightBrowsersWithAliases}/chromium-1217"
      "L+ %h/.cache/ms-playwright/chromium-1243 - - - - ${playwrightBrowsersWithAliases}/chromium-1217"
      "L+ %h/.cache/ms-playwright/chromium_headless_shell-1200 - - - - ${playwrightBrowsersWithAliases}/chromium_headless_shell-1217"
      "L+ %h/.cache/ms-playwright/chromium_headless_shell-1217 - - - - ${playwrightBrowsersWithAliases}/chromium_headless_shell-1217"
      "L+ %h/.cache/ms-playwright/chromium_headless_shell-1243 - - - - ${playwrightBrowsersWithAliases}/chromium_headless_shell-1217"
    ];
  };
}
