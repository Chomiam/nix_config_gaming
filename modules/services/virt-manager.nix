{ pkgs, ... }:

let
  # Package exposant l'ISO officielle virtio-win dans /run/current-system/sw/share/virtio-win/
  virtio-win-iso = pkgs.runCommand "virtio-win-iso" { } ''
    mkdir -p $out/share/virtio-win
    ln -s ${pkgs.virtio-win.src} $out/share/virtio-win/virtio-win.iso
  '';
in
{
  # =========================================================================
  # 🖥️ VIRT-MANAGER & VIRTUALISATION (KVM / QEMU / LIBVIRT)
  # =========================================================================

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

  # Support de la redirection des périphériques USB via SPICE
  virtualisation.spiceUSBRedirection.enable = true;

  # Réseau virtuel libvirt : interface virbr0 autorisée dans le pare-feu
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # Raccourci direct dans /etc/virtio-win.iso
  environment.etc."virtio-win.iso".source = pkgs.virtio-win.src;

  # Placement automatique de l'ISO dans le pool de stockage standard de Virt-Manager
  system.activationScripts.virtio-win-iso = ''
    mkdir -p /var/lib/libvirt/images
    ln -sf ${pkgs.virtio-win.src} /var/lib/libvirt/images/virtio-win.iso
  '';

  # Paquets utilitaires pour la virtualisation, SPICE, réseau & pilotes invités
  environment.systemPackages = with pkgs; [
    # Résolution DHCP / DNS pour le réseau virtuel par défaut de libvirt (virbr0)
    dnsmasq

    # Client d'affichage SPICE / VNC (Remote Viewer)
    virt-viewer
    spice-gtk

    # Pilotes VirtIO et outils invités Windows (Windows 7 / 10 / 11)
    virtio-win
    virtio-win-iso

    # Daemon pour le partage direct de répertoires hôte <-> invité (Virtio-FS)
    virtiofsd
  ];
}
