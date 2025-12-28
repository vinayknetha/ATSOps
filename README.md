# TalentForge ATS

<div align="center">
  <img src="src/assets/logo.svg" alt="TalentForge Logo" width="120" />
  
  # ⚡ TalentForge
  
  **The Modern AI-Powered Applicant Tracking System**
  
  [![React](https://img.shields.io/badge/React-18.2-61DAFB?logo=react)](https://reactjs.org/)
  [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?logo=postgresql)](https://postgresql.org/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  
  [Demo](https://demo.talentforge.io) • [Documentation](https://docs.talentforge.io) • [API Reference](api/)
</div>

---

## 🚀 Overview

TalentForge is a comprehensive, enterprise-grade Applicant Tracking System that combines AI-powered candidate matching with intuitive workflows. Find, engage, and hire the best talent 60% faster.

### ✨ Key Features

- **🎯 AI-Powered Matching** - Intelligent algorithms analyze skills, experience, and cultural fit
- **📊 Smart Pipelines** - Customizable hiring workflows that adapt to your process
- **👥 Collaborative Hiring** - Shared scorecards, feedback, and real-time communication
- **📈 Analytics & Insights** - Data-driven decisions with comprehensive dashboards
- **🔌 200+ Integrations** - Connect with your existing tools seamlessly
- **🔒 Enterprise Security** - SOC 2, GDPR, and ISO 27001 compliant

---

## 📁 Project Structure

```
talentforge-ats/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── Components.jsx   # Component library (Button, Input, Modal, etc.)
│   │   └── Icons.jsx        # SVG icon library
│   ├── pages/               # Application pages
│   │   ├── Dashboard.jsx    # Main ATS dashboard
│   │   └── Landing.jsx      # Marketing landing page
│   ├── styles/              # Global styles and themes
│   ├── hooks/               # Custom React hooks
│   ├── utils/               # Utility functions
│   └── assets/              # Static assets
├── database/
│   ├── migrations/          # SQL migration files
│   │   ├── 001_lookup_tables.sql
│   │   ├── 002_organizations_users.sql
│   │   ├── 003_candidates.sql
│   │   ├── 004_jobs.sql
│   │   ├── 005_applications_interviews.sql
│   │   ├── 006_communications_documents.sql
│   │   ├── 007_integrations_billing.sql
│   │   ├── 008_functions_triggers_seed.sql
│   │   └── TalentForge_Complete_Schema.sql
│   ├── seeds/               # Seed data
│   └── README.md            # Database documentation
├── api/
│   ├── api-spec-part1.md    # Auth, Organizations, Users
│   ├── api-spec-part2.md    # Candidates
│   ├── api-spec-part3.md    # Jobs & Requisitions
│   ├── api-spec-part4.md    # Applications
│   ├── api-spec-part5.md    # Interviews & Offers
│   ├── api-spec-part6.md    # Communications, Documents, Notes
│   └── api-spec-part7.md    # Analytics, Integrations, Billing
├── docs/                    # Additional documentation
├── package.json
└── README.md
```

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: React 18 with Hooks
- **Styling**: CSS-in-JS with custom theme system
- **State Management**: Zustand
- **Animations**: Framer Motion
- **Charts**: Recharts
- **Icons**: Custom SVG icon library

### Backend (Recommended)
- **Runtime**: Node.js 18+
- **Framework**: Express.js or Fastify
- **Database**: PostgreSQL 15+
- **Cache**: Redis
- **Search**: Elasticsearch or PostgreSQL FTS

### Infrastructure
- **Cloud**: AWS / GCP / Azure
- **Container**: Docker + Kubernetes
- **CI/CD**: GitHub Actions
- **CDN**: CloudFront / Cloudflare

---

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- PostgreSQL 15+
- npm or yarn

### Installation

```bash
# Clone the repository
git clone https://github.com/talentforge/talentforge-ats.git
cd talentforge-ats

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env

# Set up database
psql -d postgres -c "CREATE DATABASE talentforge;"
psql -d talentforge -f database/migrations/TalentForge_Complete_Schema.sql

# Start development server
npm run dev
```

### Environment Variables

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/talentforge

# Authentication
JWT_SECRET=your-super-secret-key
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d

# Email
SENDGRID_API_KEY=your-sendgrid-key
EMAIL_FROM=noreply@talentforge.io

# Storage
AWS_S3_BUCKET=talentforge-uploads
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key

# AI Features
OPENAI_API_KEY=your-openai-key
```

---

## 📊 Database Schema

The database consists of **65+ tables** organized into the following domains:

| Domain | Tables | Description |
|--------|--------|-------------|
| **Lookup** | 12 | Countries, skills, industries, job types |
| **Organizations** | 14 | Multi-tenant orgs, users, auth, RBAC |
| **Candidates** | 12 | Profiles, experience, education, skills |
| **Jobs** | 10 | Requisitions, requirements, pipelines |
| **Applications** | 14 | Applications, interviews, scorecards, offers |
| **Communications** | 12 | Email, documents, notes, tags |
| **Integrations** | 12 | Integrations, webhooks, billing |

See [database/README.md](database/README.md) for detailed documentation.

---

## 🔌 API Reference

The REST API provides **200+ endpoints** across 16 modules:

| Module | Endpoints | Description |
|--------|-----------|-------------|
| Authentication | 15 | Login, register, OAuth, MFA |
| Organizations | 12 | Org management, settings, branding |
| Users & Teams | 18 | User management, roles, permissions |
| Candidates | 35 | Full candidate lifecycle |
| Jobs | 25 | Job postings, pipelines, team |
| Applications | 30 | Application workflow, scoring |
| Interviews | 20 | Scheduling, feedback, scorecards |
| Offers | 15 | Offer workflow, approvals |
| Communications | 18 | Email, templates, tracking |
| Analytics | 15 | Dashboards, reports, exports |

See [api/](api/) for complete API documentation.

---

## 🎨 UI Components

The component library includes:

### Core Components
- `Button` - Primary, secondary, outline, ghost, danger variants
- `Input` - Text, password, search with validation
- `Select` - Dropdown with search and multi-select
- `Modal` - Configurable dialog with footer actions
- `Tabs` - Tab navigation with badges

### Data Display
- `Badge` - Status indicators with variants
- `Avatar` - User avatars with status dots
- `Card` - Container with hover effects
- `ProgressBar` - Linear progress indicator
- `ScoreRing` - Circular score visualization

### Feedback
- `Spinner` - Loading indicator
- `Skeleton` - Content placeholder
- `Tooltip` - Hover tooltips
- `EmptyState` - Empty content placeholder

See [src/components/Components.jsx](src/components/Components.jsx) for implementation.

---

## 📱 Screenshots

<div align="center">
  <img src="docs/screenshots/dashboard.png" alt="Dashboard" width="45%" />
  <img src="docs/screenshots/candidates.png" alt="Candidates" width="45%" />
</div>

---

## 🧪 Testing

```bash
# Run unit tests
npm run test

# Run e2e tests
npm run test:e2e

# Run with coverage
npm run test:coverage
```

---

## 📦 Deployment

### Docker

```bash
# Build image
docker build -t talentforge-ats .

# Run container
docker run -p 3000:3000 talentforge-ats
```

### Docker Compose

```bash
docker-compose up -d
```

### Kubernetes

```bash
kubectl apply -f k8s/
```

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [React](https://reactjs.org/) - UI Framework
- [PostgreSQL](https://postgresql.org/) - Database
- [Framer Motion](https://framer.com/motion/) - Animations
- [Recharts](https://recharts.org/) - Charts

---

<div align="center">
  <p>Built with ❤️ by the TalentForge Team</p>
  <p>
    <a href="https://talentforge.io">Website</a> •
    <a href="https://docs.talentforge.io">Documentation</a> •
    <a href="https://twitter.com/talentforge">Twitter</a>
  </p>
</div>
