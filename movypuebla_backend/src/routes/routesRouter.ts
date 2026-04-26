import { Router, Request, Response } from 'express';
import { db } from '../services/firestore';

const router = Router();

// GET /routes/search
router.get('/search', async (_req: Request, res: Response) => {
  try {
    const snapshot = await db.collection('routes').get();
    const routes: FirebaseFirestore.DocumentData[] = [];
    snapshot.forEach((doc) => {
      routes.push({ id: doc.id, ...doc.data() });
    });
    res.json(routes);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener rutas' });
  }
});

// GET /routes/:id
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const routeDoc = await db.collection('routes').doc(id).get();
    if (!routeDoc.exists) {
      res.status(404).json({ error: 'Ruta no encontrada' });
      return;
    }
    const stopsSnapshot = await db
      .collection('stops')
      .where('routeId', '==', id)
      .get();

    const stops: FirebaseFirestore.DocumentData[] = [];
    stopsSnapshot.forEach((doc) => {
      stops.push({ id: doc.id, ...doc.data() });
    });
    // Ordenar por 'order' en memoria (evita necesitar índice compuesto)
    stops.sort((a, b) => (a.order as number) - (b.order as number));

    res.json({
      id: routeDoc.id,
      ...routeDoc.data(),
      stops,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener ruta' });
  }
});

export default router;
