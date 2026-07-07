const express = require('express');
const multer = require('multer');
const path = require('path');                                          const fs = require('fs');
const crypto = require('crypto');
const { exec } = require('child_process');

const app = express();                                                 const PORT = 5000;
                                                                       // Almacenamiento local interno
const INTERNAL_STORAGE = path.join(__dirname, 'storage');
const DB_PATH = path.join(INTERNAL_STORAGE, 'usuarios.json');

if (!fs.existsSync(INTERNAL_STORAGE)) fs.mkdirSync(INTERNAL_STORAGE, { recursive: true });
if (!fs.existsSync(DB_PATH)) fs.writeFileSync(DB_PATH, JSON.stringify({}));

const clientesSSE = new Map();
function notificarCambio(usuario) {
    if (clientesSSE.has(usuario)) {
        clientesSSE.get(usuario).forEach(res => {
            try {
                res.write(`data: update\n\n`);
            } catch (e) {
                clientesSSE.get(usuario).delete(res);
            }
        });
    }
}

// Función para encriptar contraseñas localmente
function generarHash(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    res.header("Access-Control-Allow-Headers", "*");
    res.header("Access-Control-Expose-Headers", "Content-Length");
    if (req.method === 'OPTIONS') return res.status(200).end();
    next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/stream/:usuario', (req, res) => {
    const { usuario } = req.params;
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    res.flushHeaders();
    if (!clientesSSE.has(usuario)) clientesSSE.set(usuario, new Set());
    clientesSSE.get(usuario).add(res);
    req.on('close', () => {
        if (clientesSSE.has(usuario)) {
            clientesSSE.get(usuario).delete(res);
            if (clientesSSE.get(usuario).size === 0) clientesSSE.delete(usuario);
        }
    });
});

// ENRUTADOR
function obtenerRutaDestino(usuario, section, esOculto) {
    const baseDir = path.join(INTERNAL_STORAGE, 'usuarios', usuario);
    const rootDir = String(esOculto) === "true" ? path.join(baseDir, 'boveda_priv') : baseDir;
    const dir = path.join(rootDir, section);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    return dir;
}

const upload = multer({ dest: path.join(__dirname, 'temp_uploads') });

