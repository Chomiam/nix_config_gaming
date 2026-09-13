{ config, lib, pkgs, ... }:

{
  # =========================================================================
  # 💻 PROFIL GPU & INTÉGRATION : MACHINE VIRTUELLE (VM)
  # (QEMU, KVM, Virt-Manager, Proxmox, VMware, VirtualBox)
  # =========================================================================

  config = lib.mkMerge [
    # 🌟 Intégration universelle invité (actif quel que soit le profil GPU sélectionné) :
    # Les agents invités QEMU et SPICE sont légers et inoffensifs.
    # Grâce à ConditionVirtualization = "vm", spice-vdagentd est ignoré silencieusement sur machine physique (bare-metal).
    # En environnement virtuel (Virt-Manager, KVM), ils démarrent automatiquement et permettent
    # la résolution dynamique immédiate (notamment 2560x1440 1440p) et le copier-coller bidirectionnel.
    {
      services.qemuGuest.enable = lib.mkDefault true;
      services.spice-vdagentd.enable = lib.mkDefault true;
      systemd.services.spice-vdagentd.unitConfig.ConditionVirtualization = "vm";
    }

    # 🖥️ Profil GPU dédié "vm" (optimisations avancées noyau, initrd et hyperviseurs tiers)
    (lib.mkIf (config.chomiamos.hardware.gpu == "vm") {
      # Noyau Linux standard recommandé pour la stabilité des modules invités
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;

      # Modules noyau VirtIO & QXL précoces dans l'initrd pour un affichage natif immédiat dès le boot
      boot.initrd.kernelModules = [
        "virtio_gpu"
        "virtio_pci"
        "virtio_balloon"
        "virtio_net"
        "virtio_console"
        "qxl"
        "bochs"
      ];

      # Accélération graphique générique Mesa (Virtio-GPU, SVGA, VBoxVGA)
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          mesa
          libva
        ];
      };

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
    })
  ];
}
