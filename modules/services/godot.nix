{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.chomiamos.services.godot;
  username = config.chomiamos.user.username;
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # =========================================================================
  # 🎮 GODOT ENGINE (MOTEUR DE JEU 2D/3D - NIXPKGS UNSTABLE)
  # =========================================================================

  config = lib.mkIf cfg.enable {
    users.users."${username}".packages = [
      pkgs-unstable.godot
    ];
  };
}
