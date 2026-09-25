const express = require('express');
const { pool, init } = require('./db');
const reservasRouter = require('./routes/reservas');

const app = express();
const PORT = Number(process.env.PORT) || 3000;

app.use(express.json());

app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', db: 'ok' });
  } catch {
    res.status(503).json({ status: 'erro', db: 'indisponivel' });
  }
});

app.use('/reservas', reservasRouter);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ erro: 'Erro interno' });
});

async function start() {
  // Aguarda o banco ficar disponível (útil no compose e no boot da EC2)
  for (let tentativa = 1; tentativa <= 10; tentativa++) {
    try {
      await init();
      break;
    } catch (err) {
      console.log(`Banco indisponível (tentativa ${tentativa}/10): ${err.message}`);
      if (tentativa === 10) process.exit(1);
      await new Promise((r) => setTimeout(r, 3000));
    }
  }
  app.listen(PORT, () => console.log(`API de Reservas ouvindo na porta ${PORT}`));
}

start();
