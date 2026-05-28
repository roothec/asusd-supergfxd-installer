#!/bin/bash
# Construye el paquete .deb de asusd + supergfxd
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG="asusd-supergfxd-installer"
VERSION="6.3.7"
ARCH="amd64"
BUILD="$DIR/deb-build/$PKG"

echo "=== Construyendo $PKG-${VERSION}_${ARCH}.deb ==="

# ── Limpiar build anterior ────────────────────────────────────────────────────
rm -rf "$DIR/deb-build"

# ── Estructura de directorios ─────────────────────────────────────────────────
mkdir -p "$BUILD/DEBIAN"
mkdir -p "$BUILD/usr/bin"
mkdir -p "$BUILD/usr/lib/systemd/system"
mkdir -p "$BUILD/usr/lib/udev/rules.d"
mkdir -p "$BUILD/usr/share/dbus-1/system.d"
mkdir -p "$BUILD/usr/share/X11/xorg.conf.d"
mkdir -p "$BUILD/usr/share/asusd"
mkdir -p "$BUILD/usr/share/applications"

# ── Binarios ──────────────────────────────────────────────────────────────────
echo "[1/6] Copiando binarios..."
install -m 0755 "$DIR/binarios/asusd"              "$BUILD/usr/bin/asusd"
install -m 0755 "$DIR/binarios/asusctl"            "$BUILD/usr/bin/asusctl"
install -m 0755 "$DIR/binarios/asusd-user"         "$BUILD/usr/bin/asusd-user"
install -m 0755 "$DIR/binarios/asus-shutdown"      "$BUILD/usr/bin/asus-shutdown"
install -m 0755 "$DIR/binarios/rog-control-center" "$BUILD/usr/bin/rog-control-center"
install -m 0755 "$DIR/binarios/supergfxd"          "$BUILD/usr/bin/supergfxd"
install -m 0755 "$DIR/binarios/supergfxctl"        "$BUILD/usr/bin/supergfxctl"

# ── Servicios systemd ─────────────────────────────────────────────────────────
echo "[2/6] Copiando servicios systemd..."
install -m 0644 "$DIR/servicios/asusd.service"         "$BUILD/usr/lib/systemd/system/asusd.service"
install -m 0644 "$DIR/servicios/asus-shutdown.service" "$BUILD/usr/lib/systemd/system/asus-shutdown.service"
install -m 0644 "$DIR/servicios/supergfxd.service"     "$BUILD/usr/lib/systemd/system/supergfxd.service"

# ── Configs D-Bus y udev ──────────────────────────────────────────────────────
echo "[3/6] Copiando configs D-Bus y udev..."
install -m 0644 "$DIR/configs/asusd.conf"                   "$BUILD/usr/share/dbus-1/system.d/asusd.conf"
install -m 0644 "$DIR/configs/org.supergfxctl.Daemon.conf"  "$BUILD/usr/share/dbus-1/system.d/org.supergfxctl.Daemon.conf"
install -m 0644 "$DIR/configs/asusd.rules"                  "$BUILD/usr/lib/udev/rules.d/99-asusd.rules"
install -m 0644 "$DIR/configs/90-supergfxd-nvidia-pm.rules" "$BUILD/usr/lib/udev/rules.d/90-supergfxd-nvidia-pm.rules"
install -m 0644 "$DIR/configs/90-nvidia-screen-G05.conf"    "$BUILD/usr/share/X11/xorg.conf.d/90-nvidia-screen-G05.conf"

# ── Datos de aplicación ───────────────────────────────────────────────────────
echo "[4/6] Copiando datos de aplicación..."
install -m 0644 "$DIR/datos/aura_support.ron" "$BUILD/usr/share/asusd/aura_support.ron"
cp -r "$DIR/datos/anime" "$BUILD/usr/share/asusd/anime"

# ── ROG Control Center desktop entry ─────────────────────────────────────────
echo "[5/6] Creando entrada .desktop..."
cat > "$BUILD/usr/share/applications/rog-control-center.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=ROG Control Center
Comment=ASUS ROG laptop control panel
Exec=rog-control-center
Icon=input-gaming
Categories=Settings;HardwareSettings;
Keywords=asus;rog;tuf;gaming;gpu;aura;rgb;fan;battery;
StartupNotify=true
EOF

# ── DEBIAN/control ────────────────────────────────────────────────────────────
echo "[6/6] Generando metadatos del paquete..."
cat > "$BUILD/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Architecture: $ARCH
Maintainer: htor <tecnologia@duaga.com>
Depends: libudev1, libgcc-s1
Description: asusd + supergfxd prebuilt installer for ASUS gaming Linux
 Precompiled binaries of asusctl $VERSION and supergfxd 5.2.7 for ASUS
 gaming laptops. Includes asusd, supergfxd, asusctl, supergfxctl and
 ROG Control Center with systemd services, udev rules and D-Bus config.
 Compatible with Ubuntu 22.04+ / Debian 12+ on x86_64.
EOF

# ── DEBIAN/postinst ───────────────────────────────────────────────────────────
cat > "$BUILD/DEBIAN/postinst" <<'EOF'
#!/bin/bash
set -e
systemctl daemon-reload
systemctl enable --now supergfxd.service
systemctl start asusd.service || true
udevadm control --reload-rules
EOF
chmod 0755 "$BUILD/DEBIAN/postinst"

# ── DEBIAN/prerm ──────────────────────────────────────────────────────────────
cat > "$BUILD/DEBIAN/prerm" <<'EOF'
#!/bin/bash
set -e
systemctl kill --signal=SIGKILL asusd.service supergfxd.service 2>/dev/null || true
systemctl stop asusd.service supergfxd.service --timeout=3 2>/dev/null || true
systemctl disable supergfxd.service 2>/dev/null || true
EOF
chmod 0755 "$BUILD/DEBIAN/prerm"

# ── Construir .deb ────────────────────────────────────────────────────────────
dpkg-deb --build --root-owner-group "$BUILD" "$DIR/${PKG}_${VERSION}_${ARCH}.deb"

rm -rf "$DIR/deb-build"

echo ""
echo "Paquete generado: ${PKG}_${VERSION}_${ARCH}.deb"
echo ""
echo "Para instalar:     sudo dpkg -i ${PKG}_${VERSION}_${ARCH}.deb"
echo "Para desinstalar:  sudo apt remove $PKG"
