#!/bin/bash

# Requiere root
if [[ $EUID -ne 0 ]]; then
    echo "Ejecutar como root: sudo $0"
    exit 1
fi

# Llama a supergfxctl con un límite de tiempo para que un cuelgue del
# daemon (arrancando o a mitad de un cambio) nunca congele la ventana.
sgfx() {
    timeout 10 supergfxctl "$@"
}

# Consulta el modo actual sin bloquear. Si el daemon no responde a
# tiempo (exit 124 de timeout) o falla, mostramos "Desconocido".
CURRENT=$(sgfx --get 2>/dev/null) || CURRENT="Desconocido"
[[ -z "$CURRENT" ]] && CURRENT="Desconocido"

clear
echo "==============================="
echo "   Selector de modo GPU ASUS   "
echo "==============================="
echo ""
echo "Modo actual: $CURRENT"
echo ""
echo "  1) Integrated   — Solo iGPU  (máx. batería)"
echo "  2) Hybrid       — iGPU + dGPU bajo demanda"
echo "  3) AsusMuxDgpu  — Solo dGPU  (máx. rendimiento)"
echo "  0) Salir"
echo ""
read -rp "Elige un modo [0-3]: " OPCION

case "$OPCION" in
    1) MODO="Integrated" ;;
    2) MODO="Hybrid" ;;
    3) MODO="AsusMuxDgpu" ;;
    0) echo "Cancelado."; exit 0 ;;
    *) echo "Opción inválida."; exit 1 ;;
esac

if [[ "$MODO" == "$CURRENT" ]]; then
    echo ""
    echo "Ya estás en modo $MODO. No se requiere cambio."
    exit 0
fi

echo ""
echo "Aplicando modo: $MODO ..."
if ! sgfx --mode "$MODO"; then
    echo "Error al aplicar el modo. Verifica que supergfxd esté corriendo:"
    echo "  systemctl status supergfxd"
    exit 1
fi

echo ""
echo "Modo $MODO aplicado. Reiniciando en 5 segundos..."
echo "(Ctrl+C para cancelar el reinicio — el modo ya quedó aplicado)"

# Si el usuario cancela durante la cuenta atrás, salimos sin reiniciar.
# El modo nuevo ya está guardado y se aplicará en el próximo arranque.
trap 'echo; echo "Reinicio cancelado. Reinicia manualmente para completar el cambio."; exit 0' INT

sleep 5
trap - INT
[[ -n "$SUDO_USER" ]] && loginctl terminate-user "$SUDO_USER"
sleep 2
reboot
