const express = require('express');
const {
  handleGenerateNewShortURL,
  handleRedirect,
  handleGetAnalytics,
} = require('../controllers/urlController');

const router = express.Router();

/**
 * POST /url
 * Generate a new short URL
 */
router.post('/', handleGenerateNewShortURL);

/**
 * GET /analytics/:shortId
 * Get analytics for a short URL
 */
router.get('/analytics/:shortId', handleGetAnalytics);

/**
 * GET /:shortId
 * Redirect to original URL
 */
router.get('/:shortId', handleRedirect);

module.exports = router;
