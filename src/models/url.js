const mongoose = require('mongoose');

/**
 * URL Schema
 * Stores original URL, short ID, and analytics data
 */
const urlSchema = new mongoose.Schema(
  {
    shortId: {
      type: String,
      required: true,
      unique: true,
    },
    redirectURL: {
      type: String,
      required: true,
    },
    visitHistory: [
      {
        timestamp: {
          type: Date,
          default: Date.now,
        },
        userAgent: String,
        ipAddress: String,
      },
    ],
    clickCount: {
      type: Number,
      default: 0,
    },
  },
  { 
    timestamps: true,
    versionKey: false 
  }
);

// Create model - Export as UrlModel to avoid conflicts with global URL
const UrlModel = mongoose.model('URL', urlSchema);

module.exports = UrlModel;
