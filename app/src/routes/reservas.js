const { Router } = require('express');
const { pool } = require('../db');

const router = Router();
const STATUS = ['pendente', 'confirmada', 'cancelada'];

// ISO 8601: AAAA-MM-DD, opcionalmente com THH:MM[:SS[.fração]] e fuso (Z ou ±HH:MM)
const ISO_8601 = /^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}(:\d{2}(\.\d{1,6})?)?(Z|[+-]\d{2}:\d{2})?)?$/;

function dataIsoValida(data) {
  if (typeof data !== 'string' || !ISO_8601.test(data) || isNaN(new Date(data))) return false;
  // Rejeita datas que o JS "corrige" sozinho, como 2026-02-30 -> 2026-03-02
  const [ano, mes, dia] = data.slice(0, 10).split('-').map(Number);
  const d = new Date(Date.UTC(ano, mes - 1, dia));
  return d.getUTCFullYear() === ano && d.getUTCMonth() === mes - 1 && d.getUTCDate() === dia;
}

function validar({ cliente, data, status }) {
  if (!cliente || !data) return 'Campos obrigatórios: cliente, data';
  if (!dataIsoValida(data)) return 'data inválida (use ISO 8601, ex: 2026-10-01T14:00:00Z)';
  if (status !== undefined && !STATUS.includes(status)) {
    return `status deve ser um de: ${STATUS.join(', ')}`;
  }
  return null;
}

router.get('/', async (req, res, next) => {
  try {
    const { rows } = await pool.query('SELECT * FROM reservas ORDER BY id');
    res.json(rows);
  } catch (err) { next(err); }
});

router.get('/:id', async (req, res, next) => {
  try {
    const { rows } = await pool.query('SELECT * FROM reservas WHERE id = $1', [req.params.id]);
    if (!rows.length) return res.status(404).json({ erro: 'Reserva não encontrada' });
    res.json(rows[0]);
  } catch (err) { next(err); }
});

router.post('/', async (req, res, next) => {
  try {
    const erro = validar(req.body);
    if (erro) return res.status(400).json({ erro });
    const { cliente, data, status = 'pendente' } = req.body;
    const { rows } = await pool.query(
      'INSERT INTO reservas (cliente, data, status) VALUES ($1, $2, $3) RETURNING *',
      [cliente, data, status]
    );
    res.status(201).json(rows[0]);
  } catch (err) { next(err); }
});

router.put('/:id', async (req, res, next) => {
  try {
    const erro = validar(req.body);
    if (erro) return res.status(400).json({ erro });
    const { cliente, data, status } = req.body;
    // status omitido mantém o valor atual (o padrão "pendente" vale só na criação)
    const { rows } = await pool.query(
      'UPDATE reservas SET cliente = $1, data = $2, status = COALESCE($3, status) WHERE id = $4 RETURNING *',
      [cliente, data, status ?? null, req.params.id]
    );
    if (!rows.length) return res.status(404).json({ erro: 'Reserva não encontrada' });
    res.json(rows[0]);
  } catch (err) { next(err); }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const { rowCount } = await pool.query('DELETE FROM reservas WHERE id = $1', [req.params.id]);
    if (!rowCount) return res.status(404).json({ erro: 'Reserva não encontrada' });
    res.status(204).end();
  } catch (err) { next(err); }
});

module.exports = router;
