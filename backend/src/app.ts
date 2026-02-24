import express from 'express';
import cors from 'cors';
import { errorHandler } from './middleware/error.middleware';
import { router } from './routes';

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api', router);

// Error handler (must be last)
app.use(errorHandler);

export default app;
