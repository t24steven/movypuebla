import { Router, Request, Response } from 'express';
import { db } from '../services/firestore';

const router = Router();

// POST /users — Crear o actualizar perfil de usuario
router.post('/', async (req: Request, res: Response) => {
  try {
    const { uid, name, email, role, assignedRouteId } = req.body;
    if (!uid || !name || !email || !role) {
      res.status(400).json({ error: 'Faltan campos requeridos: uid, name, email, role' });
      return;
    }
    if (role !== 'citizen' && role !== 'driver') {
      res.status(400).json({ error: 'Rol inválido. Usa "citizen" o "driver"' });
      return;
    }

    const userData: Record<string, unknown> = { uid, name, email, role };
    if (role === 'driver' && assignedRouteId) {
      userData.assignedRouteId = assignedRouteId;
    }

    await db.collection('users').doc(uid).set(userData, { merge: true });
    res.json({ ok: true, ...userData });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al guardar usuario' });
  }
});

// GET /users/:uid — Obtener perfil de usuario
router.get('/:uid', async (req: Request, res: Response) => {
  try {
    const { uid } = req.params;
    const doc = await db.collection('users').doc(uid).get();
    if (!doc.exists) {
      res.status(404).json({ error: 'Usuario no encontrado' });
      return;
    }
    res.json({ id: doc.id, ...doc.data() });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener usuario' });
  }
});

// PUT /users/:uid/location — Actualizar ubicación del transportista
router.put('/:uid/location', async (req: Request, res: Response) => {
  try {
    const { uid } = req.params;
    const { lat, lng, status } = req.body;

    await db.collection('users').doc(uid).update({
      currentLat: lat,
      currentLng: lng,
      status: status || 'active', // active, inactive, break
      lastUpdated: new Date().toISOString(),
    });

    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar ubicación' });
  }
});

export default router;
