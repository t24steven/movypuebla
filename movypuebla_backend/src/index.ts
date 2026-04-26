import express, { Request, Response } from 'express';
import cors from 'cors';
import routesRouter from './routes/routesRouter';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (_req: Request, res: Response) => {
  res.send('API MovyPuebla funcionando');
});

app.use('/routes', routesRouter);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Servidor MovyPuebla escuchando en puerto ${PORT}`);
});
