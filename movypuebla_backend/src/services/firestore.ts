import admin from 'firebase-admin';
import path from 'path';
import fs from 'fs';

if (!admin.apps.length) {
  // Busca serviceAccountKey.json en la raíz del proyecto backend
  const keyPath = path.resolve(__dirname, '../../serviceAccountKey.json');
  if (!fs.existsSync(keyPath)) {
    throw new Error(
      `No se encontró serviceAccountKey.json en ${keyPath}. ` +
      'Descárgalo desde Firebase Console > Configuración del proyecto > Cuentas de servicio.'
    );
  }
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf-8'));
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

export const db = admin.firestore();
