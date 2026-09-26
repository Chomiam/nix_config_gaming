{ config, lib, pkgs, ... }:

let
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
in
{
  # =========================================================================
  # 🎭 MODULE PLAYWRIGHT & BROWSER SUBAGENT POUR CHOMIAMOS / ANTIGRAVITY
  # =========================================================================

  environment.systemPackages = [
    pkgs.playwright-driver.browsers
    playwrightDriver157
  ];

  environment.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
    PLAYWRIGHT_NODEJS_PATH = "${pkgs.nodejs}/bin/node";
    PLAYWRIGHT_DRIVER_PATH = "${playwrightDriver157}";
  };

  # Déploie automatiquement le driver Playwright 1.57.0 et lie les binaires Chromium patchés
  systemd.user.tmpfiles.rules = [
    "L+ %h/.cache/ms-playwright-go/1.57.0 - - - - ${playwrightDriver157}"
    "L+ %h/.cache/ms-playwright/chromium-1200/chrome-linux64 - - - - ${pkgs.playwright-driver.browsers}/chromium-1217/chrome-linux64"
    "L+ %h/.cache/ms-playwright/chromium-1243/chrome-linux64 - - - - ${pkgs.playwright-driver.browsers}/chromium-1217/chrome-linux64"
    "L+ %h/.cache/ms-playwright/chromium_headless_shell-1200/chrome-headless-shell-linux64 - - - - ${pkgs.playwright-driver.browsers}/chromium_headless_shell-1217/chrome-headless-shell-linux64"
    "L+ %h/.cache/ms-playwright/chromium_headless_shell-1243/chrome-headless-shell-linux64 - - - - ${pkgs.playwright-driver.browsers}/chromium_headless_shell-1217/chrome-headless-shell-linux64"
  ];
}