app.post('/api/upload/:usuario', upload.single('file'), (req, res) => {
    try {
        const { usuario } = req.params;
        const section = req.body.section || 'fotos';
        const esOculto = req.body.esOculto || "false";

        const dir = obtenerRutaDestino(usuario, section, esOculto);
        const nombreSeguro = req.file.originalname.replace(/[^a-zA-Z0-9.\-_]/g, '_');
        const finalPath = path.join(dir, Date.now() + '-' + nombreSeguro);

        try {
            fs.renameSync(req.file.path, finalPath);
        } catch (err) {
            fs.copyFileSync(req.file.path, finalPath);
            fs.unlinkSync(req.file.path);
        }

        notificarCambio(usuario);
        res.json({ success: true });
    } catch (error) {
        if (req.file && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
        res.status(500).json({ error: 'Error físico de escritura.' });
    }
});

app.get('/api/files/:usuario/:section', (req, res) => {
    const { usuario, section } = req.params;
    const esOculto = req.query.esOculto || "false";
    const dir = obtenerRutaDestino(usuario, section, esOculto);
    let resultado = [];

    if (fs.existsSync(dir)) {
        fs.readdirSync(dir).forEach(f => {
            const ruta = path.join(dir, f);
            const stat = fs.statSync(ruta);
            if (stat.isFile()) {
                resultado.push({
                    name: f,
                    ext: path.extname(f).toLowerCase(),
                    time: stat.mtimeMs,
                    size: stat.size,
                    url: `/files/${usuario}/${section}/${f}?esOculto=${esOculto}`
                });
            }
        });
    }
    resultado.sort((a, b) => b.time - a.time);
    res.json(resultado);
});

// MANDAR A PAPELERA
app.delete('/api/delete/:usuario/:filename', (req, res) => {
    const { usuario, filename } = req.params;
    const section = req.query.section || 'fotos';
    const esOculto = req.query.esOculto || "false";

    const origenDir = obtenerRutaDestino(usuario, section, esOculto);
    const papeleraDir = obtenerRutaDestino(usuario, 'papelera', esOculto);

    const rutaOrigen = path.join(origenDir, filename);
    if (fs.existsSync(rutaOrigen)) {
        const nombrePapelera = `${section}_${filename}`;
        fs.copyFileSync(rutaOrigen, path.join(papeleraDir, nombrePapelera));
        fs.unlinkSync(rutaOrigen);
        notificarCambio(usuario);
        return res.json({ success: true });
    }
    res.status(404).json({ error: 'Archivo no encontrado.' });
});

// RECUPERAR ARCHIVOS DE LA PAPELERA A SU SECCIÓN ORIGINAL
app.post('/api/restore/:usuario/:filename', (req, res) => {
    try {
        const { usuario, filename } = req.params;
        const esOculto = req.query.esOculto || "false";

        const papeleraDir = obtenerRutaDestino(usuario, 'papelera', esOculto);
        const rutaPapelera = path.join(papeleraDir, filename);

        if (!fs.existsSync(rutaPapelera)) {
            return res.status(404).json({ error: 'El archivo no existe en la papelera.' });
        }

        const indexGuionBajo = filename.indexOf('_');
        if (indexGuionBajo === -1) {
            return res.status(400).json({ error: 'Formato de archivo de papelera inválido.' });
        }

        const sectionOriginal = filename.substring(0, indexGuionBajo);
        const nombreOriginal = filename.substring(indexGuionBajo + 1);

        const destinoDir = obtenerRutaDestino(usuario, sectionOriginal, esOculto);
        const rutaDestino = path.join(destinoDir, nombreOriginal);

        // Mover físicamente el archivo de regreso
        fs.copyFileSync(rutaPapelera, rutaDestino);
        fs.unlinkSync(rutaPapelera);

        notificarCambio(usuario);
        res.json({ success: true, restoredTo: sectionOriginal });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error interno al restaurar el archivo.' });
    }
});

// ELLIMINACION DEFINITIVAMENTE DE LA PAPELERA
app.delete('/api/purge/:usuario/:filename', (req, res) => {
    const { usuario, filename } = req.params;
    const esOculto = req.query.esOculto || "false";
    const papeleraDir = obtenerRutaDestino(usuario, 'papelera', esOculto);
    const ruta = path.join(papeleraDir, filename);

    if (fs.existsSync(ruta)) {
        fs.unlinkSync(ruta);
        notificarCambio(usuario);
        return res.json({ success: true });
    }
    res.status(404).json({ error: 'Archivo no encontrado.' });
});

app.get('/files/:usuario/:section/:filename', (req, res) => {
    const { usuario, section, filename } = req.params;
    const esOculto = req.query.esOculto || "false";

    const dir = obtenerRutaDestino(usuario, section, esOculto);
    const archivoFinal = path.join(dir, filename);

    if (fs.existsSync(archivoFinal)) {
        if (req.query.download === 'true') return res.download(archivoFinal, filename.substring(filename.indexOf('-') + 1));
        res.setHeader('Cache-Control', 'public, max-age=604800, immutable');
        return res.sendFile(archivoFinal);
    }
    res.sendStatus(404);
});

// REGISTRO LOCAL (Para account.html)
app.post('/api/registro-local', (req, res) => {
    try {
        const { usuario, password } = req.body;
        let dbUsuarios = JSON.parse(fs.readFileSync(DB_PATH, 'utf8'));

        if (dbUsuarios[usuario]) {
            if (dbUsuarios[usuario].password === generarHash(password)) {
                return res.json({ success: true, message: 'Dispositivo vinculado. Bienvenido.' });
            } else {
                return res.status(401).json({ error: 'Usuario existente. Contraseña incorrecta.' });
            }
        }

        dbUsuarios[usuario] = {
            password: generarHash(password),
            fecha: new Date()
        };
        fs.writeFileSync(DB_PATH, JSON.stringify(dbUsuarios, null, 2));

        obtenerRutaDestino(usuario, 'fotos', "false");
        obtenerRutaDestino(usuario, 'papelera', "false");

        res.json({ success: true, message: 'Bóveda local configurada e inicializada con éxito.' });
    } catch (error) {
        res.status(500).json({ error: 'Error físico de base de datos.' });
    }
});

// LOGIN LOCAL (Para index.html)
app.post('/api/login-local', (req, res) => {
    const { usuario, password } = req.body;
    const dbUsuarios = JSON.parse(fs.readFileSync(DB_PATH, 'utf8'));

    const cuenta = dbUsuarios[usuario];
    if (cuenta && cuenta.password === generarHash(password)) {
        return res.json({ success: true, message: "Acceso authorized." });
    }
    res.status(401).json({ error: 'Credenciales incorrectas en este servidor.' });
});

app.get('/api/storage-info', (req, res) => {
    exec('df -h .', (err, stdout) => {
        let total = "454G", used = "0G", percent = "0%";
        if (!err) {
            const lines = stdout.trim().split('\n');
            if (lines.length >= 2) {
                const col = lines[1].replace(/\s+/g, ' ').split(' ').filter(p => p !== '');
                const indexPorcentaje = col.findIndex(c => c.includes('%'));
                if (indexPorcentaje !== -1) {
                    percent = col[indexPorcentaje];
                    used = col[indexPorcentaje - 2] || col[2] || "0G";
                    total = col[indexPorcentaje - 3] || col[1] || "454G";
                } else {
                    // Mapeo de respaldo por si falla la detección regex
                    total = col[1] || "454G";
                    used = col[2] || "0G";
                    percent = col[4] || "0%";
                }
            }
        }
        res.json({ total, used, percent });
    });
});

const server = app.listen(PORT, '0.0.0.0', () => console.log(`Servidor CeroCloud Soberano Activo`));

server.timeout = 0;
server.keepAliveTimeout = 0;
