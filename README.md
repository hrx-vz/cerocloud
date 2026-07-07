# ☁️ CeroCloud: Servidor Privado y Descentralizado

[![🔒 Privacidad Total](https://img.shields.io/badge/Proyecto-Privacidad%20Total-00ffff?style=for-the-badge)](https://github.com/hrx-vz/cerocloud)
![🟢 Sistema Funcionando](https://img.shields.io/badge/Fase-Sistema%20Funcionando-00ff00?style=for-the-badge)
![Licencia GPL-3.0](https://img.shields.io/badge/Licencia-GPL%203.0-blue?style=for-the-badge)

Más que una aplicación de almacenamiento, **CeroCloud** es una herramienta diseñada para devolverte el control absoluto. Convierte tu propio dispositivo en un servidor de nube privado, rápido y bajo tu dominio total.

🌐 **Portal Visual y Web App Oficial:** [hrx-vz.github.io](https://hrx-vz.github.io)  
👉 *Para saber más sobre la interfaz gráfica, visita el [Repositorio del Frontend](https://github.com/hrx-vz/hrx-vz.github.io).*

---

## 🛡️ Protocolo de Invisibilidad y Seguridad

CeroCloud no depende de sistemas tradicionales propensos a hackeos masivos. Tu ecosistema se blinda mediante dos pilares fundamentales:

*   **⚡ El Túnel Dinámico Cifrado:** Al iniciar el servidor se genera un enlace único, aleatorio y fuertemente cifrado mediante túneles inversos. Tu proveedor de internet, corporaciones o atacantes externos no sabrán que tu servidor existe. Si deseas cambiar de ruta, basta con reiniciar el servidor para desvanecerte y aparecer bajo una nueva coraza digital.
*   **👤 Protocolo de Invisibilidad:** El sistema implementa seguridad por invisibilidad absoluta. Si ingresas credenciales incorrectas, la plataforma **no mostrará advertencias ni errores**. En su lugar, te redirigirá a una bóveda completamente nueva y vacía. Solo tus datos exactos revelarán tus archivos reales.

---

## 📦 Características Maestras

*   **🔋 Sincronización Eficiente:** Diseñado especialmente para preservar el hardware y la batería de dispositivos móviles. Implementa sincronización a demanda: si realizas cambios desde otro equipo, basta con tocar de nuevo la sección en el menú lateral para refrescar el espacio de forma fría y optimizada.
*   **👥 Espacios Aislados (Multicuenta):** Un solo servidor puede alojar a múltiples usuarios. Al ingresar credenciales diferentes, el sistema genera de forma automática un espacio aislado y privado para cada persona.
*   **🔐 Bóveda Oculta:** Seguridad extra dentro de tu sesión. Haz clic **4 veces seguidas en el logo de la nube** en el menú superior para desbloquear un espacio oculto independiente del servidor público.
*   **♻️ Papelera Inteligente y Descargas en Lote:** Restaura archivos eliminados por error con un solo clic o gestiona descargas masivas de manera fluida.

---

## 🚀 Guía de Instalación Automática

El despliegue está completamente automatizado a través de un comando único de instalación. Elige tu entorno de servidor:

### 📱 1. Servidor en Celular o Tablet (Android)

> *Nota: CeroCloud requiere la libertad de procesos en segundo plano que solo los sistemas Android permiten.*

1. **Descarga Termux:** Instala la versión oficial limpia desde F-Droid.
   👉 [Descargar Termux APK (F-Droid)](https://f-droid.org/repo/com.termux_1022.apk)
2. **Optimiza la Batería (Crucial):** Para evitar que el sistema cierre tu servidor, ve a `Ajustes > Aplicaciones > Termux > Batería` y selecciona **Sin restricciones**. Adicionalmente, desactiva la opción de *Batería Adaptable/Automática* en la configuración global de tu batería.
3. **Ejecuta el Comando:** Abre Termux, pega la siguiente línea y presiona **Enter**:

```bash
curl -sL https://raw.githubusercontent.com/hrx-vz/cerocloud/refs/heads/main/install.sh | bash
```
### 💻 2. Servidor en Computadora (Linux / Ubuntu / Debian)

Si utilizas una PC o Laptop basada en Linux, puedes levantar tu infraestructura privada en segundos. Abre tu terminal de confianza, copia este bloque, pégalo y presiona Enter:

```bash
sudo apt update && sudo apt install curl -y && curl -sL https://raw.githubusercontent.com/hrx-vz/cerocloud/refs/heads/main/install.sh | bash
```

> *💡 Nota: Este comando actualizará de forma segura tus repositorios locales, verificará la herramienta curl en tu sistema y ejecutará el script de configuración automática sin que tengas que intervenir en nada más. Solo espera a que la terminal te devuelva tu enlace.*

---

## 🔄 Protocolo de Reconexión Rápida

Si tu hardware se apaga debido a un corte de energía o reinicio del sistema, tu túnel seguro se cerrará por protección. Volver a estar en línea es sumamente sencillo:

1. Levanta el servidor ejecutando el comando de activación en tu terminal:
   ```bash
   cd cero-cloud && ./activar-server.sh
   ```
2. Abre tu aplicación **MiNube** instalada en tu celular, presiona el botón **"Re-configurar"**, ingresa la nueva URL que te entregó la terminal junto con tus credenciales de siempre, ¡y listo! Tus archivos seguirán intactos bajo tu nuevo escudo de protección.

## 🕹️ El Arcade Digital: Despliegues de Concienciación Táctica

Para entender el comportamiento de las redes, la evasión de sistemas y el monitoreo global, hemos diseñado una suite interactiva de simulación y entornos arcade directamente en la web. 

Baja hasta los paneles de control de abajo, elige tu entorno y experimenta el flujo del mundo digital en tiempo real.

<br />

<div align="center">

### ⚡ PROYECTO: NEXUS
**[ 🎮 JUGAR AHORA ](https://hrx-vz.github.io/games/nexus.html)**

*60 segundos. Cero margen de error.*
Un arcade de supervivencia crítica contra el reloj. Administra la temperatura de tu núcleo, despliega señuelos dinámicos para confundir a los rastreadores y recolectar refrigerantes antes de que tu sistema sufra un sobrecalentamiento crítico. Incluye síntesis de audio integrada nativa.
</div>

---

<div align="center">

### 📡 OPERACIÓN FANTASMA
**[ 🎮 JUGAR AHORA ](https://hrx-vz.github.io/games/fantasma.html)**

*El arte de la invisibilidad digital.*
Un simulador táctico de sigilo y evasión en dos dimensiones. Tu misión es extraer paquetes de datos críticos esquivando ondas expansivas de radar en tiempo real. Sincroniza tu módulo *Ghost* para desmaterializarte justo en el instante del impacto. Si tu barra de exposición llega al 100%, la operación ha fallado.
</div>

---

<div align="center">

### 🗺️ NET-HUNTER
**[ 🎮 JUGAR AHORA ](https://hrx-vz.github.io/games/nethunter.html)**

*Estrategia global a gran escala.*
Elige tu rol: Infiltrado, Destructor o Centinela. Un RPG táctico interactivo que te pone al mando de una terminal de asalto. Coordina ataques a nodos estratégicos en un mapa esférico simulado, gestiona flujos de energía e invoca inteligencia aliada autónoma mediante comandos S.O.S de emergencia.
</div>

---

<div align="center">

### 💻 CYBERMUNDO: SIMULADOR DIGITAL
**[ 👁️ ENTRAR AL SIMULADOR ](https://hrx-vz.github.io/games/cybermundo.html)**

*No es un juego. Es una ventana a la matriz.*
Un espacio puramente contemplativo e inmersivo diseñado para visualizar la densidad de la red. Monitorea flujos de datos globales, analiza la telemetría de coordenadas tridimensionales flotantes y observa cómo interactúan los sistemas automatizados en un entorno abstracto de partículas. Ideal como panel de monitoreo estético ambiental.
</div>

---

## 🛠️ Especificaciones de Arquitectura

*   **Núcleo:** Despliegue optimizado de bajo consumo para nodos distribuidos.
*   **Seguridad:** Cifrado de punto a punto y políticas estrictas de cero logs de terceros.
*   **Diseño Visual:** Interfases híbridas optimizadas para terminales virtuales y navegadores móviles.

---

## 🛰️ Desafío Táctico: Hackeo de Objetivos Reales (Net-Hunter)

En el mapa global 3D de **Net-Hunter**, no estás atacando al azar. El sistema despliega las ubicaciones de agencias de inteligencia reales en tiempo real. Si quieres interceptar sus servidores, búscalos usando el radar visual en base a su latitud ($X$) y longitud ($Y$):

*   **El Pentágono (EE. UU.):** Ubicado en el eje de coordenadas aproximado ($X: 38.87$, $Y: -77.05$). Un nodo de alta seguridad informática.
*   **El Kremlin (Rusia):** Ubicado en el eje de coordenadas aproximado ($X: 55.75$, $Y: 37.61$). Tráfico de datos encriptado y hostil.

**¿Cómo seguir la ruta de ataque?:** 
Mueve el joystick virtual para rotar el globo terráqueo e interceptar las coordenadas en pantalla. Cuando tu laptop (`💻`) se alinee visualmente en la misma trayectoria $X$ / $Y$ del objetivo, el enlace de red se establecerá automáticamente para iniciar la infiltración.

Si te ves superado por los cortafuegos enemigos, recuerda activar tu comando **S.O.S** para desplegar compañeros autónomos en esa posición.

---

## 📞 CONTACTO

¿necesitas soporte de despliegue para tu infraestructura privada o quieres contactar directamente al desarrollador de este ecosistema? Establece una sesión directa:

*   **Telegram:** [@HRI_VL](https://t.me/HRI_VL) 🌐

