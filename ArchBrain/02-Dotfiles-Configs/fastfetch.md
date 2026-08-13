# 🎨 Fastfetch Configuration: Caelestia Neon Cyan & White ASCII Art

- **Config Path**: [`config.jsonc`](file:///home/youki/.config/fastfetch/config.jsonc)
- **Emblem**: Two-tone Caelestia block ASCII logo:
  - `${c6}`: Lighter Neon Cyan (`RGB: 103, 232, 249` / `#67e8f9`).
  - `${c7}`: Bright White (`\u001b[97m`).
- **Layout & Alignment**:
  - Top star `▄` aligned 2 spaces right above `▄███▄`.
  - `logo.padding.top`: `1` (1 line of top margin spacing).
  - 4 `break` modules for centered vertical specs alignment.

---

## 📁 Source Code (`~/.config/fastfetch/config.jsonc`)

```jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "data",
    "source": "\u001b[38;2;103;232;249m                                 ▄\n \u001b[38;2;103;232;249m                              ▄███▄\n \u001b[38;2;103;232;249m                ▄▄███████▄▄    ▀█▀   ▄\n \u001b[38;2;103;232;249m             ▄███████▀▀▀▀▀██▄       ▀█▀\n \u001b[38;2;103;232;249m            █████▀▀\n \u001b[38;2;103;232;249m          ▄█████\u001b[97m         ▄▄▄▄▄████████▄▄\n \u001b[38;2;103;232;249m         ▄██▀▀▀\u001b[97m▄▄▄▄▄▄█████████▀▀▀▀▀▀████▀\n \u001b[97m        ▄▄▄▄██████████▀▀▀▀▀        ▀▀▀\n \u001b[97m   ▄▄███████████▀▀\n \u001b[97m  █████████████\n \u001b[97m   ▀▀▀██████████▄             ▄██\u001b[38;2;103;232;249m   ██\n \u001b[97m         ▀▀███████▄▄▄     ▄▄▄██▀\n \u001b[97m             ▀███████████████▀\n \u001b[97m                ▀▀▀██████▀▀▀\u001b[0m",
    "padding": {
      "top": 1,
      "right": 4
    }
  },
  "display": {
    "color": {
      "keys": "38;2;103;232;249",
      "title": "bold_white"
    }
  },
  "modules": [
    "break",
    "break",
    "break",
    "break",
    {
      "type": "os",
      "format": "{3} {12}"
    },
    {
      "type": "host",
      "format": "{2}"
    },
    {
      "type": "kernel",
      "format": "{1} {2}"
    },
    "uptime",
    "shell",
    "wm",
    "terminal",
    {
      "type": "cpu",
      "format": "{1} ({3})"
    },
    {
      "type": "gpu",
      "format": "AMD Radeon Vega Graphics"
    }
  ]
}
```

---

## Related Notes
- [[fish-and-starship]]
- [[desktop-caelestia-hyprland]]
