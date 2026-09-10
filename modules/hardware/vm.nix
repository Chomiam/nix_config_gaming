{ config, lib, pkgs, ... }:

{
  # =========================================================================
  # 💻 PROFIL GPU & INTÉGRATION : MACHINE VIRTUELLE (VM)
  # (QEMU, KVM, Virt-Manager, Proxmox, VMware, VirtualBox)
  # =========================================================================

  config = lib.mkIf (config.chomiamos.hardware.gpu == "vm") {
    # Noyau Linux standard recommandé pour la stabilité des modules invités
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;

    # Accélération graphique générique Mesa (Virtio-GPU, SVGA, VBoxVGA)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        mesa
        libva
      ];
    };

    # Agent invité QEMU / KVM & SPICE (redimensionnement dynamique de résolution et presse-papier partagé)
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;

    # Support VMware (open-vm-tools & auto-resize)
    virtualisation.vmware.guest.enable = lib.mkDefault true;

    # Support VirtualBox (VBoxClient, auto-resize, presse-papier & glisser-déposer)
    virtualisation.virtualbox.guest = {
      enable = lib.mkDefault true;
      dragAndDrop = true;
      clipboard = true;
    };

    # Support Microsoft Hyper-V
    virtualisation.hypervGuest.enable = lib.mkDefault true;

    # Utilitaires de gestion d'affichage et résolution
    environment.systemPackages = with pkgs; [
      spice-vdagent
      xrandr
      mesa-demos
    ];
  };
}
