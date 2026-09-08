{ config, pkgs, lib, inputs, vars, ... }:

{
  # =========================================================================
  # 🖥️ HÔTE DESKTOP : ASSEMBLAGE MODULAIRE CHOMIAMOS
  # =========================================================================

  imports = [
    # Configuration matérielle spécifique à cette machine
    ./hardware-configuration.nix
    ./mount.nix

    # Architecture modulaire chomiamos
    ../../modules
  ];

  # =========================================================================
  # ⚙️ CONFIGURATION DES OPTIONS DU SYSTÈME (ALIMENTÉE PAR VARS.NIX)
  # =========================================================================
  chomiamos = {
    hostName = vars.hostName;
    timeZone = vars.timeZone;
    defaultLocale = vars.defaultLocale;
    stateVersion = vars.stateVersion;

    user = {
      username = vars.user.username;
      fullName = vars.user.fullName;
      homeDirectory = vars.user.homeDirectory;
      shell = vars.user.shell;
      extraGroups = vars.user.extraGroups;
    };

    firewall.enable = if builtins.isBool (vars.firewall or false) then vars.firewall else (vars.firewall.enable or false);

    hardware = {
      gpu = vars.gpuDriver;
      steeringWheels.enable = vars.steeringWheelSupport or true;
    };

    desktop = {
      env = vars.desktopEnv;
    };

    browser = vars.browser;

    gaming = {
      enable = vars.gaming.enable or true;
      deckyLoader = vars.gaming.deckyLoader or false;
      geforceNow = vars.gaming.geforceNow or true;
      mountGamesDisk = vars.gaming.mountGamesDisk or true;
    };

    services = {
      virtualisation.enable = vars.virtualisation.enable or false;
      samba.enable = true;
      docker.enable = true;
      nix-ld.enable = true;
      flatpak.enable = true;
      obs.enable = true;
      neovim.enable = true;
      blender.enable = vars.blender or false;
      godot.enable = vars.godot or false;
      davinciResolve.version = vars.davinciResolve or "none";
      aiSuite = {
        enable = vars.aiSuite.enable or false;
        rocmOverrideGfx = vars.aiSuite.rocmOverrideGfx or "12.0.1";
        keepAlive = vars.aiSuite.keepAlive or "0s";
        openWebUiPort = vars.aiSuite.openWebUiPort or 8080;
        searxPort = vars.aiSuite.searxPort or 8888;
      };
    };
  };
}
