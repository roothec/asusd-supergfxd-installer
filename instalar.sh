#!/bin/bash
# Instalador de asusd + supergfxd para laptops ASUS gaming en Ubuntu/Debian
# Versión: asusctl 6.3.7 / supergfxctl 5.2.7
# Compilado para: x86_64, Ubuntu 26.04 LTS, kernel 7.x
# Autor: htor | ASUS F16

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Instalando asusd + supergfxd ==="

# Binarios
echo "[1/6] Instalando binarios..."
sudo install -D -m 0755 "$DIR/binarios/asusd"              /usr/bin/asusd
sudo install -D -m 0755 "$DIR/binarios/asusctl"            /usr/bin/asusctl
sudo install -D -m 0755 "$DIR/binarios/asusd-user"         /usr/bin/asusd-user
sudo install -D -m 0755 "$DIR/binarios/asus-shutdown"      /usr/bin/asus-shutdown
sudo install -D -m 0755 "$DIR/binarios/supergfxd"          /usr/bin/supergfxd
sudo install -D -m 0755 "$DIR/binarios/supergfxctl"        /usr/bin/supergfxctl

# Servicios systemd
echo "[2/6] Instalando servicios systemd..."
sudo install -D -m 0644 "$DIR/servicios/asusd.service"         /usr/lib/systemd/system/asusd.service
sudo install -D -m 0644 "$DIR/servicios/asus-shutdown.service" /usr/lib/systemd/system/asus-shutdown.service
sudo install -D -m 0644 "$DIR/servicios/supergfxd.service"     /usr/lib/systemd/system/supergfxd.service

# Configs D-Bus y udev
echo "[3/6] Instalando configs D-Bus y udev..."
sudo install -D -m 0644 "$DIR/configs/asusd.conf"                  /usr/share/dbus-1/system.d/asusd.conf
sudo install -D -m 0644 "$DIR/configs/org.supergfxctl.Daemon.conf" /usr/share/dbus-1/system.d/org.supergfxctl.Daemon.conf
sudo install -D -m 0644 "$DIR/configs/asusd.rules"                 /usr/lib/udev/rules.d/99-asusd.rules
sudo install -D -m 0644 "$DIR/configs/90-supergfxd-nvidia-pm.rules" /usr/lib/udev/rules.d/90-supergfxd-nvidia-pm.rules
sudo install -D -m 0644 "$DIR/configs/90-nvidia-screen-G05.conf"   /usr/share/X11/xorg.conf.d/90-nvidia-screen-G05.conf

# Datos de aplicación
echo "[4/6] Instalando datos de aplicación..."
sudo install -D -m 0644 "$DIR/datos/aura_support.ron" /usr/share/asusd/aura_support.ron
sudo find "$DIR/datos/anime" -type f -exec bash -c \
    'sudo install -D -m 0644 "$1" "/usr/share/asusd/anime/${1#'"$DIR/datos/anime/"'}"' _ {} \;

# ROG Control Center
echo "[5/6] Instalando ROG Control Center..."
sudo install -D -m 0755 "$DIR/binarios/rog-control-center" /usr/bin/rog-control-center
sudo install -D -m 0644 "$DIR/build/asusctl/rog-control-center/data/rog-control-center.png" \
    /usr/share/icons/hicolor/512x512/apps/rog-control-center.png
sudo gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
sudo install -d -m 0755 /usr/share/applications
sudo tee /usr/share/applications/rog-control-center.desktop >/dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=ROG Control Center
Comment=ASUS ROG laptop control panel
Exec=rog-control-center
Icon=rog-control-center
Categories=Settings;HardwareSettings;
Keywords=asus;rog;tuf;gaming;gpu;aura;rgb;fan;battery;
StartupNotify=true
EOF

# Servicios
echo "[6/6] Habilitando e iniciando servicios..."
sudo systemctl daemon-reload
sudo systemctl enable --now supergfxd.service
sudo systemctl start asusd.service

echo ""
echo "=== Verificación ==="
systemctl is-active asusd.service    && echo "  asusd:     OK" || echo "  asusd:     FALLO"
systemctl is-active supergfxd.service && echo "  supergfxd: OK" || echo "  supergfxd: FALLO"
echo ""
echo "Modo GPU actual: $(supergfxctl -g 2>/dev/null || echo 'no disponible')"
echo ""
echo "Listo. Abre 'rog-control-center' para gestionar tu laptop."
