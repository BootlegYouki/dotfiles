# 💻 Hardware & Kernel Profile

Comprehensive hardware breakdown for this CachyOS machine.

---

## ⚡ Hardware Specs

| Component | Specification |
| :--- | :--- |
| **Processor (CPU)** | AMD Ryzen 5 5500U with Radeon Graphics (6 Cores / 12 Threads) |
| **Graphics (GPU)** | Integrated AMD Radeon Graphics (`amdgpu` driver, Lucienne rev c2) |
| **Memory (RAM)** | 14 GiB DDR4 |
| **Storage** | 256 GiB NVMe SSD (`/dev/nvme0n1p2`) |
| **Kernel** | `7.1.6-1-cachyos` (PREEMPT_DYNAMIC x86_64) |
| **Architecture Optimization** | `x86-64-v3` / `x86-64-v4` CachyOS repositories |

---

## 🛠️ Hardware Diagnostic Commands

### Check Kernel & CPU
```bash
uname -a
lscpu
```

### Check Memory & Swap Usage
```bash
free -h
```

### Check GPU & Driver Info
```bash
lspci -k | grep -A 3 -i -E "vga|3d"
```

### Check Disk Space & NVMe Health
```bash
df -h /
```
