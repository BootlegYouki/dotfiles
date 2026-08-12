---
title: Agent System Restore Guide
description: Instructions for AI Agents on how to reconstruct this customized Caelestia environment on a fresh OS install.
date: 2026-08-11
---

# Agent System Restore Guide

**ATTENTION AI AGENT:** If you are reading this, you have been tasked with restoring or understanding the custom Caelestia OS environment for the user. This document contains everything you need to know about what was added to the base install and how to restore it.

## Overview of Customizations

This system is built on **Hyprland** using the **Caelestia Shell** (Quickshell-based). The following major custom modifications have been made:

1. **Caelestia Shell Customizations (`~/.config/quickshell/caelestia/`)**:
   - **Romaji & Translation Daemon Integration:** The Media/Lyrics UI (`LyricList.qml`, `LyricsAndSelector.qml`, `Romaji.qml`) was modified to support Japanese Romaji and English translations. The old static 'LyricsInfo' button was replaced with a dynamic Mode Toggle button.
   - **Nightlight Widget:** A custom widget and service for screen color temperature adjustment.

2. **Custom Daemons and Scripts (`~/.local/bin/`)**:
   - **`caelestia-romaji-daemon`**: A multithreaded Python socket daemon that listens at `/run/user/1000/caelestia-romaji.sock`. Uses `googletrans` and `pykakasi` to provide lyrics translation.
   - **`caelestia-romaji`**: Client CLI tool for testing the daemon.
   - **`hypr-gnome-mouse-sync`**: A daemon to sync mouse settings between Hyprland and GNOME schemas.
   - **`nightlight`**: Shell script for toggling night light colors.
   - **`caelestia-wallpaper-shift`**: Script to shift wallpapers.
   - **`rclone`**: Used for syncing ArchBrain to Google Drive.

3. **Systemd User Services (`~/.config/systemd/user/`)**:
   - **`caelestia-romaji.service`**: Manages the romaji daemon.
   - **`hypr-gnome-mouse-sync.service`**: Runs the GNOME mouse sync script in the background.
   - **`archbrain-sync.timer`** & **`archbrain-sync.service`**: Automatically syncs `~/ArchBrain` to Google Drive via `rclone` every 15 minutes.

4. **Terminal & Shell**:
   - **Ghostty** (`~/.config/ghostty/config`) is the terminal emulator of choice.
   - **Fish Shell** (`~/.config/fish/config.fish`) and **Starship** (`~/.config/starship.toml`) are configured for the prompt.
   - **Fastfetch** (`~/.config/fastfetch/config.jsonc`) is customized for system info.

5. **Desktop Environment (Hyprland)**:
   - Custom window rules and workspace hover focus behavior in `~/.config/hypr/hyprland.conf`.
   - Autostart apps managed in `~/.config/autostart/`.

6. **Agent Intelligence (`~/.agents/`)**:
   - Includes custom skills and rules (like the ArchBrain interface skill) so that Antigravity can understand how to read and maintain the user's notes immediately upon restoration.

## Prerequisites (System Packages)
Ensure the following packages are installed via `pacman` or `paru` on Arch Linux before running the restore script:
```bash
sudo pacman -S hyprland fish starship fastfetch socat python python-pip python-virtualenv
```
(Ghostty and Quickshell may need to be built from source or installed from the AUR depending on availability).

## Automated Restoration

To restore all of these configurations on a new machine, execute the `restore_setup.sh` script provided in this directory.

```bash
cd ~/ArchBrain/02-Dotfiles-Configs/
bash restore_setup.sh
```

### What the script does:
1. Extracts `os-configurations-backup.tar.gz` to the user's home directory (restoring all configs and the `~/.agents` directory).
2. Creates a Python virtual environment at `~/.local/share/caelestia-romaji-venv`.
3. Installs the specific Python dependencies (`googletrans==3.1.0a0`, `pykakasi`).
4. Alters the shebang of `caelestia-romaji-daemon` to use the virtual environment's Python.
5. Reloads systemd and enables/starts `caelestia-romaji.service`, `hypr-gnome-mouse-sync.service`, and `archbrain-sync.timer`.
6. Prompts for shell and desktop environment restart.
