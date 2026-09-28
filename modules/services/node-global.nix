{ config, lib, pkgs, ... }:

let
  cfg = config.chomiamos.services.node-global;
  userCfg = config.chomiamos.user;

  # Répertoire utilisé comme prefix npm global (remplace /nix/store en lecture seule)
  npmGlobalPrefix = "${userCfg.homeDirectory}/.npm-global";
in
{
  # =========================================================================
  # 🟢 COMPATIBILITÉ NODE.JS / NPM / NPX GLOBAUX SOUS NIXOS
  # =========================================================================
  # Résout le problème structurel de NixOS avec les installations npm/npx :
  #   - `npm install -g` échoue car le prefix pointe vers /nix/store (lecture seule)
  #   - `npx` télécharge des binaires pré-compilés qui ne trouvent pas les libs dynamiques
  #   - Les agents IA (Claude Code, Aider, etc.) installés via npm ne sont pas dans le PATH
  #
  # Solution déclarative :
  #   1. Redirige le prefix npm global vers ~/.npm-global (écrivable)
  #   2. Ajoute ~/.npm-global/bin au PATH système
  #   3. Injecte les bibliothèques natives manquantes dans nix-ld
  #   4. Configure le cache npx dans un répertoire écrivable
  # =========================================================================

  config = lib.mkIf cfg.enable {
    # -------------------------------------------------------------------
    # 📁 Création automatique du répertoire npm-global et de ses sous-dossiers
    # -------------------------------------------------------------------
    system.activationScripts.npmGlobalDir = lib.stringAfter [ "users" "groups" ] ''
      install -d -m 0755 -o ${userCfg.username} -g users "${npmGlobalPrefix}"
      install -d -m 0755 -o ${userCfg.username} -g users "${npmGlobalPrefix}/bin"
      install -d -m 0755 -o ${userCfg.username} -g users "${npmGlobalPrefix}/lib"

      # Fichier .npmrc global si absent — redirection du prefix npm
      NPMRC="${userCfg.homeDirectory}/.npmrc"
      if [ ! -f "$NPMRC" ] || ! grep -q "prefix=" "$NPMRC" 2>/dev/null; then
        echo "prefix=${npmGlobalPrefix}" >> "$NPMRC"
        chown ${userCfg.username}:users "$NPMRC"
      fi
    '';

    # -------------------------------------------------------------------
    # 🔗 Variables d'environnement système (sessionnelles, visibles partout)
    # -------------------------------------------------------------------
    environment.sessionVariables = {
      # Prefix npm global écrivable (utilisé par npm install -g)
      NPM_CONFIG_PREFIX = npmGlobalPrefix;

      # Cache npx dans un répertoire écrivable (évite /nix/store)
      NPM_CONFIG_CACHE = "${userCfg.homeDirectory}/.npm";

      # Répertoire global node_modules visible par require()
      NODE_PATH = "${npmGlobalPrefix}/lib/node_modules";
    };

    # -------------------------------------------------------------------
    # 🛤️ Ajout de ~/.npm-global/bin au PATH système
    # -------------------------------------------------------------------
    environment.systemPackages = [
      # Wrapper script de diagnostic pour vérifier la configuration npm globale
      (pkgs.writeShellScriptBin "npm-global-check" ''
        echo "✅ npm global prefix : ${npmGlobalPrefix}"
        echo "✅ npm global bin    : ${npmGlobalPrefix}/bin"
        echo ""
        echo "📦 Paquets installés globalement :"
        ls -1 "${npmGlobalPrefix}/bin" 2>/dev/null || echo "  (aucun)"
      '')
    ];

    # Ajout au PATH système (méthode NixOS native)
    environment.extraInit = ''
      export PATH="${npmGlobalPrefix}/bin:$PATH"
    '';

    # -------------------------------------------------------------------
    # 🧬 Bibliothèques nix-ld supplémentaires pour les binaires npm natifs
    # Les outils npm/npx téléchargent souvent des binaires pré-compilés
    # (esbuild, turbo, swc, sharp, etc.) qui ont besoin de ces libs
    # -------------------------------------------------------------------
    programs.nix-ld.libraries = with pkgs; [
      # Runtime C/C++ (quasiment tous les binaires natifs npm en ont besoin)
      stdenv.cc.cc.lib

      # Crypto & réseau (nécessaires pour https, TLS, grpc)
      openssl

      # Compression (sharp, esbuild, turbo, bun)
      zlib
      brotli

      # Internationalisation (Node.js ICU, Puppeteer, Playwright)
      icu

      # Système (nécessaire pour les binaires qui utilisent dlopen, inotify, etc.)
      util-linux
      libcap
    ];

    # -------------------------------------------------------------------
    # 🐟 Configuration Fish (si utilisé) : ajout du PATH npm global
    # -------------------------------------------------------------------
    programs.fish.interactiveShellInit = lib.mkIf (userCfg.shell == "fish") (lib.mkAfter ''
      # 🟢 npm/npx global : ajout du bin directory au PATH Fish
      if not contains "${npmGlobalPrefix}/bin" $PATH
        fish_add_path --prepend "${npmGlobalPrefix}/bin"
      end
    '');
  };
}
