import express, { Request, Response } from 'express';
import cors from 'cors';
import routesRouter from './routes/routesRouter';
import usersRouter from './routes/usersRouter';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (_req: Request, res: Response) => {
  res.send('API MovyPuebla funcionando');
});

app.use('/routes', routesRouter);
app.use('/users', usersRouter);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Servidor MovyPuebla escuchando en puerto ${PORT}`);
});
