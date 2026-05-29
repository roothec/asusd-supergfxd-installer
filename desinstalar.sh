#!/bin/bash
# Desinstalador de asusd + supergfxd
# Solo elimina lo que instalo instalar.sh — no toca drivers ni el sistema

set -e

echo "=== Desinstalando asusd + supergfxd ==="

# Si fue instalado como paquete .deb, usar apt para desinstalar limpiamente
if dpkg -s asusd-supergfxd-installer &>/dev/null; then
    echo "Paquete .deb detectado — usando apt remove..."
    sudo apt remove -y asusd-supergfxd-installer
    echo "Desinstalación completa."
    exit 0
fi

echo "[1/5] Deteniendo servicios..."
sudo systemctl kill --signal=SIGKILL asusd.service supergfxd.service asus-shutdown.service 2>/dev/null || true
sudo systemctl stop asusd.service supergfxd.service asus-shutdown.service --timeout=3 2>/dev/null || true
sudo systemctl disable supergfxd.service 2>/dev/null || true

echo "[2/5] Eliminando binarios..."
sudo rm -f /usr/bin/{asusd,asusctl,asusd-user,asus-shutdown,rog-control-center,supergfxd,supergfxctl}

echo "[3/5] Eliminando servicios systemd..."
sudo rm -f /usr/lib/systemd/system/{asusd,asus-shutdown,supergfxd}.service

echo "[4/5] Eliminando configs D-Bus, udev y xorg..."
sudo rm -f /usr/share/dbus-1/system.d/{asusd.conf,org.supergfxctl.Daemon.conf}
sudo rm -f /usr/lib/udev/rules.d/{99-asusd,90-supergfxd-nvidia-pm}.rules
sudo rm -f /usr/share/X11/xorg.conf.d/90-nvidia-screen-G05.conf
sudo rm -f /usr/share/applications/rog-control-center.desktop
sudo rm -f /usr/share/icons/hicolor/512x512/apps/rog-control-center.png
sudo rm -rf /usr/share/asusd

echo "[5/5] Recargando systemd y udev..."
sudo systemctl daemon-reload
sudo udevadm control --reload-rules

echo ""
echo "Desinstalación completa."
echo "Tu configuración en /etc/asusd/ y los drivers NVIDIA no fueron modificados."
