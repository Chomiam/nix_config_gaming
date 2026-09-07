{ pkgs, ... }:

{
  # =========================================================================
  # 📦 GNOME BOXES & VIRTUALISATION (KVM / QEMU / LIBVIRT)
  # =========================================================================

  # Daemon de virtualisation libvirtd (requis pour l'exécution fluide des VMs)
  virtualisation.libvirtd.enable = true;

  # Support de la redirection des périphériques USB via SPICE
  virtualisation.spiceUSBRedirection.enable = true;

  # Application GNOME Boxes
  environment.systemPackages = with pkgs; [
    gnome-boxes
  ];
}
