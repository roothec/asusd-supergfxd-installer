# asusd-supergfxd-installer

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-yellow?logo=linux&logoColor=white)
![Arch](https://img.shields.io/badge/arch-x86__64-lightgrey)
![Rust](https://img.shields.io/badge/built_with-Rust-orange?logo=rust&logoColor=white)
![Bash](https://img.shields.io/badge/installer-Bash-4EAA25?logo=gnubash&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-12+-A81D33?logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04+-E95420?logo=ubuntu&logoColor=white)
![systemd](https://img.shields.io/badge/init-systemd-black?logo=systemd&logoColor=white)
![NVIDIA](https://img.shields.io/badge/GPU-NVIDIA-76B900?logo=nvidia&logoColor=white)
![ASUS ROG](https://img.shields.io/badge/ASUS-ROG%20%7C%20TUF-CC0000?logo=asus&logoColor=white)

Instalador de binarios precompilados para **asusd** y **supergfxd** en laptops ASUS gaming con Linux (Ubuntu/Debian).

Un solo script instala los daemons, servicios systemd, reglas udev, permisos D-Bus y la GUI ROG Control Center — sin necesidad de compilar ni añadir PPAs externos.

## ¿Qué son asusd y supergfxd?

| Daemon | Qué hace |
|---|---|
| **asusd** | Daemon principal ASUS: controla perfiles de rendimiento, límite de batería, teclado RGB (Aura), pantalla AniMatrix y eventos de hardware |
| **supergfxd** | Daemon de GPU switching: alterna entre Intel integrada, modo Hybrid y NVIDIA exclusivo sin reinstalar drivers |

## Versiones incluidas

| Componente | Versión | Fuente |
|---|---|---|
| asusctl / asusd / rog-control-center | 6.3.7 | https://gitlab.com/asus-linux/asusctl |
| supergfxctl / supergfxd | 5.2.7 | https://gitlab.com/asus-linux/supergfxctl |

**Compilado en:** ASUS TUF F16 (FX607VJ), Intel Core 5 210H, Ubuntu 26.04 LTS, kernel 7.0.0-15-generic, x86\_64
**Compatibilidad:** cualquier x86\_64 con Ubuntu 22.04+ / Debian 12+

---

## Compatibilidad

Los binarios son ejecutables ELF x86_64 compilados desde código Rust. Funcionan en **cualquier distribución Linux x86_64 con systemd y glibc compatible** — no son exclusivos de Debian/Ubuntu.

| Distribución | Compatible | Notas |
|---|---|---|
| Ubuntu 22.04 / 24.04 / 26.04 | ✓ | probado |
| Kubuntu / Pop!\_OS / Mint / Zorin | ✓ | basadas en Ubuntu |
| Debian 12+ | ✓ | compatible |
| Fedora 40+ | ✓ | glibc reciente |
| Arch / Manjaro / EndeavourOS | ✓ | rolling, siempre actualizado |
| openSUSE Tumbleweed | ✓ | rolling |
| openSUSE Leap | depende | verificar versión de glibc |
| ARM64 (Raspberry Pi, Mac M1) | ✗ | arquitectura diferente |

> **Nota:** Las instrucciones de dependencias usan `apt` (Debian/Ubuntu). En otras distros sustituir por el gestor de paquetes correspondiente: `dnf` en Fedora, `pacman` en Arch, `zypper` en openSUSE.

Si los binarios no arrancan en tu sistema, compílalos directamente desde `build/` — ver sección **Recompilar desde fuente**.

---

## Hardware soportado

Laptops ASUS con `asus-nb-wmi` en el kernel:

- ROG (Strix, Zephyrus, Flow, Scar)
- TUF Gaming
- ProArt Studiobook
- Vivobook Pro / S

Para GPU switching (supergfxd) se requiere dGPU NVIDIA.

---

## Requisitos previos

```bash
# Driver NVIDIA (ajustar versión según kernel)
sudo apt install nvidia-driver-595

# Dependencias de runtime
sudo apt install libudev1 libgcc-s1
```

Kernel mínimo:
- `5.17+` para funciones básicas
- `6.1+` para control de batería y perfiles avanzados
- `6.19+` para control TDP (Raptor/Meteor Lake)

---

## Instalación

### Opción A — Paquete .deb (recomendado, Debian/Ubuntu)

```bash
sudo apt install ./asusd-supergfxd-installer_6.3.7_amd64.deb
```

Instala todo de una vez (binarios, servicios, GPU Mode Selector y la configuración con el fix de `hotplug_type=Asus`). Para desinstalar limpio: `sudo apt remove asusd-supergfxd-installer`.

> ⚠️ Si la instalación cambia `hotplug_type` en `/etc/supergfxd.conf`, **reinicia** para que el modo Integrated funcione sin colgar el daemon (ver [Solución de problemas](#supergfxd-se-cuelga-al-cambiar-a-integrated)).

### Opción B — Script manual (cualquier distro con systemd)

```bash
chmod +x instalar.sh
./instalar.sh
```

El script realiza 8 pasos automáticamente:

1. Instala los binarios del sistema en `/usr/bin/`
2. Instala los servicios systemd
3. Instala las reglas udev y permisos D-Bus
4. Instala los datos de aplicación (layouts RGB, AniMatrix)
5. Instala el **GPU Mode Selector** (`/usr/local/bin/gpu-mode.sh`, lanzador en el menú y regla sudoers NOPASSWD)
6. Instala ROG Control Center con entrada en el menú del sistema
7. Configura `/etc/supergfxd.conf` forzando `hotplug_type=Asus` (con backup si ya existía)
8. Habilita e inicia los servicios

---

## Estructura del repositorio

```
asusd-supergfxd-installer/
├── instalar.sh             ← script de instalación automática
├── desinstalar.sh          ← script de desinstalación (detecta .deb o instalación manual)
├── build_deb.sh            ← genera el paquete .deb
├── gpu-mode.sh             ← GPU Mode Selector (menú interactivo de modo GPU)
├── asusd-supergfxd-installer_6.3.7_amd64.deb  ← paquete precompilado
├── binarios/               ← ejecutables precompilados (x86_64)
│   ├── asusd               daemon principal ASUS
│   ├── asusctl             CLI para controlar asusd
│   ├── asusd-user          daemon de sesión de usuario
│   ├── asus-shutdown       manejador de apagado
│   ├── rog-control-center  GUI gráfica (GTK3, Wayland)
│   ├── supergfxd           daemon de GPU switching
│   └── supergfxctl         CLI para cambiar modo GPU
├── servicios/              ← units de systemd
│   ├── asusd.service
│   ├── asus-shutdown.service
│   └── supergfxd.service
├── configs/                ← configuración de sistema
│   ├── asusd.conf                    permisos D-Bus para asusd
│   ├── org.supergfxctl.Daemon.conf   permisos D-Bus para supergfxd
│   ├── asusd.rules                   regla udev (auto-inicia asusd)
│   ├── 90-supergfxd-nvidia-pm.rules  power management NVIDIA
│   ├── 90-nvidia-screen-G05.conf     xorg config para ASUS
│   └── supergfxd.conf                plantilla (mode=Hybrid + hotplug_type=Asus)
├── datos/                  ← datos de aplicación
│   ├── aura_support.ron    layouts de teclados RGB soportados
│   └── anime/              animaciones para pantalla AniMatrix
└── build/                  ← código fuente (para recompilar)
    ├── asusctl/
    └── supergfxctl/
```

---

## Uso básico

### ROG Control Center (GUI)

```bash
rog-control-center
```

### GPU Mode Selector (menú interactivo)

Forma más sencilla de cambiar de modo GPU. Busca **"GPU Mode Selector"** en el menú de aplicaciones, o desde terminal:

```bash
sudo gpu-mode.sh
```

Muestra el modo actual y deja elegir entre Integrated / Hybrid / AsusMuxDgpu. Usa `timeout` en todas las llamadas a `supergfxctl` (para que un cuelgue del daemon nunca congele la ventana) y reinicia automáticamente tras aplicar el cambio (cancelable con Ctrl+C).

### GPU switching (manual)

```bash
supergfxctl -g                       # ver modo actual
supergfxctl -m Integrated            # solo Intel (máxima batería)
supergfxctl -m Hybrid                # Intel + NVIDIA on-demand (recomendado)
supergfxctl -m AsusMuxDgpu           # NVIDIA exclusivo (máximo rendimiento)
```

### Perfiles de rendimiento

```bash
asusctl profile -l          # listar perfiles
asusctl profile -p Balanced # aplicar perfil
```

### Control de batería

```bash
asusctl -c 80   # limitar carga al 80%
```

### Teclado RGB

```bash
asusctl aura -e static --red 255 --green 0 --blue 0
asusctl aura -e breathe
asusctl aura -e off
```

---

## Recompilar desde fuente

Si los binarios no son compatibles con tu sistema:

```bash
sudo apt install rustup build-essential cmake clang \
    libclang-dev libudev-dev libfontconfig-dev \
    libxkbcommon-dev libgtk-3-dev

rustup default stable

cd build/asusctl
cargo build --release --locked

cd ../supergfxctl
cargo build --features "daemon cli" --release

cd ../..
./instalar.sh
```

---

## Desinstalar

El script `desinstalar.sh` detecta automáticamente si instalaste por `.deb` o manualmente y limpia todo (binarios, servicios, GPU Mode Selector, sudoers y `/etc/supergfxd.conf`):

```bash
./desinstalar.sh
```

Si instalaste por `.deb` también puedes usar directamente:

```bash
sudo apt remove asusd-supergfxd-installer
```

> Tu configuración en `/etc/asusd/` y los drivers NVIDIA no se modifican.

---

## Solución de problemas

### asusd no arranca

```bash
journalctl -u asusd -b --no-pager | tail -30
```

Causa común: falta `/etc/asusd/` — se crea automáticamente en el primer arranque.

### supergfxd no arranca

```bash
sudo systemctl enable supergfxd.service
sudo systemctl start supergfxd.service
```

### supergfxd se cuelga al cambiar a Integrated

**Síntoma:** al pasar a modo Integrated, `supergfxctl` se queda colgado (cualquier comando, incluso `-g`, no responde) y el daemon queda atascado en el kernel desvinculando la NVIDIA (no muere ni con `SIGKILL`).

**Causa:** `/etc/supergfxd.conf` sin `"hotplug_type": "Asus"`. Sin ese valor, el daemon intenta desvincular la dGPU de forma incompatible con las laptops ASUS y se clava.

**Solución:** asegúrate de que `/etc/supergfxd.conf` tenga `hotplug_type` en `Asus` y **reinicia**:

```bash
grep hotplug_type /etc/supergfxd.conf   # debe mostrar "Asus"
sudo reboot
```

El instalador (`.deb` y `instalar.sh`) ya aplica este valor automáticamente. El **GPU Mode Selector** además protege con `timeout` para que un cuelgue nunca congele la ventana.

### Pantalla negra después de cambiar GPU

Desde Live USB, restaurar un modo seguro (Hybrid + hotplug Asus):

```bash
sudo mount /dev/nvme0n1p5 /mnt
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys
sudo chroot /mnt

cat > /etc/supergfxd.conf << 'EOF'
{"mode":"Hybrid","vfio_enable":false,"vfio_save":false,"always_reboot":false,"no_logind":true,"logout_timeout_s":180,"hotplug_type":"Asus"}
EOF

exit && sudo reboot
```

### Servicios no sobreviven al reboot

`asusd` se activa por udev al detectar hardware ASUS — no necesita `enable`.
`supergfxd` sí necesita estar habilitado: `sudo systemctl enable supergfxd.service`

---

## Capturas de pantalla

| System Control | Keyboard Aura |
|---|---|
| ![System Control](screenshots/01-system-control.png) | ![Keyboard Aura](screenshots/02-keyboard-aura.png) |

| Fan Curves | GPU Configuration |
|---|---|
| ![Fan Curves](screenshots/03-fan-curves.png) | ![GPU Configuration](screenshots/04-gpu-configuration.png) |

![App Settings](screenshots/05-app-settings.png)

---

## Licencia

MIT License — Copyright (c) 2026 **roothec**

Ver [LICENSE](LICENSE) para el texto completo.

---

## Autor

Creado por **[roothec](https://github.com/roothec)**
Compilado y probado en ASUS TUF Gaming F16 (FX607VJ) — Ubuntu 26.04 LTS, kernel 7.0.0-15-generic.
