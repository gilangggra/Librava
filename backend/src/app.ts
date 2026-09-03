import express, { Application } from 'express';
import cors from 'cors';
import routes from './routes';
import { errorHandler, notFoundHandler } from './middlewares/error.middleware';

const app: Application = express();

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

app.get('/', (req, res) => {
  res.status(200).json({
    name: 'Librava API',
    version: '1.0.0',
    description: 'Peer-to-Peer Book Sharing & Barter Backend API',
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      books: '/api/books',
    },
  });
});

app.use('/api', routes);

app.use(notFoundHandler);
app.use(errorHandler);

export default app;
