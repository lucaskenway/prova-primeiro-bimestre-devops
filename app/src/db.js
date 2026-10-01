const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: Number(process.env.POSTGRES_PORT) || 5432,
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
  ssl: process.env.POSTGRES_SSL === 'true' ? { rejectUnauthorized: false } : false,
  // Sem timeout, /health pode travar se o host do banco não responder
  connectionTimeoutMillis: 3000,
  query_timeout: 5000,
});

// Conexão ociosa derrubada pelo banco (restart/parada) emite 'error' no pool;
// sem este handler o processo Node encerra em vez de responder 503 no /health
pool.on('error', (err) => {
  console.error('Conexão com o banco perdida:', err.message);
});

async function init() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS reservas (
      id      SERIAL PRIMARY KEY,
      cliente VARCHAR(120) NOT NULL,
      data    TIMESTAMPTZ  NOT NULL,
      status  VARCHAR(20)  NOT NULL DEFAULT 'pendente'
              CHECK (status IN ('pendente', 'confirmada', 'cancelada'))
    )
  `);
}

module.exports = { pool, init };
