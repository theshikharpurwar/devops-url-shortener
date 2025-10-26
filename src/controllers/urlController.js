const URL = require('../models/url');
const shortid = require('shortid');

/**
 * Generate a short URL
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
async function handleGenerateNewShortURL(req, res) {
  const { url } = req.body;

  // Validate URL
  if (!url) {
    return res.status(400).json({ 
      error: 'URL is required',
      success: false 
    });
  }

  // Validate URL format
  try {
    new URL(url);
  } catch (error) {
    return res.status(400).json({ 
      error: 'Invalid URL format',
      success: false 
    });
  }

  try {
    // Generate short ID
    const shortId = shortid.generate();

    // Create new URL entry
    await URL.create({
      shortId: shortId,
      redirectURL: url,
      visitHistory: [],
    });

    // Return success response
    return res.status(201).json({
      success: true,
      id: shortId,
      shortUrl: `${req.protocol}://${req.get('host')}/${shortId}`,
      originalUrl: url
    });
  } catch (error) {
    console.error('Error generating short URL:', error);
    return res.status(500).json({ 
      error: 'Internal server error',
      success: false 
    });
  }
}

/**
 * Redirect to original URL
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
async function handleRedirect(req, res) {
  const shortId = req.params.shortId;

  try {
    // Find URL and update analytics
    const entry = await URL.findOneAndUpdate(
      { shortId },
      {
        $push: {
          visitHistory: {
            timestamp: Date.now(),
            userAgent: req.headers['user-agent'],
            ipAddress: req.ip,
          },
        },
        $inc: { clickCount: 1 },
      },
      { new: true }
    );

    if (!entry) {
      return res.status(404).json({ 
        error: 'Short URL not found',
        success: false 
      });
    }

    // Redirect to original URL
    return res.redirect(entry.redirectURL);
  } catch (error) {
    console.error('Error redirecting:', error);
    return res.status(500).json({ 
      error: 'Internal server error',
      success: false 
    });
  }
}

/**
 * Get analytics for a short URL
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
async function handleGetAnalytics(req, res) {
  const shortId = req.params.shortId;

  try {
    const entry = await URL.findOne({ shortId });

    if (!entry) {
      return res.status(404).json({ 
        error: 'Short URL not found',
        success: false 
      });
    }

    return res.json({
      success: true,
      shortId: entry.shortId,
      originalUrl: entry.redirectURL,
      totalClicks: entry.clickCount,
      visitHistory: entry.visitHistory,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    });
  } catch (error) {
    console.error('Error fetching analytics:', error);
    return res.status(500).json({ 
      error: 'Internal server error',
      success: false 
    });
  }
}

module.exports = {
  handleGenerateNewShortURL,
  handleRedirect,
  handleGetAnalytics,
};
