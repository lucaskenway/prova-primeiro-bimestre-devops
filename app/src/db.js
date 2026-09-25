const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: Number(process.env.POSTGRES_PORT) || 5432,
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
  ssl: process.env.POSTGRES_SSL === 'true' ? { rejectUnauthorized: false } : false,
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
