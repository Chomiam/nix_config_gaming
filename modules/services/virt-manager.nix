{ config, pkgs, lib, ... }:

let
  cfg = config.chomiamos.services.virtualisation.enable;
  username = config.chomiamos.user.username;

  # ISO VirtIO moderne (Windows 10 / 11 / Server récents)
  virtio-win-iso = pkgs.runCommand "virtio-win-iso" { } ''
    mkdir -p $out/share/virtio-win
    ln -s ${pkgs.virtio-win.src} $out/share/virtio-win/virtio-win.iso
  '';

  # ISO VirtIO 0.1.173 : Dernière version certifiée avec installateur et pilotes compatibles Windows 7 (SHA-1/SHA-2)
  virtio-win-win7-iso-file = pkgs.fetchurl {
    url = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.173-2/virtio-win-0.1.173.iso";
    sha256 = "0i438xsb417l260w62h6s6cpgv3zfb1ifm904pf2zhg67capv8wd";
  };

  virtio-win-win7-iso = pkgs.runCommand "virtio-win-win7-iso" { } ''
    mkdir -p $out/share/virtio-win
    ln -s ${virtio-win-win7-iso-file} $out/share/virtio-win/virtio-win-win7.iso
  '';
in
{
  # =========================================================================
  # 🖥️ VIRT-MANAGER & VIRTUALISATION (KVM / QEMU / LIBVIRT)
  # =========================================================================

  config = lib.mkIf cfg {
    # Ajout automatique de l'utilisateur aux groupes de virtualisation et d'accélération graphique
    users.users."${username}".extraGroups = [ "libvirtd" "kvm" "video" "render" ];

    # Activation et configuration du daemon libvirtd
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [ virtiofsd ];
      };
    };

    # Interface graphique d'administration Virt-Manager
    programs.virt-manager.enable = true;

    # Profils dconf pour Virt-Manager : gestion optimale de la résolution d'écran et du redimensionnement dynamique
    programs.dconf.profiles.user.databases = [
      {
        settings = {
          "org/virt-manager/virt-manager/console" = {
            resize-guest = lib.gvariant.mkInt32 1; # Auto-redimensionnement dynamique de la résolution de l'écran invité selon la taille de la fenêtre
            scaling = lib.gvariant.mkInt32 1;      # Mise à l'échelle uniquement en plein écran (évite le flou d'interpolation en mode fenêtré)
            auto-redirect = true;                  # Redirection automatique des périphériques USB SPICE
          };
          "org/virt-manager/virt-manager/new-vm" = {
            cpu-default = "host-passthrough";      # Passe l'intégralité des instructions CPU de l'hôte (AVX, SSE) pour un bureau invité ultra-fluide
          };
        };
      }
    ];

    # Support de la redirection des périphériques USB via SPICE
    virtualisation.spiceUSBRedirection.enable = true;

    # Réseau virtuel libvirt : interface virbr0 autorisée dans le pare-feu
    networking.firewall.trustedInterfaces = [ "virbr0" ];

    # Raccourcis directs dans /etc
    environment.etc."virtio-win.iso".source = pkgs.virtio-win.src;
    environment.etc."virtio-win-win7.iso".source = virtio-win-win7-iso-file;

    # Placement automatique des ISOs dans le pool de stockage standard de Virt-Manager (/var/lib/libvirt/images)
    system.activationScripts.virtio-win-iso = ''
      mkdir -p /var/lib/libvirt/images
      ln -sf ${pkgs.virtio-win.src} /var/lib/libvirt/images/virtio-win.iso
      ln -sf ${virtio-win-win7-iso-file} /var/lib/libvirt/images/virtio-win-win7.iso
    '';

    # Paquets utilitaires pour la virtualisation, SPICE, réseau & pilotes invités
    environment.systemPackages = with pkgs; [
      # Résolution DHCP / DNS pour le réseau virtuel par défaut de libvirt (virbr0)
      dnsmasq

      # Client d'affichage SPICE / VNC (Remote Viewer)
      virt-viewer
      spice-gtk
      spice-protocol

      # Moteur de rendu graphique 3D OpenGL pour QEMU (VirtIO-GPU VirGL)
      virglrenderer

      # Pilotes VirtIO modernes (Windows 10 / 11)
      virtio-win
      virtio-win-iso

      # Pilotes VirtIO compatibles Windows 7 (v0.1.173)
      virtio-win-win7-iso

      # Daemon pour le partage direct de répertoires hôte <-> invité (Virtio-FS)
      virtiofsd
    ];
  };
}
