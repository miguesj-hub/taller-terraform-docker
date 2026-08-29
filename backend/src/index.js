const express = require('express');
const os = require('os');
const mysql = require('mysql2/promise');

const app = express();
const PORT = process.env.PORT || 3000;

// Pool de conexiones a MySQL. Los valores llegan por variables de entorno,
// inyectadas desde Terraform (ver terraform/backend.tf).
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 5,
});

// Endpoint de salud: usado por curl/navegador para comprobar qué réplica
// del backend respondió. os.hostname() devuelve el "hostname" del
// contenedor, que Terraform fija explícitamente (backend-1, backend-2...),
// así que aquí se ve directamente el efecto del balanceo de carga de Nginx.
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', servedBy: os.hostname() });
});

// Endpoint que escribe y lee de MySQL, para demostrar que las tres capas
// (Nginx -> backend -> MySQL) están realmente conectadas end-to-end.
app.get('/api/visits', async (req, res) => {
  try {
    await pool.query('INSERT INTO visits (served_by) VALUES (?)', [os.hostname()]);
    const [rows] = await pool.query('SELECT COUNT(*) AS total FROM visits');
    res.json({ totalVisits: rows[0].total, servedBy: os.hostname() });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Backend escuchando en el puerto ${PORT} (hostname: ${os.hostname()})`);
});
