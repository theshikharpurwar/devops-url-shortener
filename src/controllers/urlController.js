const URL = require('../models/url');
const shortid = require('shortid');

/**
 * Generate a short URL
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
async function handleGenerateNewShortURL(req, res) {
  const { url } = req.body;
  
  console.log('Received URL shortening request:', { url, body: req.body });

  // Validate URL
  if (!url) {
    console.log('Validation failed: URL is required');
    return res.status(400).json({ 
      error: 'URL is required',
      success: false 
    });
  }

  // Validate URL format - be more permissive
  try {
    // Add protocol if missing
    let urlToValidate = url.trim();
    if (!urlToValidate.match(/^https?:\/\//i)) {
      console.log('Adding https:// protocol to URL');
      urlToValidate = 'https://' + urlToValidate;
    }
    new URL(urlToValidate);
    
    console.log('URL validated successfully:', urlToValidate);
    
    // Use the validated URL (with protocol if added)
    const finalUrl = urlToValidate;
    
    // Generate short ID
    const shortId = shortid.generate();
    console.log('Generated short ID:', shortId);

    // Create new URL entry
    await URL.create({
      shortId: shortId,
      redirectURL: finalUrl,
      visitHistory: [],
    });
    
    console.log('URL entry created successfully');

    // Return success response
    return res.status(201).json({
      success: true,
      id: shortId,
      shortUrl: `${req.protocol}://${req.get('host')}/${shortId}`,
      originalUrl: finalUrl
    });
  } catch (error) {
    console.error('Error in handleGenerateNewShortURL:', error);
    return res.status(400).json({ 
      error: 'Invalid URL format. Please enter a valid URL.',
      success: false,
      details: error.message
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
