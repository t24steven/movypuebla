import { Router, Request, Response } from 'express';
import { db } from '../services/firestore';

const router = Router();

/** Distancia en km entre dos coordenadas (fórmula Haversine). */
function haversineKm(
  lat1: number, lng1: number,
  lat2: number, lng2: number
): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// GET /routes/search?originLat=&originLng=&destLat=&destLng=
// Si se pasan coordenadas, ordena rutas por cercanía a origen+destino.
// Si no, devuelve todas las rutas.
router.get('/search', async (req: Request, res: Response) => {
  try {
    const { originLat, originLng, destLat, destLng } = req.query;

    // Obtener todas las rutas
    const routesSnapshot = await db.collection('routes').get();
    const routes: FirebaseFirestore.DocumentData[] = [];
    routesSnapshot.forEach((doc) => {
      routes.push({ id: doc.id, ...doc.data() });
    });

    // Si no hay coordenadas, devolver todas
    if (!originLat || !originLng || !destLat || !destLng) {
      res.json(routes);
      return;
    }

    const oLat = parseFloat(originLat as string);
    const oLng = parseFloat(originLng as string);
    const dLat = parseFloat(destLat as string);
    const dLng = parseFloat(destLng as string);

    // Obtener todas las paradas
    const stopsSnapshot = await db.collection('stops').get();
    const allStops: FirebaseFirestore.DocumentData[] = [];
    stopsSnapshot.forEach((doc) => {
      allStops.push({ id: doc.id, ...doc.data() });
    });

    // Para cada ruta, calcular qué tan cerca están sus paradas del origen y destino
    const scored = routes.map((route) => {
      const routeStops = allStops.filter(
        (s) => s.routeId === route.id && s.lat != null && s.lng != null
      );

      if (routeStops.length === 0) {
        return { ...route, score: Infinity, nearestOriginStop: null, nearestDestStop: null };
      }

      // Parada más cercana al origen
      let minOriginDist = Infinity;
      let nearestOriginStop = null;
      for (const stop of routeStops) {
        const d = haversineKm(oLat, oLng, stop.lat, stop.lng);
        if (d < minOriginDist) {
          minOriginDist = d;
          nearestOriginStop = stop.name;
        }
      }

      // Parada más cercana al destino
      let minDestDist = Infinity;
      let nearestDestStop = null;
      for (const stop of routeStops) {
        const d = haversineKm(dLat, dLng, stop.lat, stop.lng);
        if (d < minDestDist) {
          minDestDist = d;
          nearestDestStop = stop.name;
        }
      }

      // Score = suma de distancias mínimas (menor es mejor)
      const score = minOriginDist + minDestDist;

      return {
        ...route,
        score,
        nearestOriginStop,
        nearestOriginDistKm: Math.round(minOriginDist * 10) / 10,
        nearestDestStop,
        nearestDestDistKm: Math.round(minDestDist * 10) / 10,
      };
    });

    // Ordenar por score (más relevante primero)
    scored.sort((a, b) => a.score - b.score);

    res.json(scored);
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
