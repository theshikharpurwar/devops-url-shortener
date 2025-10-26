const express = require('express');
const path = require('path');
require('dotenv').config();
const connectToMongoDB = require('./src/connect');
const urlRoute = require('./src/routes/url');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 8001;
const MONGO_URL = process.env.MONGO_URL || 'mongodb://mongo:27017/url-shortener';

// Connect to MongoDB
connectToMongoDB(MONGO_URL);

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Set view engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Routes
// Home page
app.get('/', (req, res) => {
  res.render('index', { 
    shortUrl: null,
    error: null 
  });
});

// API routes
app.use('/url', urlRoute);

// Redirect route (must be last)
app.get('/:shortId', async (req, res, next) => {
  // This will be handled by the url route
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK',
    message: 'Server is running',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    error: 'Not Found',
    message: 'The requested resource was not found'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({ 
    error: 'Internal Server Error',
    message: err.message 
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server started on port ${PORT}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📊 MongoDB URL: ${MONGO_URL}`);
  console.log(`✅ Health check available at http://localhost:${PORT}/health`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});

module.exports = app;
