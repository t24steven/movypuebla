import { db } from '../services/firestore';

interface StopData {
  name: string;
  lat: number;
  lng: number;
}

async function seed() {
  // Línea 3 Valsequillo – CAPU
  const route3Ref = await db.collection('routes').add({
    name: 'Línea 3 Valsequillo – CAPU',
    code: 'L3',
    zoneType: 'urbana',
    baseFareMin: 6.0,
    baseFareMax: 7.5,
    discountDisabled: 0.0,
    discountStudentMin: 4.0,
    discountStudentMax: 6.0,
    discountSeniorMin: 4.0,
    discountSeniorMax: 6.0,
    nightFare: 30.0,
    supportsNightService: true,
  });

  const stops3: StopData[] = [
    { name: 'Ciudad Universitaria (BUAP)', lat: 19.0028, lng: -98.2038 },
    { name: 'Valsequillo',                 lat: 19.0005, lng: -98.1750 },
    { name: 'Analco',                      lat: 19.0380, lng: -98.1870 },
    { name: 'Las Torres',                  lat: 19.0520, lng: -98.2100 },
    { name: 'CAPU',                        lat: 19.0700, lng: -98.2280 },
  ];

  for (let i = 0; i < stops3.length; i++) {
    await db.collection('stops').add({
      routeId: route3Ref.id,
      name: stops3[i].name,
      order: i + 1,
      lat: stops3[i].lat,
      lng: stops3[i].lng,
    });
  }

  // Línea 2 Margaritas – Diagonal
  const route2Ref = await db.collection('routes').add({
    name: 'Línea 2 Margaritas – Diagonal',
    code: 'L2',
    zoneType: 'urbana',
    baseFareMin: 6.0,
    baseFareMax: 7.5,
    discountDisabled: 0.0,
    discountStudentMin: 4.0,
    discountStudentMax: 6.0,
    discountSeniorMin: 4.0,
    discountSeniorMax: 6.0,
    nightFare: 30.0,
    supportsNightService: true,
  });

  const stops2: StopData[] = [
    { name: 'San Bartolo',   lat: 19.0610, lng: -98.2350 },
    { name: 'Torrecillas',   lat: 19.0530, lng: -98.2200 },
    { name: 'Club Jardín',   lat: 19.0460, lng: -98.2050 },
    { name: 'Paseo Bravo',   lat: 19.0400, lng: -98.1980 },
  ];

  for (let i = 0; i < stops2.length; i++) {
    await db.collection('stops').add({
      routeId: route2Ref.id,
      name: stops2[i].name,
      order: i + 1,
      lat: stops2[i].lat,
      lng: stops2[i].lng,
    });
  }

  console.log('Seed completado con coordenadas');
}

seed()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
