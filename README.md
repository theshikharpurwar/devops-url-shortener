#  Shorty - URL Shortener

<div align="center">

**Lightning-fast URL shortening with stunning modern UI**

[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=flat&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.0-47A248?style=flat&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![GCP](https://img.shields.io/badge/GCP-Deployed-4285F4?style=flat&logo=google-cloud&logoColor=white)](https://cloud.google.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

![GitHub last commit](https://img.shields.io/github/last-commit/theshikharpurwar/devops-url-shortener)

[ Live Demo](http://34.72.126.110:8001)  [ Report Bug](https://github.com/theshikharpurwar/devops-url-shortener/issues)  [ Request Feature](https://github.com/theshikharpurwar/devops-url-shortener/issues)

</div>

---

##  Table of Contents

- [About](#-about)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Usage](#-usage)
- [API Documentation](#-api-documentation)
- [Technology Stack](#-technology-stack)
- [GCP Deployment](#-gcp-deployment)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

---

##  About

**Shorty** is a modern URL shortener built with Node.js, Express, and MongoDB. Features include a stunning animated UI, real-time analytics, enterprise-grade security, and automated deployment to Google Cloud Platform using GitHub Actions.

### Why Shorty?

-  **Beautiful Design** - Animated gradients and glassmorphism effects
-  **Lightning Fast** - Optimized performance with Docker
-  **Analytics Ready** - Track clicks, timestamps, and visitor data
-  **Secure** - Rate limiting, security headers, input validation
-  **Cloud Native** - Deployed on GCP with CI/CD automation

---

##  Features

-  **Instant URL Shortening** - Generate short links in milliseconds
-  **Smart Redirects** - Fast 302 redirects with analytics tracking
-  **Real-time Analytics** - Track clicks, user agents, and IP addresses
-  **Modern UI** - Animated 4-color gradient background
-  **Fully Responsive** - Perfect on all devices
-  **One-Click Copy** - Copy URLs with visual feedback
-  **Helmet.js Security** - 12+ security headers enabled
-  **Rate Limiting** - 10 URLs per 15 minutes per IP
-  **Docker Ready** - Multi-stage builds
-  **GitHub Actions CI/CD** - Automated deployment

---

##  Quick Start

### Prerequisites

- Docker (v20.0+)
- Docker Compose (v2.0+)

### Installation

```bash
# Clone and start
git clone https://github.com/theshikharpurwar/devops-url-shortener.git
cd devops-url-shortener
docker-compose up -d

# Open http://localhost:8001
```

### Verify

```bash
docker ps
curl http://localhost:8001/health
```

---

##  Usage

### Web Interface

1. Open http://localhost:8001
2. Enter a long URL
3. Click " Shorten Now!"
4. Copy and share

### Command Line

```bash
# Create short URL
curl -X POST http://localhost:8001/url \
  -H "Content-Type: application/json" \
  -d '{\"url\": \"https://github.com/theshikharpurwar\"}'

# Get analytics
curl http://localhost:8001/url/analytics/{shortId}
```

---

##  API Documentation

### Endpoints

#### POST /url
Create a short URL

**Request:**
```json
{
  \"url\": \"https://example.com/very/long/url\"
}
```

**Response:** 201 Created
```json
{
  \"success\": true,
  \"id\": \"XyZ123\",
  \"shortUrl\": \"http://localhost:8001/XyZ123\",
  \"originalUrl\": \"https://example.com/very/long/url\"
}
```

#### GET /:shortId
Redirect to original URL (tracks analytics)

**Response:** 302 Found

#### GET /url/analytics/:shortId
Get analytics for a short URL

**Response:** 200 OK
```json
{
  \"success\": true,
  \"shortId\": \"XyZ123\",
  \"originalUrl\": \"https://example.com\",
  \"totalClicks\": 42,
  \"visitHistory\": [...]
}
```

#### GET /health
Health check endpoint

**Response:** 200 OK

---

##  Technology Stack

### Backend
- Node.js 18
- Express.js 4.18
- MongoDB 7.0
- Mongoose 8.0

### Security
- Helmet.js - Security headers
- express-rate-limit - Rate limiting

### Frontend
- EJS 3.1 - Template engine
- CSS3 - Animations
- Google Fonts - Poppins
- Vanilla JavaScript

### DevOps
- Docker & Docker Compose
- GitHub Actions
- Google Cloud Platform
- Google Compute Engine
- Google Artifact Registry

---

##  GCP Deployment

### Architecture

```
GitHub  GitHub Actions  Artifact Registry  Compute Engine
```

### CI/CD Pipeline

**Triggers:**
- Push to main  Build, test, deploy
- Pull Request  Build and test only

**Jobs:**
1. Build & Test - Install deps, run tests
2. Deploy - Push to GCP, deploy containers

### Resources

- **Project:** banded-oven-471507-q9
- **Region:** us-central1
- **VM:** url-shortener-vm
- **IP:** 34.72.126.110

---

##  Security

-  Helmet.js security headers
-  Rate limiting (10 URLs/15min)
-  Input validation
-  CORS protection
-  XSS protection

---

##  Troubleshooting

### Port in use
```bash
netstat -ano | findstr :8001
# Change port in docker-compose.yml
```

### MongoDB connection failed
```bash
docker-compose restart mongo
# Or fresh start:
docker-compose down -v
docker-compose up -d
```

### Check logs
```bash
docker-compose logs -f api
docker logs url-shortener-api
```

---

##  Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push and open PR

---

##  License

MIT License - Copyright (c) 2025 Shikhar Purwar

---

##  Contact

- **Author:** Shikhar Purwar
- **GitHub:** [@theshikharpurwar](https://github.com/theshikharpurwar)
- **Repository:** [devops-url-shortener](https://github.com/theshikharpurwar/devops-url-shortener)

---

<div align="center">

**Built with  using modern DevOps practices**

**Deployed on Google Cloud Platform**

[ Back to Top](#-shorty---url-shortener)

</div>
