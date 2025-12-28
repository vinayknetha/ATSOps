# TalentForge ATS

## Overview
TalentForge is an AI-powered Applicant Tracking System (ATS) built with React and Vite. It provides modern recruitment and hiring workflows with intuitive interfaces for managing candidates, jobs, and interviews.

## Project Architecture

### Tech Stack
- **Frontend Framework**: React 18 with Vite 5
- **Backend API**: Express.js on port 3001
- **Database**: PostgreSQL (via pg driver)
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

server/
└── index.js         # Express API server with PostgreSQL connection

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
- December 28, 2025: Page-Based Navigation Architecture
  - Replaced modals/panels with full-page navigation for better UX
  - Added Breadcrumbs component for navigation hierarchy
  - AddCandidatePage: Full page with "Candidates → Add New Candidate" breadcrumbs
  - CandidateDetailPage: Full page with "Candidates → [Candidate Name]" breadcrumbs
  - navigateTo() function manages view state and selected candidate
  - CandidatesView uses callback props (onAddCandidate, onSelectCandidate)
- December 28, 2025: Full Candidate Management with Database Persistence
  - Added POST /api/candidates endpoint to save new candidates to PostgreSQL
  - Candidates view now fetches real data from database instead of mock data
  - New candidates appear immediately in the UI after saving
  - Added error handling for duplicate emails and validation
- December 28, 2025: AI-powered Resume Parsing
  - Added /api/resume/parse endpoint for resume text extraction and AI parsing
  - Integrated OpenAI (via Replit AI Integrations) for intelligent data extraction
  - Uses pdf2json for PDF files and mammoth for DOCX files
  - Add Candidate modal now auto-populates fields (name, email, phone, title, company, location) from uploaded resume
  - Visual feedback during parsing with loading state and success indicators
  - Form fields highlight green when auto-populated from resume
- December 28, 2025: Database integration for Dashboard
  - Created Express.js backend API (server/index.js) on port 3001
  - Added API endpoints: /api/dashboard/stats, candidates, jobs, interviews, pipeline, activity
  - Updated Dashboard.jsx to fetch real data from PostgreSQL database
  - Configured Vite proxy to route /api requests to backend
  - Updated npm scripts to run frontend and backend concurrently
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
