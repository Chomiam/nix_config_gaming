{ config, lib, pkgs, ... }:

{
  # =========================================================================
  # 💻 PROFIL GPU & INTÉGRATION : MACHINE VIRTUELLE (VM)
  # (QEMU, KVM, Virt-Manager, Proxmox, VMware, VirtualBox)
  # =========================================================================

  config = lib.mkIf (config.chomiamos.hardware.gpu == "vm") {
    # Accélération graphique générique Mesa (Virtio-GPU, SVGA, VBox)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        mesa
        libva
      ];
    };

    # Agent invité QEMU / KVM & SPICE (redimensionnement dynamique et presse-papier partagé)
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;

    # Support VMware
    virtualisation.vmware.guest.enable = lib.mkDefault true;
  };
}
