{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.chomiamos.services.blender;
  username = config.chomiamos.user.username;
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # =========================================================================
  # 🎨 BLENDER (SUITE DE MODÉLISATION & ANIMATION 3D - NIXPKGS UNSTABLE)
  # =========================================================================

  config = lib.mkIf cfg.enable {
    users.users."${username}".packages = [
      pkgs-unstable.blender
    ];
  };
}
