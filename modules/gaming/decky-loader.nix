{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.chomiamos.gaming;
  username = config.chomiamos.user.username;
in
{
  # Import du module decky-loader officiel de Jovian-NixOS
  imports = [
    "${inputs.jovian}/modules/decky-loader.nix"
  ];

  config = lib.mkIf (cfg.enable && cfg.deckyLoader && cfg.launchers.steam) {
    # Configuration de Decky Loader (Jovian-NixOS)
    jovian.decky-loader = {
      enable = true;
      package = inputs.jovian.legacyPackages.${pkgs.stdenv.hostPlatform.system}.decky-loader-prerelease;
      user = username;
      extraPackages = with pkgs; [
        curl
        unzip
        jq
        util-linux
        coreutils
        systemd
        psmisc
        lsof
        gdb
        python3
      ];
    };

    # Active automatiquement le débogage CEF dans Steam (requis par Decky Loader pour injecter son interface)
    # ⚠️ Ne JAMAIS faire 'mkdir -p ~/.steam/steam' car Steam exige que ~/.steam/steam soit un lien symbolique vers ~/.local/share/Steam.
    systemd.services.steam-cef-debug = {
      description = "Activer le débogage distant Steam CEF pour Decky Loader";
      serviceConfig = {
        Type = "oneshot";
        User = username;
        ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p ~/.local/share/Steam ~/.steam && if [ -d ~/.steam/steam ] && [ ! -L ~/.steam/steam ]; then rm -rf ~/.steam/steam; fi && if [ ! -e ~/.steam/steam ]; then ln -s ~/.local/share/Steam ~/.steam/steam; fi && touch ~/.local/share/Steam/.cef-enable-remote-debugging'";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
