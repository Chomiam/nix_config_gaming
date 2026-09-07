{ pkgs, ... }:

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

  # Paquets utilitaires pour la virtualisation, SPICE, réseau & pilotes invités
  environment.systemPackages = with pkgs; [
    # Résolution DHCP / DNS pour le réseau virtuel par défaut de libvirt (virbr0)
    dnsmasq

    # Client d'affichage SPICE / VNC (Remote Viewer)
    virt-viewer
    spice-gtk

    # Pilotes VirtIO et outils invités Windows (Windows 7 / 10 / 11)
    # Fournit l'ISO complète dans /run/current-system/sw/share/virtio-win/virtio-win.iso
    virtio-win

    # Daemon pour le partage direct de répertoires hôte <-> invité (Virtio-FS)
    virtiofsd
  ];
}
