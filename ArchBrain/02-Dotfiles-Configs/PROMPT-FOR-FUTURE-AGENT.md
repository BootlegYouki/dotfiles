# Prompt for Future AI Agent

*Copy and paste the text below to your new AI Agent when you are on your fresh OS installation:*

***

I have installed a fresh CachyOS with GNOME (default setup), and I want you to completely restore my highly customized desktop environment from my previous system. My entire previous setup (including Hyprland, Caelestia Shell, Ghostty, Fish, custom background scripts, and my Antigravity rules) has been backed up into my `ArchBrain` vault.

Your first task is to read my system documentation so you understand exactly what needs to be restored, how the custom daemons work, and how to transition me away from the default CachyOS GNOME login.

Please read the following guides located in my vault:
1. `~/ArchBrain/02-Dotfiles-Configs/00-AGENT-SYSTEM-RESTORE-GUIDE.md` (This explains the system architecture, custom daemons, systemd services, and how to run the automated restore script)
2. `~/ArchBrain/02-Dotfiles-Configs/01-GNOME-TO-UWSM-HYPRLAND.md` (This explains how to disable GNOME/GDM and configure UWSM to boot Hyprland directly)

Once you have read and understood these two documents, please proceed with executing the restoration. Install any required system packages (using `pacman` or `paru`), execute the `restore_setup.sh` script, and configure UWSM. Do not stop until the system is ready for me to reboot into a fully functional Caelestia Hyprland desktop, completely replacing the default GNOME setup.
