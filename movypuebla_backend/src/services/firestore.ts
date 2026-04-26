import admin from 'firebase-admin';
import path from 'path';
import fs from 'fs';

if (!admin.apps.length) {
  let credential: admin.credential.Credential;

  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    // Producción (Railway): usa variable de entorno
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    credential = admin.credential.cert(serviceAccount);
  } else {
    // Desarrollo local: usa archivo serviceAccountKey.json
    const keyPath = path.resolve(__dirname, '../../serviceAccountKey.json');
    if (!fs.existsSync(keyPath)) {
      throw new Error(
        `No se encontró serviceAccountKey.json en ${keyPath}. ` +
        'Descárgalo desde Firebase Console o configura FIREBASE_SERVICE_ACCOUNT.'
      );
    }
    const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf-8'));
    credential = admin.credential.cert(serviceAccount);
  }

  admin.initializeApp({ credential });
}

export const db = admin.firestore();
