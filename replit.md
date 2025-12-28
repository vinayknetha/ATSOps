# TalentForge ATS

## Overview
TalentForge is an AI-powered Applicant Tracking System (ATS) built with React and Vite. It provides modern recruitment and hiring workflows with intuitive interfaces for managing candidates, jobs, and interviews.

## Project Architecture

### Tech Stack
- **Frontend Framework**: React 18 with Vite 5
- **Styling**: Tailwind CSS with custom styles
- **State Management**: Zustand
- **Routing**: React Router DOM v6
- **Charts**: Recharts
- **Animations**: Framer Motion
- **Icons**: Lucide React
- **Date Utilities**: date-fns

### Directory Structure
```
src/
├── assets/          # Static assets
├── components/      # Reusable UI components
│   ├── Components.jsx
│   └── Icons.jsx
├── hooks/           # Custom React hooks
├── pages/           # Page components
│   ├── Dashboard.jsx
│   └── Landing.jsx
├── styles/          # Global CSS styles
├── utils/           # Utility functions
├── App.jsx          # Main app component
└── index.jsx        # Entry point

api/                 # API specification docs
database/            # Database schema and migrations
docs/                # Documentation
```

### Key Configuration
- **Dev Server**: Port 5000 on 0.0.0.0
- **Build Output**: dist/
- **Path Aliases**: @, @components, @pages, @styles, @hooks, @utils, @assets

## Development Commands
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run format` - Format code with Prettier

## Recent Changes
- December 28, 2025: Initial Replit setup
  - Configured Vite for port 5000 with allowedHosts
  - Fixed syntax error in Dashboard.jsx (line 2608)
  - Set up development workflow
  - Configured autoscale deployment

## Database
- **PostgreSQL** with 86 tables for complete ATS functionality
- **Extensions**: uuid-ossp, pg_trgm, unaccent
- **India-specific data**: 
  - 15 Indian states/territories
  - 15 major Indian cities (Mumbai, Bangalore, Chennai, Delhi, Hyderabad, etc.)
  - INR currency as primary
  - 10 Indian languages (Hindi, Tamil, Telugu, Marathi, etc.)
  - Indian job boards (Naukri, Shine, TimesJobs, Instahyre)
  - Subscription plans with INR pricing

## Notes
- API specifications are documented in the api/ directory
- Multi-tenant architecture with organization isolation
- Full-text search enabled on candidates and jobs tables
