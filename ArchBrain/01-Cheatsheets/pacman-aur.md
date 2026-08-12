# 📦 Pacman & AUR Cheatsheet

Quick reference for package management on Arch Linux.

---

## 🛠️ Essential Pacman Commands

### Updating System
```bash
sudo pacman -Syu        # Full system sync and upgrade
```

### Installing & Removing Packages
```bash
sudo pacman -S <pkg>    # Install package
sudo pacman -R <pkg>    # Remove package
sudo pacman -Rns <pkg> # Remove package with unneeded dependencies and config backups
```

### Searching & Querying
```bash
pacman -Ss <keyword>    # Search remote repository
pacman -Qs <keyword>    # Search locally installed packages
pacman -Qi <pkg>        # Detailed info on installed package
pacman -Ql <pkg>        # List files installed by package
```

### Maintenance & Cleaning
```bash
sudo pacman -Sc         # Clean old cache files
sudo pacman -Scc        # Clean all cache files
pacman -Qdt             # List orphan packages (unneeded dependencies)
sudo pacman -Rns $(pacman -Qdtq) # Remove all orphan packages
```

---

## 🚀 AUR (Arch User Repository) - `paru`

Your active AUR helper is **`paru`** (written in Rust).

### Using `paru`
```bash
paru                    # Full system update (official repos + AUR packages)
paru -S <aur-pkg>        # Install package from AUR
paru -Ss <keyword>      # Search AUR and official repos
paru -Qe                # List explicitly installed packages
```

