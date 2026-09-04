import http from 'http';
import dotenv from 'dotenv';
dotenv.config();

import app from './app';
import prisma from './config/prisma';
import { ensureDatabaseExists } from './config/database';
import { initSocket } from './socket';

const PORT = process.env.PORT || 5000;

async function bootstrap() {
  try {
    await ensureDatabaseExists();
    await prisma.$connect();
    console.log('Connected to PostgreSQL via Prisma ORM');
  } catch (error: any) {
    console.warn('Database connection warning:', error.message);
  }

  const server = http.createServer(app);
  initSocket(server);

  server.listen(PORT, () => {
    console.log(`Server listening on port ${PORT} with Socket.IO enabled`);
  });

  const shutdown = async () => {
    console.log('Shutting down server...');
    await prisma.$disconnect();
    server.close(() => {
      process.exit(0);
    });
  };

  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

bootstrap();
