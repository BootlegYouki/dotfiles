# 🎵 Spicetify & Marketplace Setup

Instructions for managing Spicetify with Marketplace integration and disabled update checks on CachyOS / Arch Linux.

---

## 🛠️ Permissions Setup

Spicetify requires write permissions to the Spotify directory in order to inject themes and extensions:

```bash
sudo chmod -R a+rwX /opt/spotify
```

---

## ⚙️ Spicetify Configuration & Marketplace

Enable the Marketplace custom app in Spicetify:

```bash
spicetify config custom_apps marketplace
```

Set current theme to marketplace (required for installing themes directly via the Marketplace UI):

```bash
spicetify config current_theme marketplace
```

Disable automatic update checking for Spicetify:

```bash
spicetify config check_spicetify_update 0
```

Apply changes and backup Spotify client:

```bash
spicetify backup apply
```

> [!NOTE]
> Spotify package updates are managed by Arch Linux package manager (`pacman`). Automatic in-app executable updates are not applicable on Linux package installations.

---

## 🔄 Automatic Spicetify Restoration (Pacman Hook)

To prevent Spotify package updates from wiping out Spicetify customizations, a Pacman post-transaction hook is configured at `/etc/pacman.d/hooks/spicetify.hook`. 

Whenever Spotify is updated or installed, this hook runs `/usr/local/bin/spicetify-pacman-hook.sh` which:
1. Restores directory write permissions: `chmod -R a+rwX /opt/spotify`
2. Re-applies Spicetify settings as user `youki`: `spicetify apply`

---

## 📌 Pinning Spotify Package (Preventing Updates)

If you want to prevent Spotify from updating entirely during system upgrades (to avoid breaking changes and maintain Spicetify compatibility), Spotify has been added to the `IgnorePkg` directive in `/etc/pacman.conf`:

```ini
IgnorePkg = spotify
```

This prevents pacman from updating Spotify unless manually forced (`pacman -S spotify`).

---

## 🔗 Related Notes
- [[installed-applications]]
