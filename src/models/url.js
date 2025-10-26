const mongoose = require('mongoose');
const shortid = require('shortid');

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
      default: shortid.generate,
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

// Index for faster lookups
urlSchema.index({ shortId: 1 });

const URL = mongoose.model('URL', urlSchema);

module.exports = URL;
