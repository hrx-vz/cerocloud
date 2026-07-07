#!/bin/bash
# ==============================================================================
# CeroCloud - Deployment Core & Environment Provisioner
# ==============================================================================

# --- COLORES --
C_CYAN="\e[36m"
C_BLUE="\e[34m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_WHITE="\e[97m"
C_DIM="\e[2m"
C_RESET="\e[0m"
C_BOLD="\e[1m"

# --- ENLACES DE REPOSITORIO ---
URL_INDEX="https://raw.githubusercontent.com/hrx-vz/hrx-vz.github.io/refs/heads/main/index.html"
URL_ACCOUNT="https://raw.githubusercontent.com/hrx-vz/hrx-vz.github.io/refs/heads/main/account.html"
URL_MANIFEST="https://raw.githubusercontent.com/hrx-vz/hrx-vz.github.io/refs/heads/main/manifest.json"
URL_SW="https://raw.githubusercontent.com/hrx-vz/hrx-vz.github.io/refs/heads/main/sw.js"
URL_LOGOINTERNO="https://raw.githubusercontent.com/hrx-vz/hrx-vz.github.io/refs/heads/main/logo_cerocloud.png"
URL_LOGO="https://raw.githubusercontent.com/hrx-vz/hrx-vz.github.io/refs/heads/main/logo.png"


clear

# --- BARRAS AJUSTADAS ---
SEP_DOUBLE="${C_CYAN}================================================${C_RESET}"
SEP_SINGLE="${C_CYAN}------------------------------------------------${C_RESET}"

# --- JERARQUÍA VISUAL ---
step_msg()  { echo -e "\n${C_CYAN}${C_BOLD}[ >> ] $1${C_RESET}"; }
sub_msg()   { echo -e "       ${C_BLUE}├─${C_RESET} ${C_WHITE}$1${C_RESET}"; }
ok_msg()    { echo -e "       ${C_GREEN}[ OK ]${C_RESET} ${C_DIM}$1${C_RESET}"; }
warn_msg()  { echo -e "\n${C_YELLOW}[ WARN ]${C_RESET} ${C_WHITE}$1${C_RESET}"; }

# --- SPINNER DE CARGA ---
spin() {
    local pid=$1
    local delay=0.15
    local safe_spin='-\|/'
    while kill -0 $pid 2>/dev/null; do
        local temp=${safe_spin#?}
        printf "       ${C_BLUE}[ %c ]${C_RESET} ${C_WHITE}PROCESANDO TAREAS...${C_RESET}" "$safe_spin"
        local safe_spin=$temp${safe_spin%"$temp"}
        sleep $delay
        printf "\r"
    done
    printf "                                                \r"
}

# --- ENCABEZADO Y DESCRIPCIÓN ---
echo -e "${C_CYAN}${C_BOLD}"
echo "  ██████╗ ███████╗██████╗  ██████╗ "
echo " ██╔════╝ ██╔════╝██╔══██╗██╔═══██╗"
echo " ██║      █████╗  ██████╔╝██║   ██║"
echo " ██║      ██╔══╝  ██╔══██╗██║   ██║"
echo " ╚██████╗ ███████╗██║  ██║╚██████╔╝"
echo "  ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ "
echo -e "${C_CYAN}       C L O U D  ${C_RESET}\n"

echo -e "$SEP_DOUBLE"
echo -e " ${C_WHITE}TRANSFORMA TUS DISPOSITIVOS EN UN SERVIDOR DE${C_RESET}"
echo -e " ${C_WHITE}ALMACENAMIENTO PRIVADO. ${C_CYAN}SIN CONFIGURACIONES${C_RESET}"
echo -e " ${C_CYAN}COMPLEJAS, SIN CONTRATOS Y 100% TUYO.${C_RESET}"
echo -e "$SEP_DOUBLE"
sleep 1

# --- DETECCIÓN DE ENTORNO OPERATIVO ---
IS_TERMUX=false
if [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=true
fi

SUDO=""
if [ "$IS_TERMUX" = false ] && [ "$EUID" -ne 0 ]; then
    warn_msg "ENTORNO LINUX DETECTADO. REQUIERE SUPERUSUARIO."
    sudo -v || exit 1
    SUDO="sudo"
fi

# EJECUCIÓN DE ETAPAS

step_msg "ETAPA 1: PREPARACIÓN DE ALMACENAMIENTO"
if [ "$IS_TERMUX" = true ]; then
    sub_msg "Solicitando vinculación de disco..."
    termux-setup-storage
    sleep 2
    ok_msg "Almacenamiento montado exitosamente."
else
    ok_msg "Entorno Linux. Vinculación nativa omitida."
fi

step_msg "ETAPA 2: DESPLIEGUE DE MOTORES CORE"
if [ "$IS_TERMUX" = true ]; then
    sub_msg "Instalando red y backend (Node.js & Cloudflared)..."
    (
        DEBIAN_FRONTEND=noninteractive pkg upgrade -y -o Dpkg::Options::="--force-confnew" < /dev/null > install_debug.log 2>&1
        pkg install nodejs cloudflared curl -y < /dev/null >> install_debug.log 2>&1
    ) & spin $!
    sleep 1
else
    sub_msg "Instalando dependencias base de Linux..."
    (
        $SUDO apt-get update -y < /dev/null > install_debug.log 2>&1
        $SUDO apt-get install curl nodejs npm -y < /dev/null >> install_debug.log 2>&1
        if ! command -v cloudflared &> /dev/null; then
            $SUDO mkdir -p /usr/local/bin >> install_debug.log 2>&1
            ARCH=$(uname -m)
            if [ "$ARCH" = "x86_64" ]; then
                $SUDO curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared >> install_debug.log 2>&1
            elif [[ "$ARCH" = "aarch64" || "$ARCH" = "arm64" ]]; then
                $SUDO curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -o /usr/local/bin/cloudflared >> install_debug.log 2>&1
            fi
            $SUDO chmod +x /usr/local/bin/cloudflared >> install_debug.log 2>&1
        fi
    ) & spin $!
    sleep 1
fi
ok_msg "Motores base instalados correctamente."

step_msg "ETAPA 3: CONSTRUCCIÓN DE ARQUITECTURA"
sub_msg "Desplegando ecosistema de carpetas..."
mkdir -p ~/cero-cloud/storage/usuarios
mkdir -p ~/cero-cloud/temp_uploads
mkdir -p ~/cero-cloud/web_local_src/public
cd ~/cero-cloud
ok_msg "Núcleo desplegado en ~/cero-cloud"
sleep 1
step_msg "ETAPA 4: INYECCIÓN DE INTERFAZ Y BACKEND"
sub_msg "Sincronizando portal web y servidor de datos..."
(
    curl -sL https://raw.githubusercontent.com/hrx-vz/cerocloud/refs/heads/main/server.js -o server.js < /dev/null >> ../install_debug.log 2>&1
    npm init -y < /dev/null >> ../install_debug.log 2>&1
    npm install express cors multer < /dev/null >> ../install_debug.log 2>&1
    
    curl -sL "$URL_INDEX" -o web_local_src/public/index.html >> ../install_debug.log 2>&1
    curl -sL "$URL_ACCOUNT" -o web_local_src/public/account.html >> ../install_debug.log 2>&1
    curl -sL "$URL_MANIFEST" -o web_local_src/public/manifest.json >> ../install_debug.log 2>&1
    curl -sL "$URL_SW" -o web_local_src/public/sw.js >> ../install_debug.log 2>&1
    curl -sL "$URL_LOGOINTERNO" -o web_local_src/public/logo_cerocloud.png >> ../install_debug.log 2>&1
    curl -sL "$URL_LOGO" -o web_local_src/public/logo.png >> ../install_debug.log 2>&1

) & spin $!

cat << 'EOF' > web_local_src/web_local.js
const express = require('express');
const path = require('path');
const app = express();
const PORT = 5001;

app.use(express.static(path.join(__dirname, 'public')));

app.listen(PORT, '0.0.0.0', () => {});
EOF
ok_msg "       Sincronización completada al 100%."

step_msg "     ETAPA 5: GENERACIÓN DE LLAVE DE ACTIVACIÓN"
sub_msg "          -> Escribiendo protocolo de inicio del servidor..."

# SCRIPT DE ARRANQUE (INTERFAZ VISUAL)
cat << 'EOF' > activar-server.sh
#!/bin/bash
C_CYAN="\e[36m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_WHITE="\e[97m"
C_RESET="\e[0m"
C_BOLD="\e[1m"

SEP_DOUBLE="${C_CYAN}================================================${C_RESET}"

clear
echo -e "$SEP_DOUBLE"
echo -e "${C_CYAN}${C_BOLD}      [ INICIANDO PROTOCOLOS CERO CLOUD ]       ${C_RESET}"
echo -e "$SEP_DOUBLE\n"

if command -v termux-wake-lock &> /dev/null; then termux-wake-lock; fi

pkill -f "node server.js" > /dev/null 2>&1
pkill -f "node web_local_src/web_local.js" > /dev/null 2>&1
pkill -f "cloudflared" > /dev/null 2>&1

echo -e " ${C_CYAN}[ >> ]${C_RESET} ${C_WHITE}Asegurando Servicios Internos...${C_RESET}"
nohup node server.js > server.log 2>&1 &
nohup node web_local_src/web_local.js > web_local.log 2>&1 &
nohup cloudflared tunnel --url http://localhost:5000 > cloudflare.log 2>&1 &

echo -n -e " ${C_CYAN}[ >> ]${C_RESET} ${C_WHITE}Generando Túnel Seguro (Cloudflare)${C_RESET}"
URL=""
for i in {1..12}; do
    echo -n "."
    sleep 1
    URL=$(grep -a -m 1 -o 'https://[a-zA-Z0-9-]*\.trycloudflare\.com' cloudflare.log)
    if [ -n "$URL" ]; then break; fi
done

if [ -z "$URL" ]; then
    DISP_URL="${C_YELLOW}Error de red. Reinicia el servidor.${C_RESET}"
else
    DISP_URL="${C_GREEN}${C_BOLD}$URL${C_RESET}"
fi

echo -e "\n\n ${C_GREEN}[ OK ]${C_RESET} ${C_WHITE}Túnel Establecido Exitosamente.${C_RESET}\n"
sleep 1

IP_LOCAL="127.0.0.1"
if command -v ip &> /dev/null; then
    IP_LOCAL=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+')
elif command -v ifconfig &> /dev/null; then
    IP_LOCAL=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1)
fi

clear
echo -e "$SEP_DOUBLE"
echo -e "${C_GREEN}${C_BOLD}         [ BÓVEDA ACTIVA Y PROTEGIDA ]          ${C_RESET}"
echo -e "$SEP_DOUBLE\n"

echo -e "${C_CYAN}  ⬢ ${C_WHITE}${C_BOLD}C E R O${C_CYAN} C L O U D${C_RESET}   ${C_CYAN}│ ESTADO:${C_RESET} ${C_GREEN}● En Línea${C_RESET}"
echo -e "${C_WHITE}  Privacidad Absoluta   ${C_CYAN}│ RED:${C_RESET}    ${C_WHITE}Global y Local${C_RESET}"
echo -e "                        ${C_CYAN}│ NÚCLEO:${C_RESET} ${C_WHITE}Operativo${C_RESET}\n"
echo -e "$SEP_DOUBLE"

# ACCESO GLOBAL
echo -e "${C_CYAN}${C_BOLD} 🌍 ACCESO GLOBAL (Fuera de Casa)${C_RESET}"
echo -e "${C_WHITE} Enlace: ${DISP_URL}\n"

echo -e "${C_YELLOW} 📥 PASO 1: Instalar la App${C_RESET}"
echo -e "${C_WHITE} 1. Entra a: ${C_CYAN}https://hrx-vz.github.io${C_RESET}"
echo -e "${C_WHITE} 2. Toca los 3 puntos (⋮) del navegador.${C_RESET}"
echo -e "${C_WHITE} 3. Selecciona ${C_GREEN}\"Instalar\"${C_WHITE} o ${C_GREEN}\"Agregar a pantalla\"${C_RESET}."
echo -e "${C_WHITE} 4. Búscala en tu celular como: ${C_BOLD}MiNube${C_RESET}\n"

echo -e "${C_YELLOW} 🚀 PASO 2: Configurar Acceso${C_RESET}"
echo -e "${C_WHITE} Abre ${C_BOLD}MiNube${C_RESET}, entra en ${C_GREEN}\"¿Primera vez...\"${C_RESET},"
echo -e "${C_WHITE} pega tu Enlace Global y crea tu cuenta.${C_RESET}\n"
echo -e "$SEP_DOUBLE"

# ACCESO LOCAL
echo -e "${C_CYAN}${C_BOLD} 🏠 ACCESO LOCAL (Máxima velocidad en Casa)${C_RESET}"
echo -e "${C_WHITE} Enlace Servidor: ${C_GREEN}${C_BOLD}http://${IP_LOCAL}:5000${C_RESET}"
echo -e "${C_WHITE} pagina web local acceso sin wifi 🌐!: http://${IP_LOCAL}:5001${C_RESET}\n"

echo -e " ${C_YELLOW}💡 ¿CÓMO CONECTAR EN LOCAL?${C_RESET}"
echo -e " ${C_WHITE}1. Abre tu aplicación ${C_BOLD}MiNube${C_RESET}."
echo -e " ${C_WHITE}2. Toca el botón ${C_GREEN}\"Reconfigurar\"${C_RESET}."
echo -e " ${C_WHITE}3. Pega el Enlace Servidor de arriba."
echo -e " ${C_WHITE}4. Pon tu usuario y contraseña exactos.${C_RESET}\n"

echo -e " ${C_YELLOW}⚠️  REQUISITO DEL WI-FI:${C_RESET}"
echo -e " ${C_WHITE}Debes estar conectado al Wi-Fi de tu casa."
echo -e " ${C_WHITE}Funciona aunque el módem no tenga internet"
echo -e " ${C_WHITE}(icono '!' o 'i'), ya que la transferencia"
echo -e " ${C_WHITE}es directa por la señal de tu router.${C_RESET}\n"
echo -e "$SEP_DOUBLE"

# PROTOCOLO DE SEGURIDAD
echo -e "${C_CYAN}${C_BOLD} 🛡️ PROTOCOLO DE INVISIBILIDAD${C_RESET}"
echo -e " ${C_WHITE}Si ingresas datos incorrectos, el sistema"
echo -e " ${C_WHITE}NO mostrará errores. Creará una bóveda"
echo -e " ${C_WHITE}nueva y vacía para proteger tus archivos."
echo -e " ${C_WHITE}Escribe tus datos tal como los creaste.${C_RESET}\n"
echo -e "$SEP_DOUBLE"

echo -e "${C_WHITE} PARA APAGAR EL SERVIDOR ESCRIBE Y PRESIONA ENTER:${C_RESET}"
echo -e " ${C_YELLOW}> pkill -f node && pkill -f cloudflared${C_RESET}"
echo -e "$SEP_DOUBLE\n"

EOF

chmod +x activar-server.sh
ok_msg "Llave de encendido compilada."

echo -e "\n${C_GREEN}${C_BOLD}¡INSTALACIÓN FINALIZADA EXITOSAMENTE!${C_RESET}"
echo -e "${C_WHITE}Iniciando Tu Bóveda En 3 Segundos...${C_RESET}"
sleep 3

cd ~/cero-cloud
./activar-server.sh
