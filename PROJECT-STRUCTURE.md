# Project File Structure

This document shows the complete file structure for the URL Shortener DevOps project (Phase 1 - Local Development).

```
devops-url-shortener/
│
├── src/
│   ├── models/
│   │   └── url.js                    # Mongoose schema for URL model
│   │
│   ├── routes/
│   │   └── url.js                    # Express routes for URL operations
│   │
│   ├── controllers/
│   │   └── urlController.js          # Business logic for URL shortening
│   │
│   └── connect.js                    # MongoDB connection configuration
│
├── views/
│   └── index.ejs                     # Simple frontend UI (EJS template)
│
├── index.js                          # Main Express server entry point
├── package.json                      # Node.js dependencies and scripts
├── .dockerignore                     # Files to exclude from Docker build
├── Dockerfile                        # Docker image configuration
├── docker-compose.yml                # Multi-container Docker setup
│
├── .gitignore                        # Git ignore rules
├── SETUP-WSL2.md                     # WSL 2 setup instructions
├── PROJECT-STRUCTURE.md              # This file
└── README.md                         # How to run the project

```

---

## File Descriptions

### Application Files (`src/`)

**`src/models/url.js`**
- Mongoose schema defining the URL document structure
- Fields: original URL, short ID, click analytics

**`src/routes/url.js`**
- Express router defining API endpoints
- Routes: POST /url (create), GET /:shortId (redirect)

**`src/controllers/urlController.js`**
- Controller functions containing business logic
- Handles URL shortening and redirect logic

**`src/connect.js`**
- MongoDB connection setup using Mongoose
- Handles database connection errors and events

### View Files (`views/`)

**`views/index.ejs`**
- Simple HTML form to submit URLs
- Displays shortened URL result
- Uses EJS templating engine

### Root Files

**`index.js`**
- Main application entry point
- Express server setup
- Middleware configuration
- Route mounting

**`package.json`**
- Project metadata
- Dependencies: express, mongoose, shortid, ejs
- NPM scripts for running the app

### Docker Files

**`Dockerfile`**
- Multi-stage build for optimized image
- Node.js Alpine base image
- Production-ready configuration

**`.dockerignore`**
- Excludes node_modules, logs, .git from image
- Reduces image size and build time

**`docker-compose.yml`**
- Defines `api` service (our Node.js app)
- Defines `mongo` service (MongoDB database)
- Sets up networking and volumes

### Documentation Files

**`README.md`**
- Quick start guide
- Step-by-step run instructions
- Testing endpoints

**`SETUP-WSL2.md`**
- Complete WSL 2 setup for Windows 11
- Docker Desktop configuration
- VS Code integration

**`.gitignore`**
- Excludes node_modules, logs, env files
- Keeps repository clean

---

## Next Steps

1. ✅ Review this structure
2. ✅ Ensure all files are created (see README.md)
3. ✅ Follow README.md to run the application locally
4. 🚀 Proceed to Phase 2 (Terraform) after Phase 1 works
