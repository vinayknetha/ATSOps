import React, { useState, useEffect, useRef } from 'react';

// ============================================================================
// TALENTFORGE ATS - ENTERPRISE UI
// A stunning, production-grade Applicant Tracking System interface
// ============================================================================

// Theme Configuration
const theme = {
  colors: {
    // Primary palette - Deep navy with electric accents
    primary: '#0A1628',
    secondary: '#1A2942',
    tertiary: '#243B55',
    
    // Accent colors
    accent: '#00D4FF',
    accentAlt: '#7B61FF',
    accentGreen: '#00E5A0',
    accentOrange: '#FF6B35',
    accentPink: '#FF3D71',
    
    // Neutrals
    white: '#FFFFFF',
    gray100: '#F7F9FC',
    gray200: '#E4E9F2',
    gray300: '#C5CEE0',
    gray400: '#8F9BB3',
    gray500: '#5D6B82',
    
    // Status colors
    success: '#00E5A0',
    warning: '#FFB800',
    error: '#FF3D71',
    info: '#00D4FF',
    
    // Gradients
    gradientPrimary: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    gradientDark: 'linear-gradient(180deg, #0A1628 0%, #1A2942 100%)',
    gradientGlow: 'radial-gradient(circle at 50% 50%, rgba(0, 212, 255, 0.15) 0%, transparent 70%)',
  },
  fonts: {
    heading: "'Plus Jakarta Sans', sans-serif",
    body: "'Inter', sans-serif",
    mono: "'JetBrains Mono', monospace",
  },
  shadows: {
    sm: '0 2px 8px rgba(0, 0, 0, 0.15)',
    md: '0 4px 20px rgba(0, 0, 0, 0.2)',
    lg: '0 8px 40px rgba(0, 0, 0, 0.3)',
    glow: '0 0 40px rgba(0, 212, 255, 0.3)',
    glowPurple: '0 0 40px rgba(123, 97, 255, 0.3)',
  },
  radius: {
    sm: '8px',
    md: '12px',
    lg: '16px',
    xl: '24px',
    full: '9999px',
  },
};

// ============================================================================
// ICONS COMPONENT
// ============================================================================
const Icons = {
  Dashboard: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <rect x="3" y="3" width="7" height="9" rx="1" />
      <rect x="14" y="3" width="7" height="5" rx="1" />
      <rect x="14" y="12" width="7" height="9" rx="1" />
      <rect x="3" y="16" width="7" height="5" rx="1" />
    </svg>
  ),
  Jobs: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <rect x="2" y="7" width="20" height="14" rx="2" />
      <path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2" />
      <line x1="12" y1="12" x2="12" y2="12.01" />
    </svg>
  ),
  Candidates: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
      <circle cx="9" cy="7" r="4" />
      <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
      <path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  ),
  Applications: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
      <polyline points="14 2 14 8 20 8" />
      <line x1="16" y1="13" x2="8" y2="13" />
      <line x1="16" y1="17" x2="8" y2="17" />
    </svg>
  ),
  Interviews: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
      <line x1="16" y1="2" x2="16" y2="6" />
      <line x1="8" y1="2" x2="8" y2="6" />
      <line x1="3" y1="10" x2="21" y2="10" />
      <circle cx="12" cy="16" r="2" />
    </svg>
  ),
  Offers: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
      <polyline points="22 4 12 14.01 9 11.01" />
    </svg>
  ),
  Analytics: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <line x1="18" y1="20" x2="18" y2="10" />
      <line x1="12" y1="20" x2="12" y2="4" />
      <line x1="6" y1="20" x2="6" y2="14" />
    </svg>
  ),
  Settings: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="12" r="3" />
      <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42" />
    </svg>
  ),
  Search: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="11" cy="11" r="8" />
      <line x1="21" y1="21" x2="16.65" y2="16.65" />
    </svg>
  ),
  Bell: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
      <path d="M13.73 21a2 2 0 0 1-3.46 0" />
    </svg>
  ),
  Plus: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <line x1="12" y1="5" x2="12" y2="19" />
      <line x1="5" y1="12" x2="19" y2="12" />
    </svg>
  ),
  ChevronDown: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polyline points="6 9 12 15 18 9" />
    </svg>
  ),
  ChevronRight: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polyline points="9 18 15 12 9 6" />
    </svg>
  ),
  ArrowUp: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <line x1="12" y1="19" x2="12" y2="5" />
      <polyline points="5 12 12 5 19 12" />
    </svg>
  ),
  ArrowDown: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <line x1="12" y1="5" x2="12" y2="19" />
      <polyline points="19 12 12 19 5 12" />
    </svg>
  ),
  Star: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" strokeWidth="2">
      <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
    </svg>
  ),
  Users: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
      <circle cx="9" cy="7" r="4" />
      <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
      <path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  ),
  Mail: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
      <polyline points="22,6 12,13 2,6" />
    </svg>
  ),
  Phone: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
    </svg>
  ),
  MapPin: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z" />
      <circle cx="12" cy="10" r="3" />
    </svg>
  ),
  Calendar: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
      <line x1="16" y1="2" x2="16" y2="6" />
      <line x1="8" y1="2" x2="8" y2="6" />
      <line x1="3" y1="10" x2="21" y2="10" />
    </svg>
  ),
  Clock: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="12" r="10" />
      <polyline points="12 6 12 12 16 14" />
    </svg>
  ),
  Filter: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3" />
    </svg>
  ),
  MoreVertical: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="12" r="1" />
      <circle cx="12" cy="5" r="1" />
      <circle cx="12" cy="19" r="1" />
    </svg>
  ),
  ExternalLink: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
      <polyline points="15 3 21 3 21 9" />
      <line x1="10" y1="14" x2="21" y2="3" />
    </svg>
  ),
  Sparkles: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M12 3L13.5 8.5L19 10L13.5 11.5L12 17L10.5 11.5L5 10L10.5 8.5L12 3Z" />
      <path d="M19 15L20 18L23 19L20 20L19 23L18 20L15 19L18 18L19 15Z" />
    </svg>
  ),
  Zap: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
    </svg>
  ),
  TrendingUp: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polyline points="23 6 13.5 15.5 8.5 10.5 1 18" />
      <polyline points="17 6 23 6 23 12" />
    </svg>
  ),
  Target: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="12" r="10" />
      <circle cx="12" cy="12" r="6" />
      <circle cx="12" cy="12" r="2" />
    </svg>
  ),
  Award: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <circle cx="12" cy="8" r="7" />
      <polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88" />
    </svg>
  ),
  Briefcase: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <rect x="2" y="7" width="20" height="14" rx="2" ry="2" />
      <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16" />
    </svg>
  ),
  Eye: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  ),
  Upload: () => (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
      <polyline points="17 8 12 3 7 8" />
      <line x1="12" y1="3" x2="12" y2="15" />
    </svg>
  ),
  Edit: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
      <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
    </svg>
  ),
  Trash: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polyline points="3 6 5 6 21 6" />
      <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
    </svg>
  ),
  Video: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polygon points="23 7 16 12 23 17 23 7" />
      <rect x="1" y="5" width="15" height="14" rx="2" ry="2" />
    </svg>
  ),
  FileText: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
      <polyline points="14 2 14 8 20 8" />
      <line x1="16" y1="13" x2="8" y2="13" />
      <line x1="16" y1="17" x2="8" y2="17" />
    </svg>
  ),
  Send: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <line x1="22" y1="2" x2="11" y2="13" />
      <polygon points="22 2 15 22 11 13 2 9 22 2" />
    </svg>
  ),
  Menu: () => (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <line x1="3" y1="12" x2="21" y2="12" />
      <line x1="3" y1="6" x2="21" y2="6" />
      <line x1="3" y1="18" x2="21" y2="18" />
    </svg>
  ),
  X: () => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <line x1="18" y1="6" x2="6" y2="18" />
      <line x1="6" y1="6" x2="18" y2="18" />
    </svg>
  ),
  Check: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
      <polyline points="20 6 9 17 4 12" />
    </svg>
  ),
  LinkedIn: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
      <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
    </svg>
  ),
  GitHub: () => (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
      <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
    </svg>
  ),
};

// ============================================================================
// API BASE URL
// ============================================================================
const API_BASE = '/api';

// Default data (used as fallback while loading)
const defaultCandidates = [];
const defaultJobs = [];
const defaultInterviews = [];
const defaultPipeline = [
  { id: 'applied', name: 'New', count: 0, color: '#00D4FF' },
  { id: 'screening', name: 'Screening', count: 0, color: '#7B61FF' },
  { id: 'interview', name: 'Interview', count: 0, color: '#FFB800' },
  { id: 'offer', name: 'Offer', count: 0, color: '#00E5A0' },
  { id: 'hired', name: 'Hired', count: 0, color: '#FF6B35' },
];
const defaultStats = {
  total_candidates: '0',
  active_jobs: '0',
  interviews_today: '0',
  offers_sent: '0'
};
const defaultActivity = [];

// Mock data for other views (until they're converted to API)
const mockCandidates = [
  { id: 1, name: 'Priya Sharma', title: 'Senior Software Engineer', company: 'Infosys', location: 'Bangalore', score: 94, skills: ['React', 'TypeScript', 'Node.js', 'AWS'], avatar: '👩‍💻', status: 'Interview', appliedDate: '2 days ago', experience: '8 years' },
  { id: 2, name: 'Rahul Verma', title: 'Product Manager', company: 'Flipkart', location: 'Mumbai', score: 89, skills: ['Product Strategy', 'Agile', 'Analytics'], avatar: '👨‍💼', status: 'Phone Screen', appliedDate: '3 days ago', experience: '6 years' },
  { id: 3, name: 'Anita Patel', title: 'UX Designer', company: 'Zoho', location: 'Chennai', score: 91, skills: ['Figma', 'User Research', 'Prototyping'], avatar: '👩‍🎨', status: 'New', appliedDate: '1 day ago', experience: '5 years' },
  { id: 4, name: 'Vikram Singh', title: 'Data Scientist', company: 'TCS', location: 'Hyderabad', score: 87, skills: ['Python', 'ML', 'TensorFlow', 'SQL'], avatar: '👨‍🔬', status: 'Offer', appliedDate: '5 days ago', experience: '7 years' },
  { id: 5, name: 'Kavitha Reddy', title: 'DevOps Engineer', company: 'Wipro', location: 'Pune', score: 92, skills: ['Kubernetes', 'Docker', 'Terraform', 'CI/CD'], avatar: '👩‍🔧', status: 'Technical Interview', appliedDate: '4 days ago', experience: '6 years' },
  { id: 6, name: 'Arjun Kumar', title: 'Frontend Developer', company: 'Paytm', location: 'Delhi', score: 85, skills: ['Vue.js', 'JavaScript', 'CSS', 'GraphQL'], avatar: '👨‍💻', status: 'Review', appliedDate: '1 day ago', experience: '4 years' },
];

const mockJobs = [
  { id: 1, title: 'Senior Software Engineer', department: 'Engineering', location: 'Bangalore', type: 'Full-time', applicants: 45, newApplicants: 12, status: 'Active', posted: '5 days ago', salary: '₹25L - ₹40L' },
  { id: 2, title: 'Product Manager', department: 'Product', location: 'Mumbai', type: 'Full-time', applicants: 38, newApplicants: 8, status: 'Active', posted: '3 days ago', salary: '₹30L - ₹45L' },
  { id: 3, title: 'UX Designer', department: 'Design', location: 'Remote', type: 'Full-time', applicants: 52, newApplicants: 15, status: 'Active', posted: '7 days ago', salary: '₹18L - ₹28L' },
  { id: 4, title: 'Data Scientist', department: 'Data', location: 'Hyderabad', type: 'Full-time', applicants: 29, newApplicants: 5, status: 'Active', posted: '10 days ago', salary: '₹28L - ₹42L' },
  { id: 5, title: 'DevOps Engineer', department: 'Engineering', location: 'Pune', type: 'Full-time', applicants: 21, newApplicants: 3, status: 'Paused', posted: '14 days ago', salary: '₹22L - ₹35L' },
];

const mockInterviews = [
  { id: 1, candidate: 'Priya Sharma', position: 'Senior Software Engineer', type: 'Technical Interview', time: '10:00 AM', date: 'Today', interviewer: 'Rajesh Kumar', status: 'Scheduled', avatar: '👩‍💻' },
  { id: 2, candidate: 'Rahul Verma', position: 'Product Manager', type: 'Phone Screen', time: '2:00 PM', date: 'Today', interviewer: 'Sneha Gupta', status: 'Scheduled', avatar: '👨‍💼' },
  { id: 3, candidate: 'Kavitha Reddy', position: 'DevOps Engineer', type: 'Culture Fit', time: '11:30 AM', date: 'Tomorrow', interviewer: 'Amit Joshi', status: 'Confirmed', avatar: '👩‍🔧' },
  { id: 4, candidate: 'Anita Patel', position: 'UX Designer', type: 'Portfolio Review', time: '3:00 PM', date: 'Tomorrow', interviewer: 'Meera Shah', status: 'Pending', avatar: '👩‍🎨' },
];

// ============================================================================
// MAIN APPLICATION
// ============================================================================
function Breadcrumbs({ items, onNavigate }) {
  return (
    <div style={styles.breadcrumbs}>
      {items.map((item, index) => (
        <React.Fragment key={index}>
          {index > 0 && <span style={styles.breadcrumbSeparator}>/</span>}
          {item.onClick ? (
            <button style={styles.breadcrumbLink} onClick={item.onClick}>
              {item.label}
            </button>
          ) : (
            <span style={styles.breadcrumbCurrent}>{item.label}</span>
          )}
        </React.Fragment>
      ))}
    </div>
  );
}

export default function TalentForgeATS() {
  const [currentView, setCurrentView] = useState('dashboard');
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [showNotifications, setShowNotifications] = useState(false);
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [selectedCandidate, setSelectedCandidate] = useState(null);
  const [animationReady, setAnimationReady] = useState(false);

  const navigateTo = (view, candidate = null) => {
    setCurrentView(view);
    setSelectedCandidate(candidate);
  };

  useEffect(() => {
    setTimeout(() => setAnimationReady(true), 100);
  }, []);

  const navItems = [
    { id: 'dashboard', label: 'Dashboard', icon: Icons.Dashboard },
    { id: 'jobs', label: 'Jobs', icon: Icons.Jobs, badge: 5 },
    { id: 'candidates', label: 'Candidates', icon: Icons.Candidates, badge: 24 },
    { id: 'applications', label: 'Applications', icon: Icons.Applications },
    { id: 'interviews', label: 'Interviews', icon: Icons.Interviews, badge: 4 },
    { id: 'offers', label: 'Offers', icon: Icons.Offers },
    { id: 'analytics', label: 'Analytics', icon: Icons.Analytics },
    { id: 'settings', label: 'Settings', icon: Icons.Settings },
  ];

  return (
    <div style={styles.appContainer}>
      <style>{globalStyles}</style>
      
      {/* Sidebar */}
      <aside style={{
        ...styles.sidebar,
        width: sidebarCollapsed ? '80px' : '260px',
        transform: animationReady ? 'translateX(0)' : 'translateX(-100%)',
      }}>
        {/* Logo */}
        <div style={styles.logoContainer}>
          <div style={styles.logoIcon}>
            <Icons.Zap />
          </div>
          {!sidebarCollapsed && (
            <span style={styles.logoText}>TalentForge</span>
          )}
        </div>

        {/* Navigation */}
        <nav style={styles.nav}>
          {navItems.map((item, index) => (
            <button
              key={item.id}
              style={{
                ...styles.navItem,
                ...(currentView === item.id ? styles.navItemActive : {}),
                animationDelay: `${index * 50}ms`,
              }}
              onClick={() => setCurrentView(item.id)}
              className="nav-item"
            >
              <span style={styles.navIcon}>
                <item.icon />
              </span>
              {!sidebarCollapsed && (
                <>
                  <span style={styles.navLabel}>{item.label}</span>
                  {item.badge && (
                    <span style={styles.navBadge}>{item.badge}</span>
                  )}
                </>
              )}
              {currentView === item.id && (
                <div style={styles.navIndicator} />
              )}
            </button>
          ))}
        </nav>

        {/* AI Assistant Card */}
        {!sidebarCollapsed && (
          <div style={styles.aiCard}>
            <div style={styles.aiCardHeader}>
              <Icons.Sparkles />
              <span>AI Assistant</span>
            </div>
            <p style={styles.aiCardText}>
              Get intelligent candidate recommendations and insights
            </p>
            <button style={styles.aiCardButton}>
              Ask AI
            </button>
          </div>
        )}

        {/* Collapse Toggle */}
        <button 
          style={styles.collapseBtn}
          onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
        >
          <Icons.ChevronRight />
        </button>
      </aside>

      {/* Main Content */}
      <main style={{
        ...styles.mainContent,
        marginLeft: sidebarCollapsed ? '80px' : '260px',
      }}>
        {/* Top Bar */}
        <header style={styles.topBar}>
          <div style={styles.searchContainer}>
            <Icons.Search />
            <input
              type="text"
              placeholder="Search candidates, jobs, or applications..."
              style={styles.searchInput}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
            <kbd style={styles.searchKbd}>⌘K</kbd>
          </div>

          <div style={styles.topBarActions}>
            <button style={styles.topBarBtn} onClick={() => setShowNotifications(!showNotifications)}>
              <Icons.Bell />
              <span style={styles.notificationDot} />
            </button>
            
            <button style={styles.createBtn}>
              <Icons.Plus />
              <span>Create</span>
            </button>

            <div style={styles.userMenu} onClick={() => setShowUserMenu(!showUserMenu)}>
              <div style={styles.userAvatar}>JD</div>
              <div style={styles.userInfo}>
                <span style={styles.userName}>John Doe</span>
                <span style={styles.userRole}>HR Manager</span>
              </div>
              <Icons.ChevronDown />
            </div>
          </div>
        </header>

        {/* Page Content */}
        <div style={styles.pageContent}>
          {currentView === 'dashboard' && <DashboardView />}
          {currentView === 'jobs' && <JobsView />}
          {currentView === 'candidates' && <CandidatesView onSelectCandidate={(c) => navigateTo('candidateDetail', c)} onAddCandidate={() => navigateTo('addCandidate')} />}
          {currentView === 'addCandidate' && <AddCandidatePage onBack={() => navigateTo('candidates')} onSave={() => navigateTo('candidates')} />}
          {currentView === 'candidateDetail' && <CandidateDetailPage candidate={selectedCandidate} onBack={() => navigateTo('candidates')} />}
          {currentView === 'applications' && <ApplicationsView />}
          {currentView === 'interviews' && <InterviewsView />}
          {currentView === 'offers' && <OffersView />}
          {currentView === 'analytics' && <AnalyticsView />}
          {currentView === 'settings' && <SettingsView />}
        </div>
      </main>
    </div>
  );
}

// ============================================================================
// DASHBOARD VIEW
// ============================================================================
function DashboardView() {
  const [stats, setStats] = useState(defaultStats);
  const [candidates, setCandidates] = useState(defaultCandidates);
  const [interviews, setInterviews] = useState(defaultInterviews);
  const [pipeline, setPipeline] = useState(defaultPipeline);
  const [activity, setActivity] = useState(defaultActivity);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        const [statsRes, candidatesRes, interviewsRes, pipelineRes, activityRes] = await Promise.all([
          fetch(`${API_BASE}/dashboard/stats`),
          fetch(`${API_BASE}/dashboard/candidates`),
          fetch(`${API_BASE}/dashboard/interviews`),
          fetch(`${API_BASE}/dashboard/pipeline`),
          fetch(`${API_BASE}/dashboard/activity`)
        ]);
        
        if (statsRes.ok) setStats(await statsRes.json());
        if (candidatesRes.ok) setCandidates(await candidatesRes.json());
        if (interviewsRes.ok) setInterviews(await interviewsRes.json());
        if (pipelineRes.ok) setPipeline(await pipelineRes.json());
        if (activityRes.ok) setActivity(await activityRes.json());
      } catch (error) {
        console.error('Error fetching dashboard data:', error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchDashboardData();
  }, []);

  const statsDisplay = [
    { label: 'Total Candidates', value: stats.total_candidates?.toString() || '0', change: 'From database', trend: 'up', icon: Icons.Users, color: '#00D4FF' },
    { label: 'Active Jobs', value: stats.active_jobs?.toString() || '0', change: 'Open positions', trend: 'up', icon: Icons.Briefcase, color: '#7B61FF' },
    { label: 'Interviews Today', value: stats.interviews_today?.toString() || '0', change: 'Scheduled', trend: 'neutral', icon: Icons.Calendar, color: '#FFB800' },
    { label: 'Offers Sent', value: stats.offers_sent?.toString() || '0', change: 'Pending', trend: 'up', icon: Icons.Award, color: '#00E5A0' },
  ];

  const maxPipelineCount = Math.max(...pipeline.map(s => s.count), 1);

  return (
    <div style={styles.dashboardContainer}>
      {/* Welcome Section */}
      <div style={styles.welcomeSection}>
        <div style={styles.welcomeContent}>
          <h1 style={styles.welcomeTitle}>Good morning! 👋</h1>
          <p style={styles.welcomeSubtitle}>
            You have <span style={styles.highlight}>{stats.total_candidates} candidates</span> and <span style={styles.highlight}>{stats.interviews_today} interviews</span> scheduled.
          </p>
        </div>
        <div style={styles.welcomeActions}>
          <button style={styles.primaryBtn}>
            <Icons.Plus />
            Post New Job
          </button>
          <button style={styles.secondaryBtn}>
            <Icons.Sparkles />
            AI Recommendations
          </button>
        </div>
      </div>

      {/* Stats Grid */}
      <div style={styles.statsGrid}>
        {statsDisplay.map((stat, index) => (
          <div key={index} style={styles.statCard} className="stat-card">
            <div style={styles.statHeader}>
              <div style={{...styles.statIcon, background: `${stat.color}22`, color: stat.color}}>
                <stat.icon />
              </div>
              <div style={{
                ...styles.statChange,
                color: stat.trend === 'up' ? '#00E5A0' : stat.trend === 'down' ? '#FF3D71' : '#8F9BB3'
              }}>
                {stat.trend === 'up' && <Icons.ArrowUp />}
                {stat.trend === 'down' && <Icons.ArrowDown />}
                {stat.change}
              </div>
            </div>
            <div style={styles.statValue}>{loading ? '...' : stat.value}</div>
            <div style={styles.statLabel}>{stat.label}</div>
            <div style={{...styles.statGlow, background: `radial-gradient(circle at 50% 100%, ${stat.color}15 0%, transparent 70%)`}} />
          </div>
        ))}
      </div>

      {/* Main Content Grid */}
      <div style={styles.dashboardGrid}>
        {/* Pipeline Overview */}
        <div style={styles.pipelineCard}>
          <div style={styles.cardHeader}>
            <h3 style={styles.cardTitle}>Hiring Pipeline</h3>
            <button style={styles.cardAction}>View All</button>
          </div>
          <div style={styles.pipelineStages}>
            {pipeline.map((stage, index) => (
              <div key={stage.id} style={styles.pipelineStage}>
                <div style={styles.pipelineStageHeader}>
                  <span style={styles.pipelineStageName}>{stage.name}</span>
                  <span style={{...styles.pipelineStageCount, color: stage.color}}>{stage.count}</span>
                </div>
                <div style={styles.pipelineBar}>
                  <div style={{
                    ...styles.pipelineBarFill,
                    width: `${(stage.count / maxPipelineCount) * 100}%`,
                    background: `linear-gradient(90deg, ${stage.color}, ${stage.color}88)`,
                  }} />
                </div>
                {index < pipeline.length - 1 && (
                  <div style={styles.pipelineConnector}>
                    <Icons.ChevronRight />
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Today's Interviews */}
        <div style={styles.interviewsCard}>
          <div style={styles.cardHeader}>
            <h3 style={styles.cardTitle}>Upcoming Interviews</h3>
            <button style={styles.cardAction}>Schedule</button>
          </div>
          <div style={styles.interviewsList}>
            {interviews.length === 0 && !loading ? (
              <div style={{padding: '20px', textAlign: 'center', color: '#8F9BB3'}}>No upcoming interviews</div>
            ) : interviews.slice(0, 3).map((interview) => (
              <div key={interview.id} style={styles.interviewItem}>
                <div style={styles.interviewTime}>
                  <span style={styles.interviewTimeText}>{interview.time}</span>
                  <span style={styles.interviewDate}>{interview.date}</span>
                </div>
                <div style={styles.interviewInfo}>
                  <div style={styles.interviewAvatar}>{interview.avatar}</div>
                  <div style={styles.interviewDetails}>
                    <span style={styles.interviewCandidate}>{interview.candidate}</span>
                    <span style={styles.interviewType}>{interview.type}</span>
                  </div>
                </div>
                <div style={{
                  ...styles.interviewStatus,
                  background: interview.status === 'Scheduled' ? '#00D4FF22' : interview.status === 'Confirmed' ? '#00E5A022' : '#FFB80022',
                  color: interview.status === 'Scheduled' ? '#00D4FF' : interview.status === 'Confirmed' ? '#00E5A0' : '#FFB800',
                }}>
                  {interview.status}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Top Candidates */}
        <div style={styles.topCandidatesCard}>
          <div style={styles.cardHeader}>
            <h3 style={styles.cardTitle}>Top Candidates</h3>
            <button style={styles.cardAction}>View All</button>
          </div>
          <div style={styles.candidatesList}>
            {candidates.length === 0 && !loading ? (
              <div style={{padding: '20px', textAlign: 'center', color: '#8F9BB3'}}>No candidates found</div>
            ) : candidates.slice(0, 4).map((candidate) => (
              <div key={candidate.id} style={styles.candidateItem}>
                <div style={styles.candidateAvatar}>{candidate.avatar || '👤'}</div>
                <div style={styles.candidateInfo}>
                  <span style={styles.candidateName}>{candidate.name}</span>
                  <span style={styles.candidateTitle}>{candidate.title}</span>
                </div>
                <div style={styles.candidateScore}>
                  <div style={styles.scoreCircle}>
                    <svg width="44" height="44" viewBox="0 0 44 44">
                      <circle
                        cx="22"
                        cy="22"
                        r="18"
                        fill="none"
                        stroke="#1A2942"
                        strokeWidth="4"
                      />
                      <circle
                        cx="22"
                        cy="22"
                        r="18"
                        fill="none"
                        stroke={candidate.score >= 90 ? '#00E5A0' : candidate.score >= 80 ? '#00D4FF' : '#FFB800'}
                        strokeWidth="4"
                        strokeDasharray={`${(candidate.score / 100) * 113} 113`}
                        strokeLinecap="round"
                        transform="rotate(-90 22 22)"
                      />
                    </svg>
                    <span style={styles.scoreValue}>{candidate.score}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Activity */}
        <div style={styles.activityCard}>
          <div style={styles.cardHeader}>
            <h3 style={styles.cardTitle}>Recent Activity</h3>
            <button style={styles.cardAction}>View All</button>
          </div>
          <div style={styles.activityList}>
            {activity.length === 0 && !loading ? (
              <div style={{padding: '20px', textAlign: 'center', color: '#8F9BB3'}}>No recent activity</div>
            ) : activity.map((item, index) => (
              <div key={index} style={styles.activityItem}>
                <div style={{...styles.activityIcon, background: `${item.color}22`}}>
                  {item.icon}
                </div>
                <div style={styles.activityContent}>
                  <span style={styles.activityAction}>{item.action}</span>
                  <span style={styles.activityDetail}>{item.detail}</span>
                </div>
                <span style={styles.activityTime}>{item.time}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

// ============================================================================
// JOBS VIEW
// ============================================================================
function JobsView() {
  const [viewMode, setViewMode] = useState('grid');
  const [filterStatus, setFilterStatus] = useState('all');
  const [selectedJob, setSelectedJob] = useState(null);
  const [showEditModal, setShowEditModal] = useState(false);

  const handleViewJob = (job) => {
    setSelectedJob(job);
  };

  const handleEditJob = (job) => {
    setSelectedJob(job);
    setShowEditModal(true);
  };

  const closeModal = () => {
    setSelectedJob(null);
    setShowEditModal(false);
  };

  return (
    <div style={styles.pageContainer}>
      <div style={styles.pageHeader}>
        <div>
          <h1 style={styles.pageTitle}>Jobs</h1>
          <p style={styles.pageSubtitle}>Manage your open positions and track applications</p>
        </div>
        <button style={styles.primaryBtn}>
          <Icons.Plus />
          Post New Job
        </button>
      </div>

      {/* Filters */}
      <div style={styles.filtersBar}>
        <div style={styles.filterTabs}>
          {['All Jobs', 'Active', 'Paused', 'Closed'].map((tab) => (
            <button
              key={tab}
              style={{
                ...styles.filterTab,
                ...(filterStatus === tab.toLowerCase().replace(' ', '') ? styles.filterTabActive : {})
              }}
              onClick={() => setFilterStatus(tab.toLowerCase().replace(' ', ''))}
            >
              {tab}
            </button>
          ))}
        </div>
        <div style={styles.filterActions}>
          <button style={styles.iconBtn}>
            <Icons.Filter />
          </button>
          <div style={styles.viewToggle}>
            <button 
              style={{...styles.viewBtn, ...(viewMode === 'grid' ? styles.viewBtnActive : {})}}
              onClick={() => setViewMode('grid')}
            >
              <Icons.Dashboard />
            </button>
            <button 
              style={{...styles.viewBtn, ...(viewMode === 'list' ? styles.viewBtnActive : {})}}
              onClick={() => setViewMode('list')}
            >
              <Icons.Menu />
            </button>
          </div>
        </div>
      </div>

      {/* Jobs Grid */}
      <div style={viewMode === 'grid' ? styles.jobsGrid : styles.jobsList}>
        {mockJobs.map((job) => (
          <div key={job.id} style={styles.jobCard} className="job-card">
            <div style={styles.jobCardHeader}>
              <div style={{
                ...styles.jobStatus,
                background: job.status === 'Active' ? '#00E5A022' : '#FFB80022',
                color: job.status === 'Active' ? '#00E5A0' : '#FFB800',
              }}>
                {job.status}
              </div>
              <button style={styles.jobMenuBtn}>
                <Icons.MoreVertical />
              </button>
            </div>
            <h3 style={styles.jobTitle}>{job.title}</h3>
            <div style={styles.jobMeta}>
              <span style={styles.jobMetaItem}>
                <Icons.Briefcase /> {job.department}
              </span>
              <span style={styles.jobMetaItem}>
                <Icons.MapPin /> {job.location}
              </span>
            </div>
            <div style={styles.jobSalary}>{job.salary}</div>
            <div style={styles.jobStats}>
              <div style={styles.jobStat}>
                <span style={styles.jobStatValue}>{job.applicants}</span>
                <span style={styles.jobStatLabel}>Applicants</span>
              </div>
              <div style={styles.jobStat}>
                <span style={{...styles.jobStatValue, color: '#00D4FF'}}>{job.newApplicants}</span>
                <span style={styles.jobStatLabel}>New</span>
              </div>
              <div style={styles.jobStat}>
                <span style={styles.jobStatValue}>{job.posted}</span>
                <span style={styles.jobStatLabel}>Posted</span>
              </div>
            </div>
            <div style={styles.jobActions}>
              <button style={styles.jobActionBtn} onClick={() => handleViewJob(job)}>
                <Icons.Eye /> View
              </button>
              <button style={styles.jobActionBtn} onClick={() => handleEditJob(job)}>
                <Icons.Edit /> Edit
              </button>
            </div>
          </div>
        ))}
        
        {/* Add New Job Card */}
        <div style={styles.addJobCard}>
          <div style={styles.addJobIcon}>
            <Icons.Plus />
          </div>
          <span style={styles.addJobText}>Post New Job</span>
        </div>
      </div>

      {/* Job Detail Modal */}
      {selectedJob && !showEditModal && (
        <div style={styles.modalOverlay} onClick={closeModal}>
          <div style={styles.modalContent} onClick={e => e.stopPropagation()}>
            <div style={styles.modalHeader}>
              <h2 style={styles.modalTitle}>{selectedJob.title}</h2>
              <button style={styles.modalCloseBtn} onClick={closeModal}>
                <Icons.X />
              </button>
            </div>
            <div style={styles.modalBody}>
              <div style={styles.jobDetailRow}>
                <span style={styles.jobDetailLabel}>Department:</span>
                <span style={styles.jobDetailValue}>{selectedJob.department}</span>
              </div>
              <div style={styles.jobDetailRow}>
                <span style={styles.jobDetailLabel}>Location:</span>
                <span style={styles.jobDetailValue}>{selectedJob.location}</span>
              </div>
              <div style={styles.jobDetailRow}>
                <span style={styles.jobDetailLabel}>Type:</span>
                <span style={styles.jobDetailValue}>{selectedJob.type}</span>
              </div>
              <div style={styles.jobDetailRow}>
                <span style={styles.jobDetailLabel}>Salary:</span>
                <span style={styles.jobDetailValue}>{selectedJob.salary}</span>
              </div>
              <div style={styles.jobDetailRow}>
                <span style={styles.jobDetailLabel}>Status:</span>
                <span style={{...styles.jobDetailValue, color: selectedJob.status === 'Active' ? '#00E5A0' : '#FFB800'}}>{selectedJob.status}</span>
              </div>
              <div style={styles.jobDetailRow}>
                <span style={styles.jobDetailLabel}>Total Applicants:</span>
                <span style={styles.jobDetailValue}>{selectedJob.applicants}</span>
              </div>
              <div style={styles.jobDetailRow}>
                <span style={styles.jobDetailLabel}>New Applicants:</span>
                <span style={{...styles.jobDetailValue, color: '#00D4FF'}}>{selectedJob.newApplicants}</span>
              </div>
              <div style={styles.jobDetailRow}>
                <span style={styles.jobDetailLabel}>Posted:</span>
                <span style={styles.jobDetailValue}>{selectedJob.posted}</span>
              </div>
            </div>
            <div style={styles.modalFooter}>
              <button style={styles.secondaryBtn} onClick={closeModal}>Close</button>
              <button style={styles.primaryBtn} onClick={() => handleEditJob(selectedJob)}>Edit Job</button>
            </div>
          </div>
        </div>
      )}

      {/* Edit Job Modal */}
      {selectedJob && showEditModal && (
        <div style={styles.modalOverlay} onClick={closeModal}>
          <div style={styles.modalContent} onClick={e => e.stopPropagation()}>
            <div style={styles.modalHeader}>
              <h2 style={styles.modalTitle}>Edit: {selectedJob.title}</h2>
              <button style={styles.modalCloseBtn} onClick={closeModal}>
                <Icons.X />
              </button>
            </div>
            <div style={styles.modalBody}>
              <div style={styles.formGroup}>
                <label style={styles.formLabel}>Job Title</label>
                <input type="text" style={styles.formInput} defaultValue={selectedJob.title} />
              </div>
              <div style={styles.formGroup}>
                <label style={styles.formLabel}>Department</label>
                <input type="text" style={styles.formInput} defaultValue={selectedJob.department} />
              </div>
              <div style={styles.formGroup}>
                <label style={styles.formLabel}>Location</label>
                <input type="text" style={styles.formInput} defaultValue={selectedJob.location} />
              </div>
              <div style={styles.formGroup}>
                <label style={styles.formLabel}>Salary Range</label>
                <input type="text" style={styles.formInput} defaultValue={selectedJob.salary} />
              </div>
              <div style={styles.formGroup}>
                <label style={styles.formLabel}>Status</label>
                <select style={styles.formInput} defaultValue={selectedJob.status}>
                  <option value="Active">Active</option>
                  <option value="Paused">Paused</option>
                  <option value="Closed">Closed</option>
                </select>
              </div>
            </div>
            <div style={styles.modalFooter}>
              <button style={styles.secondaryBtn} onClick={closeModal}>Cancel</button>
              <button style={styles.primaryBtn} onClick={closeModal}>Save Changes</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ============================================================================
// CANDIDATES VIEW
// ============================================================================
function CandidatesView({ onSelectCandidate, onAddCandidate }) {
  const [viewMode, setViewMode] = useState('kanban');
  const [selectedStage, setSelectedStage] = useState('all');
  const [candidates, setCandidates] = useState([]);
  const [isLoadingCandidates, setIsLoadingCandidates] = useState(true);

  useEffect(() => {
    const fetchCandidates = async () => {
      try {
        const response = await fetch('/api/dashboard/candidates');
        const data = await response.json();
        setCandidates(data);
      } catch (err) {
        console.error('Error fetching candidates:', err);
      } finally {
        setIsLoadingCandidates(false);
      }
    };
    fetchCandidates();
  }, []);

  const kanbanStages = [
    { id: 'new', name: 'New', candidates: candidates.filter(c => c.status === 'new' || c.status === 'active' || !c.status) },
    { id: 'screening', name: 'Screening', candidates: candidates.filter(c => c.status === 'screening' || c.status === 'phone_screen') },
    { id: 'interview', name: 'Interview', candidates: candidates.filter(c => c.status === 'interview' || c.status === 'technical_interview') },
    { id: 'offer', name: 'Offer', candidates: candidates.filter(c => c.status === 'offer' || c.status === 'offer_sent') },
  ];

  return (
    <div style={styles.pageContainer}>
      <div style={styles.pageHeader}>
        <div>
          <h1 style={styles.pageTitle}>Candidates</h1>
          <p style={styles.pageSubtitle}>Track and manage your candidate pipeline</p>
        </div>
        <div style={styles.headerActions}>
          <button style={styles.secondaryBtn}>
            <Icons.Filter />
            Filters
          </button>
          <button style={styles.primaryBtn} onClick={onAddCandidate}>
            <Icons.Plus />
            Add Candidate
          </button>
        </div>
      </div>

      {/* View Toggle */}
      <div style={styles.viewModeBar}>
        <div style={styles.viewModeToggle}>
          {['kanban', 'list', 'table'].map((mode) => (
            <button
              key={mode}
              style={{
                ...styles.viewModeBtn,
                ...(viewMode === mode ? styles.viewModeBtnActive : {})
              }}
              onClick={() => setViewMode(mode)}
            >
              {mode.charAt(0).toUpperCase() + mode.slice(1)}
            </button>
          ))}
        </div>
        <div style={styles.candidateCount}>
          Showing <strong>{candidates.length}</strong> candidates
        </div>
      </div>

      {/* Kanban Board */}
      {viewMode === 'kanban' && (
        <div style={styles.kanbanBoard}>
          {kanbanStages.map((stage) => (
            <div key={stage.id} style={styles.kanbanColumn}>
              <div style={styles.kanbanColumnHeader}>
                <span style={styles.kanbanColumnTitle}>{stage.name}</span>
                <span style={styles.kanbanColumnCount}>{stage.candidates.length}</span>
              </div>
              <div style={styles.kanbanColumnContent}>
                {stage.candidates.map((candidate) => (
                  <div 
                    key={candidate.id} 
                    style={styles.kanbanCard}
                    onClick={() => onSelectCandidate(candidate)}
                    className="kanban-card"
                  >
                    <div style={styles.kanbanCardHeader}>
                      <div style={styles.kanbanCardAvatar}>{candidate.avatar}</div>
                      <div style={styles.kanbanCardScore}>
                        <Icons.Star />
                        {candidate.score}
                      </div>
                    </div>
                    <h4 style={styles.kanbanCardName}>{candidate.name}</h4>
                    <p style={styles.kanbanCardTitle}>{candidate.title}</p>
                    <p style={styles.kanbanCardCompany}>{candidate.company}</p>
                    <div style={styles.kanbanCardSkills}>
                      {(candidate.skills || []).slice(0, 3).map((skill, idx) => (
                        <span key={idx} style={styles.skillTag}>{skill}</span>
                      ))}
                    </div>
                    <div style={styles.kanbanCardFooter}>
                      <span style={styles.kanbanCardDate}>
                        <Icons.Clock /> {candidate.appliedDate}
                      </span>
                      <button style={styles.kanbanCardAction}>
                        <Icons.MoreVertical />
                      </button>
                    </div>
                  </div>
                ))}
                <button style={styles.kanbanAddBtn} onClick={onAddCandidate}>
                  <Icons.Plus />
                  Add Candidate
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* List View */}
      {viewMode === 'list' && (
        <div style={styles.candidatesListView}>
          {candidates.map((candidate) => (
            <div 
              key={candidate.id} 
              style={styles.candidateListItem}
              onClick={() => onSelectCandidate(candidate)}
              className="candidate-list-item"
            >
              <div style={styles.candidateListAvatar}>{candidate.avatar}</div>
              <div style={styles.candidateListInfo}>
                <h4 style={styles.candidateListName}>{candidate.name}</h4>
                <p style={styles.candidateListTitle}>{candidate.title} at {candidate.company}</p>
              </div>
              <div style={styles.candidateListMeta}>
                <span style={styles.candidateListLocation}>
                  <Icons.MapPin /> {candidate.location}
                </span>
              </div>
              <div style={styles.candidateListSkills}>
                {(candidate.skills || []).slice(0, 3).map((skill, idx) => (
                  <span key={idx} style={styles.skillTagSmall}>{skill}</span>
                ))}
              </div>
              <div style={styles.candidateListScore}>
                <div style={{
                  ...styles.scoreBar,
                  '--score-width': `${candidate.score}%`,
                  '--score-color': candidate.score >= 90 ? '#00E5A0' : candidate.score >= 80 ? '#00D4FF' : '#FFB800',
                }}>
                  <span>{candidate.score}</span>
                </div>
              </div>
              <div style={{
                ...styles.candidateListStatus,
                background: (candidate.status || '').includes('Offer') ? '#00E5A022' : (candidate.status || '').includes('Interview') ? '#00D4FF22' : '#7B61FF22',
                color: (candidate.status || '').includes('Offer') ? '#00E5A0' : (candidate.status || '').includes('Interview') ? '#00D4FF' : '#7B61FF',
              }}>
                {candidate.status}
              </div>
              <button style={styles.candidateListAction}>
                <Icons.ChevronRight />
              </button>
            </div>
          ))}
        </div>
      )}

      </div>
  );
}

// ============================================================================
// ADD CANDIDATE PAGE
// ============================================================================
function AddCandidatePage({ onBack, onSave }) {
  const [uploadedFile, setUploadedFile] = useState(null);
  const [isParsing, setIsParsing] = useState(false);
  const [parseError, setParseError] = useState(null);
  const [isSaving, setIsSaving] = useState(false);
  const [saveError, setSaveError] = useState(null);
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    currentTitle: '',
    currentCompany: '',
    location: '',
  });
  const fileInputRef = React.useRef(null);

  const handleFileClick = () => {
    fileInputRef.current?.click();
  };

  const parseResume = async (file) => {
    setIsParsing(true);
    setParseError(null);
    try {
      const formDataUpload = new FormData();
      formDataUpload.append('resume', file);
      
      const response = await fetch('/api/resume/parse', {
        method: 'POST',
        body: formDataUpload,
      });
      
      const result = await response.json();
      
      if (!response.ok) {
        throw new Error(result.error || 'Failed to parse resume');
      }
      
      if (result.success && result.data) {
        setFormData({
          firstName: result.data.firstName || '',
          lastName: result.data.lastName || '',
          email: result.data.email || '',
          phone: result.data.phone || '',
          currentTitle: result.data.currentTitle || '',
          currentCompany: result.data.currentCompany || '',
          location: result.data.location || '',
        });
      }
    } catch (err) {
      console.error('Resume parse error:', err);
      setParseError(err.message);
    } finally {
      setIsParsing(false);
    }
  };

  const handleFileChange = (e) => {
    const file = e.target.files?.[0];
    if (file) {
      setUploadedFile(file);
      parseResume(file);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    const file = e.dataTransfer.files?.[0];
    if (file) {
      setUploadedFile(file);
      parseResume(file);
    }
  };

  const handleDragOver = (e) => {
    e.preventDefault();
  };

  const handleInputChange = (field) => (e) => {
    setFormData(prev => ({ ...prev, [field]: e.target.value }));
  };

  const handleSaveCandidate = async () => {
    if (!formData.firstName || !formData.lastName || !formData.email) {
      setSaveError('Please fill in first name, last name, and email');
      return;
    }
    
    setIsSaving(true);
    setSaveError(null);
    
    try {
      const response = await fetch('/api/candidates', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });
      
      const result = await response.json();
      
      if (!response.ok) {
        throw new Error(result.error || 'Failed to save candidate');
      }
      
      onSave();
    } catch (err) {
      console.error('Save candidate error:', err);
      setSaveError(err.message);
    } finally {
      setIsSaving(false);
    }
  };

  const breadcrumbItems = [
    { label: 'Candidates', onClick: onBack },
    { label: 'Add New Candidate' }
  ];

  return (
    <div style={styles.pageContainer}>
      <Breadcrumbs items={breadcrumbItems} />
      
      <div style={styles.pageHeader}>
        <div>
          <h1 style={styles.pageTitle}>Add New Candidate</h1>
          <p style={styles.pageSubtitle}>Upload a resume to auto-populate fields or enter manually</p>
        </div>
      </div>

      <div style={styles.formCard}>
        <div style={styles.formGroup}>
          <label style={styles.formLabel}>Resume</label>
          <input
            type="file"
            ref={fileInputRef}
            onChange={handleFileChange}
            accept=".pdf,.doc,.docx"
            style={{ display: 'none' }}
          />
          <div
            style={{
              ...styles.fileUpload,
              borderColor: isParsing ? '#00D4FF' : uploadedFile ? '#00D68F' : 'rgba(255, 255, 255, 0.1)',
              opacity: isParsing ? 0.7 : 1,
              pointerEvents: isParsing ? 'none' : 'auto',
            }}
            onClick={handleFileClick}
            onDrop={handleDrop}
            onDragOver={handleDragOver}
          >
            {isParsing ? (
              <>
                <div style={{ animation: 'spin 1s linear infinite', width: 24, height: 24 }}>
                  <Icons.Clock />
                </div>
                <span style={{ color: '#00D4FF' }}>Parsing resume...</span>
                <span style={styles.fileHint}>Extracting candidate information</span>
              </>
            ) : uploadedFile ? (
              <>
                <Icons.Check />
                <span style={{ color: '#00D68F' }}>{uploadedFile.name}</span>
                <span style={styles.fileHint}>
                  {(uploadedFile.size / 1024 / 1024).toFixed(2)} MB - Parsed successfully
                </span>
              </>
            ) : (
              <>
                <Icons.Upload />
                <span>Click to upload or drag and drop</span>
                <span style={styles.fileHint}>PDF, DOC up to 10MB - Fields will auto-populate</span>
              </>
            )}
          </div>
          {parseError && (
            <div style={{ color: '#FF6B6B', fontSize: '12px', marginTop: '8px' }}>
              {parseError}
            </div>
          )}
        </div>

        <div style={styles.formRow}>
          <div style={styles.formGroup}>
            <label style={styles.formLabel}>First Name *</label>
            <input
              type="text"
              style={{
                ...styles.formInput,
                borderColor: formData.firstName ? '#00D68F' : 'rgba(255, 255, 255, 0.1)',
              }}
              placeholder="Enter first name"
              value={formData.firstName}
              onChange={handleInputChange('firstName')}
            />
          </div>
          <div style={styles.formGroup}>
            <label style={styles.formLabel}>Last Name *</label>
            <input
              type="text"
              style={{
                ...styles.formInput,
                borderColor: formData.lastName ? '#00D68F' : 'rgba(255, 255, 255, 0.1)',
              }}
              placeholder="Enter last name"
              value={formData.lastName}
              onChange={handleInputChange('lastName')}
            />
          </div>
        </div>

        <div style={styles.formGroup}>
          <label style={styles.formLabel}>Email *</label>
          <input
            type="email"
            style={{
              ...styles.formInput,
              borderColor: formData.email ? '#00D68F' : 'rgba(255, 255, 255, 0.1)',
            }}
            placeholder="candidate@email.com"
            value={formData.email}
            onChange={handleInputChange('email')}
          />
        </div>

        <div style={styles.formGroup}>
          <label style={styles.formLabel}>Phone</label>
          <input
            type="tel"
            style={{
              ...styles.formInput,
              borderColor: formData.phone ? '#00D68F' : 'rgba(255, 255, 255, 0.1)',
            }}
            placeholder="+91 98765 43210"
            value={formData.phone}
            onChange={handleInputChange('phone')}
          />
        </div>

        <div style={styles.formGroup}>
          <label style={styles.formLabel}>Current Title</label>
          <input
            type="text"
            style={{
              ...styles.formInput,
              borderColor: formData.currentTitle ? '#00D68F' : 'rgba(255, 255, 255, 0.1)',
            }}
            placeholder="e.g. Senior Software Engineer"
            value={formData.currentTitle}
            onChange={handleInputChange('currentTitle')}
          />
        </div>

        <div style={styles.formGroup}>
          <label style={styles.formLabel}>Current Company</label>
          <input
            type="text"
            style={{
              ...styles.formInput,
              borderColor: formData.currentCompany ? '#00D68F' : 'rgba(255, 255, 255, 0.1)',
            }}
            placeholder="e.g. Infosys"
            value={formData.currentCompany}
            onChange={handleInputChange('currentCompany')}
          />
        </div>

        <div style={styles.formGroup}>
          <label style={styles.formLabel}>Location</label>
          <input
            type="text"
            style={{
              ...styles.formInput,
              borderColor: formData.location ? '#00D68F' : 'rgba(255, 255, 255, 0.1)',
            }}
            placeholder="e.g. Bangalore, Mumbai"
            value={formData.location}
            onChange={handleInputChange('location')}
          />
        </div>

        {saveError && (
          <div style={{color: '#ef4444', fontSize: '0.875rem', marginTop: '1rem'}}>
            {saveError}
          </div>
        )}

        <div style={styles.formActions}>
          <button style={styles.secondaryBtn} onClick={onBack}>Cancel</button>
          <button 
            style={{...styles.primaryBtn, opacity: isSaving ? 0.7 : 1}} 
            onClick={handleSaveCandidate}
            disabled={isSaving}
          >
            {isSaving ? 'Saving...' : 'Add Candidate'}
          </button>
        </div>
      </div>
    </div>
  );
}

// ============================================================================
// CANDIDATE DETAIL PAGE
// ============================================================================
function CandidateDetailPage({ candidate, onBack }) {
  const [activeTab, setActiveTab] = useState('overview');

  if (!candidate) {
    return (
      <div style={styles.pageContainer}>
        <Breadcrumbs items={[{ label: 'Candidates', onClick: onBack }, { label: 'Not Found' }]} />
        <div style={{ textAlign: 'center', padding: '4rem' }}>
          <h2 style={{ color: '#fff', marginBottom: '1rem' }}>Candidate not found</h2>
          <button style={styles.primaryBtn} onClick={onBack}>Back to Candidates</button>
        </div>
      </div>
    );
  }

  const breadcrumbItems = [
    { label: 'Candidates', onClick: onBack },
    { label: candidate.name }
  ];

  return (
    <div style={styles.pageContainer}>
      <Breadcrumbs items={breadcrumbItems} />

      <div style={styles.candidateDetailHeader}>
        <div style={styles.candidateDetailInfo}>
          <div style={styles.profileAvatarLarge}>{candidate.avatar || '👤'}</div>
          <div>
            <h1 style={styles.pageTitle}>{candidate.name}</h1>
            <p style={styles.pageSubtitle}>{candidate.title} at {candidate.company}</p>
            <div style={styles.candidateDetailMeta}>
              <span><Icons.MapPin /> {candidate.location}</span>
              <span><Icons.Briefcase /> {candidate.experience || 'N/A'}</span>
              <span><Icons.Clock /> Applied {candidate.appliedDate}</span>
            </div>
          </div>
        </div>
        <div style={styles.candidateDetailActions}>
          <button style={styles.secondaryBtn}>
            <Icons.Mail />
            Email
          </button>
          <button style={styles.primaryBtn}>
            <Icons.Calendar />
            Schedule Interview
          </button>
        </div>
      </div>

      <div style={styles.candidateDetailScore}>
        <div style={styles.scoreCircle}>
          <svg width="100" height="100" viewBox="0 0 100 100">
            <circle cx="50" cy="50" r="45" fill="none" stroke="#1A2942" strokeWidth="8" />
            <circle
              cx="50" cy="50" r="45"
              fill="none"
              stroke={candidate.score >= 90 ? '#00E5A0' : candidate.score >= 80 ? '#00D4FF' : '#FFB800'}
              strokeWidth="8"
              strokeDasharray={`${(candidate.score / 100) * 283} 283`}
              strokeLinecap="round"
              transform="rotate(-90 50 50)"
            />
          </svg>
          <span style={styles.scoreValue}>{candidate.score}</span>
        </div>
        <span style={styles.scoreLabel}>Match Score</span>
      </div>

      <div style={styles.profileTabs}>
        {['Overview', 'Resume', 'Timeline', 'Notes'].map((tab) => (
          <button
            key={tab}
            style={{
              ...styles.profileTab,
              ...(activeTab === tab.toLowerCase() ? styles.profileTabActive : {})
            }}
            onClick={() => setActiveTab(tab.toLowerCase())}
          >
            {tab}
          </button>
        ))}
      </div>

      <div style={styles.profileContent}>
        {activeTab === 'overview' && (
          <>
            <div style={styles.profileSection}>
              <h4 style={styles.sectionTitle}>Skills</h4>
              <div style={styles.skillsGrid}>
                {(candidate.skills || []).map((skill, idx) => (
                  <span key={idx} style={styles.skillTagLarge}>{skill}</span>
                ))}
                {(!candidate.skills || candidate.skills.length === 0) && (
                  <span style={{ color: '#8F9BB3' }}>No skills listed</span>
                )}
              </div>
            </div>

            <div style={styles.profileSection}>
              <h4 style={styles.sectionTitle}>AI Analysis</h4>
              <div style={styles.aiAnalysis}>
                <div style={styles.aiAnalysisHeader}>
                  <Icons.Sparkles />
                  <span>TalentForge AI</span>
                </div>
                <p style={styles.aiAnalysisText}>
                  Strong candidate with excellent technical skills and relevant experience. 
                  Exceeds requirements in most areas. Recommended for technical interview.
                </p>
              </div>
            </div>

            <div style={styles.profileSection}>
              <h4 style={styles.sectionTitle}>Contact</h4>
              <div style={styles.contactList}>
                <div style={styles.contactItem}>
                  <Icons.Mail />
                  <span>{candidate.name?.toLowerCase().replace(' ', '.')}@email.com</span>
                </div>
                <div style={styles.contactItem}>
                  <Icons.Phone />
                  <span>+91 98765 43210</span>
                </div>
              </div>
            </div>
          </>
        )}

        {activeTab === 'resume' && (
          <div style={styles.profileSection}>
            <p style={{ color: '#8F9BB3' }}>Resume content will be displayed here.</p>
          </div>
        )}

        {activeTab === 'timeline' && (
          <div style={styles.profileSection}>
            <p style={{ color: '#8F9BB3' }}>Application timeline will be displayed here.</p>
          </div>
        )}

        {activeTab === 'notes' && (
          <div style={styles.profileSection}>
            <p style={{ color: '#8F9BB3' }}>Notes and comments will be displayed here.</p>
          </div>
        )}
      </div>

      <div style={styles.candidateDetailFooter}>
        <button style={styles.rejectBtn}>Reject</button>
        <button style={styles.advanceBtn}>Advance to Next Stage</button>
      </div>
    </div>
  );
}

// ============================================================================
// CANDIDATE DETAIL PANEL (kept for reference, unused)
// ============================================================================
function CandidateDetailPanel({ candidate, onClose }) {
  const [activeTab, setActiveTab] = useState('overview');

  if (!candidate) return null;

  return (
    <div style={styles.slideoverBackdrop} onClick={onClose}>
      <div style={styles.slideoverPanel} onClick={(e) => e.stopPropagation()}>
        <div style={styles.slideoverHeader}>
          <button style={styles.closeBtn} onClick={onClose}>
            <Icons.X />
          </button>
          <div style={styles.slideoverActions}>
            <button style={styles.secondaryBtnSm}>
              <Icons.Mail />
              Email
            </button>
            <button style={styles.primaryBtnSm}>
              <Icons.Calendar />
              Schedule Interview
            </button>
          </div>
        </div>

        <div style={styles.candidateProfile}>
          <div style={styles.profileAvatar}>{candidate.avatar}</div>
          <div style={styles.profileInfo}>
            <h2 style={styles.profileName}>{candidate.name}</h2>
            <p style={styles.profileTitle}>{candidate.title}</p>
            <p style={styles.profileCompany}>{candidate.company}</p>
          </div>
          <div style={styles.profileScore}>
            <div style={styles.scoreLarge}>
              <svg width="80" height="80" viewBox="0 0 80 80">
                <circle cx="40" cy="40" r="35" fill="none" stroke="#1A2942" strokeWidth="6" />
                <circle
                  cx="40" cy="40" r="35"
                  fill="none"
                  stroke={candidate.score >= 90 ? '#00E5A0' : candidate.score >= 80 ? '#00D4FF' : '#FFB800'}
                  strokeWidth="6"
                  strokeDasharray={`${(candidate.score / 100) * 220} 220`}
                  strokeLinecap="round"
                  transform="rotate(-90 40 40)"
                />
              </svg>
              <span style={styles.scoreLargeValue}>{candidate.score}</span>
            </div>
            <span style={styles.scoreLabel}>Match Score</span>
          </div>
        </div>

        <div style={styles.profileMeta}>
          <div style={styles.profileMetaItem}>
            <Icons.MapPin />
            <span>{candidate.location}</span>
          </div>
          <div style={styles.profileMetaItem}>
            <Icons.Briefcase />
            <span>{candidate.experience}</span>
          </div>
          <div style={styles.profileMetaItem}>
            <Icons.Clock />
            <span>Applied {candidate.appliedDate}</span>
          </div>
        </div>

        <div style={styles.profileTabs}>
          {['Overview', 'Resume', 'Timeline', 'Notes'].map((tab) => (
            <button
              key={tab}
              style={{
                ...styles.profileTab,
                ...(activeTab === tab.toLowerCase() ? styles.profileTabActive : {})
              }}
              onClick={() => setActiveTab(tab.toLowerCase())}
            >
              {tab}
            </button>
          ))}
        </div>

        <div style={styles.profileContent}>
          {activeTab === 'overview' && (
            <>
              <div style={styles.profileSection}>
                <h4 style={styles.sectionTitle}>Skills</h4>
                <div style={styles.skillsGrid}>
                  {(candidate.skills || []).map((skill, idx) => (
                    <span key={idx} style={styles.skillTagLarge}>{skill}</span>
                  ))}
                </div>
              </div>

              <div style={styles.profileSection}>
                <h4 style={styles.sectionTitle}>AI Analysis</h4>
                <div style={styles.aiAnalysis}>
                  <div style={styles.aiAnalysisHeader}>
                    <Icons.Sparkles />
                    <span>TalentForge AI</span>
                  </div>
                  <p style={styles.aiAnalysisText}>
                    Strong candidate with excellent technical skills and relevant experience. 
                    Exceeds requirements in most areas. Recommended for technical interview.
                  </p>
                  <div style={styles.aiStrengths}>
                    <span style={styles.aiStrengthItem}>✓ 8+ years experience</span>
                    <span style={styles.aiStrengthItem}>✓ Strong tech stack match</span>
                    <span style={styles.aiStrengthItem}>✓ Leadership potential</span>
                  </div>
                </div>
              </div>

              <div style={styles.profileSection}>
                <h4 style={styles.sectionTitle}>Contact</h4>
                <div style={styles.contactList}>
                  <div style={styles.contactItem}>
                    <Icons.Mail />
                    <span>{candidate.name.toLowerCase().replace(' ', '.')}@email.com</span>
                  </div>
                  <div style={styles.contactItem}>
                    <Icons.Phone />
                    <span>+1 (555) 123-4567</span>
                  </div>
                  <div style={styles.contactItem}>
                    <Icons.LinkedIn />
                    <span>linkedin.com/in/{candidate.name.toLowerCase().replace(' ', '')}</span>
                  </div>
                </div>
              </div>
            </>
          )}
        </div>

        <div style={styles.slideoverFooter}>
          <button style={styles.rejectBtn}>
            Reject
          </button>
          <button style={styles.advanceBtn}>
            Advance to Next Stage
          </button>
        </div>
      </div>
    </div>
  );
}

// Placeholder views for other sections
function ApplicationsView() {
  return (
    <div style={styles.pageContainer}>
      <h1 style={styles.pageTitle}>Applications</h1>
      <p style={styles.pageSubtitle}>Track all job applications in one place</p>
    </div>
  );
}

function InterviewsView() {
  return (
    <div style={styles.pageContainer}>
      <div style={styles.pageHeader}>
        <div>
          <h1 style={styles.pageTitle}>Interviews</h1>
          <p style={styles.pageSubtitle}>Manage your interview schedule</p>
        </div>
        <button style={styles.primaryBtn}>
          <Icons.Plus />
          Schedule Interview
        </button>
      </div>

      <div style={styles.interviewsGrid}>
        {mockInterviews.map((interview) => (
          <div key={interview.id} style={styles.interviewCard}>
            <div style={styles.interviewCardHeader}>
              <div style={styles.interviewCardTime}>
                <span style={styles.interviewCardTimeText}>{interview.time}</span>
                <span style={styles.interviewCardDate}>{interview.date}</span>
              </div>
              <div style={{
                ...styles.interviewCardStatus,
                background: interview.status === 'Scheduled' ? '#00D4FF22' : interview.status === 'Confirmed' ? '#00E5A022' : '#FFB80022',
                color: interview.status === 'Scheduled' ? '#00D4FF' : interview.status === 'Confirmed' ? '#00E5A0' : '#FFB800',
              }}>
                {interview.status}
              </div>
            </div>
            <div style={styles.interviewCardBody}>
              <div style={styles.interviewCardAvatar}>{interview.avatar}</div>
              <div style={styles.interviewCardInfo}>
                <h4 style={styles.interviewCardName}>{interview.candidate}</h4>
                <p style={styles.interviewCardPosition}>{interview.position}</p>
                <p style={styles.interviewCardType}>{interview.type}</p>
              </div>
            </div>
            <div style={styles.interviewCardFooter}>
              <span style={styles.interviewCardInterviewer}>
                <Icons.Users /> {interview.interviewer}
              </span>
              <div style={styles.interviewCardActions}>
                <button style={styles.iconBtnSm}>
                  <Icons.Video />
                </button>
                <button style={styles.iconBtnSm}>
                  <Icons.MoreVertical />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function OffersView() {
  return (
    <div style={styles.pageContainer}>
      <h1 style={styles.pageTitle}>Offers</h1>
      <p style={styles.pageSubtitle}>Manage job offers and approvals</p>
    </div>
  );
}

function AnalyticsView() {
  return (
    <div style={styles.pageContainer}>
      <h1 style={styles.pageTitle}>Analytics</h1>
      <p style={styles.pageSubtitle}>Insights and reports on your hiring performance</p>
    </div>
  );
}

function SettingsView() {
  return (
    <div style={styles.pageContainer}>
      <h1 style={styles.pageTitle}>Settings</h1>
      <p style={styles.pageSubtitle}>Configure your TalentForge workspace</p>
    </div>
  );
}

// ============================================================================
// GLOBAL STYLES
// ============================================================================
const globalStyles = `
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap');
  
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  
  body {
    font-family: 'Inter', sans-serif;
    background: #0A1628;
    color: #E4E9F2;
    overflow-x: hidden;
  }
  
  ::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }
  
  ::-webkit-scrollbar-track {
    background: #0A1628;
  }
  
  ::-webkit-scrollbar-thumb {
    background: #243B55;
    border-radius: 4px;
  }
  
  ::-webkit-scrollbar-thumb:hover {
    background: #2D4A6A;
  }
  
  .nav-item {
    transition: all 0.2s ease;
  }
  
  .nav-item:hover {
    background: rgba(0, 212, 255, 0.1) !important;
    transform: translateX(4px);
  }
  
  .stat-card {
    transition: all 0.3s ease;
  }
  
  .stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 40px rgba(0, 0, 0, 0.3);
  }
  
  .job-card {
    transition: all 0.3s ease;
  }
  
  .job-card:hover {
    transform: translateY(-4px);
    border-color: rgba(0, 212, 255, 0.3);
  }
  
  .kanban-card {
    transition: all 0.2s ease;
    cursor: pointer;
  }
  
  .kanban-card:hover {
    transform: translateY(-2px);
    border-color: rgba(0, 212, 255, 0.4);
    box-shadow: 0 4px 20px rgba(0, 212, 255, 0.15);
  }
  
  .candidate-list-item {
    transition: all 0.2s ease;
    cursor: pointer;
  }
  
  .candidate-list-item:hover {
    background: rgba(0, 212, 255, 0.05);
    border-color: rgba(0, 212, 255, 0.2);
  }

  @keyframes slideIn {
    from {
      opacity: 0;
      transform: translateX(100%);
    }
    to {
      opacity: 1;
      transform: translateX(0);
    }
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: translateY(10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes pulse {
    0%, 100% {
      opacity: 1;
    }
    50% {
      opacity: 0.5;
    }
  }
`;

// ============================================================================
// STYLES OBJECT
// ============================================================================
const styles = {
  appContainer: {
    display: 'flex',
    minHeight: '100vh',
    background: '#0A1628',
  },

  // Breadcrumbs
  breadcrumbs: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    marginBottom: '24px',
    fontSize: '14px',
  },

  breadcrumbLink: {
    background: 'none',
    border: 'none',
    color: '#00D4FF',
    cursor: 'pointer',
    fontSize: '14px',
    padding: 0,
  },

  breadcrumbSeparator: {
    color: '#8F9BB3',
  },

  breadcrumbCurrent: {
    color: '#fff',
  },

  // Form Card
  formCard: {
    background: '#0D1B2A',
    borderRadius: '16px',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    padding: '32px',
    maxWidth: '600px',
  },

  formActions: {
    display: 'flex',
    justifyContent: 'flex-end',
    gap: '12px',
    marginTop: '24px',
    paddingTop: '24px',
    borderTop: '1px solid rgba(255, 255, 255, 0.1)',
  },

  // Candidate Detail Page
  candidateDetailHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: '32px',
    flexWrap: 'wrap',
    gap: '24px',
  },

  candidateDetailInfo: {
    display: 'flex',
    alignItems: 'center',
    gap: '20px',
  },

  profileAvatarLarge: {
    width: '80px',
    height: '80px',
    borderRadius: '50%',
    background: 'linear-gradient(135deg, #00D4FF22 0%, #7B61FF22 100%)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '32px',
  },

  candidateDetailMeta: {
    display: 'flex',
    gap: '20px',
    marginTop: '8px',
    color: '#8F9BB3',
    fontSize: '14px',
  },

  candidateDetailActions: {
    display: 'flex',
    gap: '12px',
  },

  candidateDetailScore: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    marginBottom: '32px',
  },

  candidateDetailFooter: {
    display: 'flex',
    justifyContent: 'flex-end',
    gap: '12px',
    marginTop: '32px',
    paddingTop: '24px',
    borderTop: '1px solid rgba(255, 255, 255, 0.1)',
  },

  // Sidebar
  sidebar: {
    position: 'fixed',
    left: 0,
    top: 0,
    height: '100vh',
    background: 'linear-gradient(180deg, #0D1B2A 0%, #0A1628 100%)',
    borderRight: '1px solid rgba(255, 255, 255, 0.06)',
    display: 'flex',
    flexDirection: 'column',
    padding: '20px 12px',
    transition: 'all 0.3s ease',
    zIndex: 100,
    overflow: 'hidden',
  },

  logoContainer: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    padding: '8px 12px',
    marginBottom: '32px',
  },

  logoIcon: {
    width: '40px',
    height: '40px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    borderRadius: '12px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    color: '#fff',
    flexShrink: 0,
  },

  logoText: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '20px',
    fontWeight: 700,
    color: '#fff',
    whiteSpace: 'nowrap',
  },

  nav: {
    display: 'flex',
    flexDirection: 'column',
    gap: '4px',
    flex: 1,
  },

  navItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    padding: '12px 16px',
    background: 'transparent',
    border: 'none',
    borderRadius: '10px',
    color: '#8F9BB3',
    cursor: 'pointer',
    fontSize: '14px',
    fontWeight: 500,
    position: 'relative',
    textAlign: 'left',
    width: '100%',
  },

  navItemActive: {
    background: 'rgba(0, 212, 255, 0.1)',
    color: '#00D4FF',
  },

  navIcon: {
    width: '20px',
    height: '20px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    flexShrink: 0,
  },

  navLabel: {
    whiteSpace: 'nowrap',
  },

  navBadge: {
    marginLeft: 'auto',
    background: '#FF3D71',
    color: '#fff',
    fontSize: '11px',
    fontWeight: 600,
    padding: '2px 8px',
    borderRadius: '10px',
  },

  navIndicator: {
    position: 'absolute',
    left: 0,
    top: '50%',
    transform: 'translateY(-50%)',
    width: '3px',
    height: '24px',
    background: 'linear-gradient(180deg, #00D4FF 0%, #7B61FF 100%)',
    borderRadius: '0 3px 3px 0',
  },

  aiCard: {
    background: 'linear-gradient(135deg, rgba(0, 212, 255, 0.1) 0%, rgba(123, 97, 255, 0.1) 100%)',
    border: '1px solid rgba(0, 212, 255, 0.2)',
    borderRadius: '16px',
    padding: '20px',
    margin: '16px 4px',
  },

  aiCardHeader: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    color: '#00D4FF',
    fontSize: '14px',
    fontWeight: 600,
    marginBottom: '8px',
  },

  aiCardText: {
    fontSize: '13px',
    color: '#8F9BB3',
    lineHeight: 1.5,
    marginBottom: '16px',
  },

  aiCardButton: {
    width: '100%',
    padding: '10px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    border: 'none',
    borderRadius: '8px',
    color: '#fff',
    fontSize: '13px',
    fontWeight: 600,
    cursor: 'pointer',
  },

  collapseBtn: {
    position: 'absolute',
    right: '-12px',
    top: '50%',
    transform: 'translateY(-50%)',
    width: '24px',
    height: '24px',
    background: '#1A2942',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '50%',
    color: '#8F9BB3',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  // Main Content
  mainContent: {
    flex: 1,
    minHeight: '100vh',
    transition: 'margin-left 0.3s ease',
  },

  topBar: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '16px 32px',
    background: 'rgba(10, 22, 40, 0.8)',
    backdropFilter: 'blur(20px)',
    borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
    position: 'sticky',
    top: 0,
    zIndex: 50,
  },

  searchContainer: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    background: '#1A2942',
    borderRadius: '12px',
    padding: '12px 16px',
    width: '400px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  searchInput: {
    flex: 1,
    background: 'transparent',
    border: 'none',
    outline: 'none',
    color: '#E4E9F2',
    fontSize: '14px',
  },

  searchKbd: {
    background: '#243B55',
    color: '#8F9BB3',
    padding: '4px 8px',
    borderRadius: '6px',
    fontSize: '12px',
    fontFamily: "'JetBrains Mono', monospace",
  },

  topBarActions: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
  },

  topBarBtn: {
    position: 'relative',
    width: '40px',
    height: '40px',
    background: '#1A2942',
    border: '1px solid rgba(255, 255, 255, 0.06)',
    borderRadius: '10px',
    color: '#8F9BB3',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  notificationDot: {
    position: 'absolute',
    top: '8px',
    right: '8px',
    width: '8px',
    height: '8px',
    background: '#FF3D71',
    borderRadius: '50%',
  },

  createBtn: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    padding: '10px 20px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    border: 'none',
    borderRadius: '10px',
    color: '#fff',
    fontSize: '14px',
    fontWeight: 600,
    cursor: 'pointer',
  },

  userMenu: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    padding: '8px 12px',
    background: '#1A2942',
    borderRadius: '12px',
    cursor: 'pointer',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  userAvatar: {
    width: '36px',
    height: '36px',
    background: 'linear-gradient(135deg, #7B61FF 0%, #00D4FF 100%)',
    borderRadius: '10px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    color: '#fff',
    fontSize: '14px',
    fontWeight: 600,
  },

  userInfo: {
    display: 'flex',
    flexDirection: 'column',
  },

  userName: {
    fontSize: '14px',
    fontWeight: 600,
    color: '#E4E9F2',
  },

  userRole: {
    fontSize: '12px',
    color: '#8F9BB3',
  },

  // Page Content
  pageContent: {
    padding: '32px',
    minHeight: 'calc(100vh - 73px)',
  },

  // Dashboard
  dashboardContainer: {
    display: 'flex',
    flexDirection: 'column',
    gap: '24px',
  },

  welcomeSection: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    background: 'linear-gradient(135deg, rgba(0, 212, 255, 0.1) 0%, rgba(123, 97, 255, 0.1) 100%)',
    borderRadius: '20px',
    padding: '32px',
    border: '1px solid rgba(0, 212, 255, 0.2)',
  },

  welcomeContent: {},

  welcomeTitle: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '28px',
    fontWeight: 700,
    color: '#fff',
    marginBottom: '8px',
  },

  welcomeSubtitle: {
    fontSize: '16px',
    color: '#8F9BB3',
  },

  highlight: {
    color: '#00D4FF',
    fontWeight: 600,
  },

  welcomeActions: {
    display: 'flex',
    gap: '12px',
  },

  primaryBtn: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    padding: '12px 24px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    border: 'none',
    borderRadius: '12px',
    color: '#fff',
    fontSize: '14px',
    fontWeight: 600,
    cursor: 'pointer',
  },

  secondaryBtn: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    padding: '12px 24px',
    background: '#1A2942',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '12px',
    color: '#E4E9F2',
    fontSize: '14px',
    fontWeight: 600,
    cursor: 'pointer',
  },

  statsGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(4, 1fr)',
    gap: '20px',
  },

  statCard: {
    position: 'relative',
    background: '#1A2942',
    borderRadius: '16px',
    padding: '24px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
    overflow: 'hidden',
  },

  statHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: '16px',
  },

  statIcon: {
    width: '44px',
    height: '44px',
    borderRadius: '12px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  statChange: {
    display: 'flex',
    alignItems: 'center',
    gap: '4px',
    fontSize: '13px',
    fontWeight: 500,
  },

  statValue: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '32px',
    fontWeight: 700,
    color: '#fff',
    marginBottom: '4px',
  },

  statLabel: {
    fontSize: '14px',
    color: '#8F9BB3',
  },

  statGlow: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: '100px',
    pointerEvents: 'none',
  },

  dashboardGrid: {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: '20px',
  },

  // Cards
  pipelineCard: {
    gridColumn: 'span 2',
    background: '#1A2942',
    borderRadius: '16px',
    padding: '24px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  cardHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '20px',
  },

  cardTitle: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '18px',
    fontWeight: 600,
    color: '#fff',
  },

  cardAction: {
    background: 'transparent',
    border: 'none',
    color: '#00D4FF',
    fontSize: '14px',
    fontWeight: 500,
    cursor: 'pointer',
  },

  pipelineStages: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
  },

  pipelineStage: {
    flex: 1,
    position: 'relative',
  },

  pipelineStageHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '8px',
  },

  pipelineStageName: {
    fontSize: '14px',
    color: '#8F9BB3',
  },

  pipelineStageCount: {
    fontSize: '18px',
    fontWeight: 700,
  },

  pipelineBar: {
    height: '8px',
    background: 'rgba(255, 255, 255, 0.1)',
    borderRadius: '4px',
    overflow: 'hidden',
  },

  pipelineBarFill: {
    height: '100%',
    borderRadius: '4px',
    transition: 'width 0.5s ease',
  },

  pipelineConnector: {
    position: 'absolute',
    right: '-16px',
    top: '50%',
    transform: 'translateY(-50%)',
    color: '#5D6B82',
  },

  interviewsCard: {
    background: '#1A2942',
    borderRadius: '16px',
    padding: '24px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  interviewsList: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },

  interviewItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
    padding: '16px',
    background: 'rgba(255, 255, 255, 0.03)',
    borderRadius: '12px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  interviewTime: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    minWidth: '70px',
  },

  interviewTimeText: {
    fontSize: '14px',
    fontWeight: 600,
    color: '#fff',
  },

  interviewDate: {
    fontSize: '12px',
    color: '#8F9BB3',
  },

  interviewInfo: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    flex: 1,
  },

  interviewAvatar: {
    fontSize: '24px',
  },

  interviewDetails: {
    display: 'flex',
    flexDirection: 'column',
  },

  interviewCandidate: {
    fontSize: '14px',
    fontWeight: 600,
    color: '#fff',
  },

  interviewType: {
    fontSize: '13px',
    color: '#8F9BB3',
  },

  interviewStatus: {
    padding: '6px 12px',
    borderRadius: '8px',
    fontSize: '12px',
    fontWeight: 500,
  },

  topCandidatesCard: {
    background: '#1A2942',
    borderRadius: '16px',
    padding: '24px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  candidatesList: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },

  candidateItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    padding: '12px',
    background: 'rgba(255, 255, 255, 0.03)',
    borderRadius: '12px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  candidateAvatar: {
    fontSize: '28px',
  },

  candidateInfo: {
    flex: 1,
    display: 'flex',
    flexDirection: 'column',
  },

  candidateName: {
    fontSize: '14px',
    fontWeight: 600,
    color: '#fff',
  },

  candidateTitle: {
    fontSize: '13px',
    color: '#8F9BB3',
  },

  candidateScore: {},

  scoreCircle: {
    position: 'relative',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  scoreValue: {
    position: 'absolute',
    fontSize: '12px',
    fontWeight: 700,
    color: '#fff',
  },

  activityCard: {
    gridColumn: 'span 2',
    background: '#1A2942',
    borderRadius: '16px',
    padding: '24px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  activityList: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },

  activityItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
    padding: '16px',
    background: 'rgba(255, 255, 255, 0.03)',
    borderRadius: '12px',
  },

  activityIcon: {
    width: '40px',
    height: '40px',
    borderRadius: '10px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '18px',
  },

  activityContent: {
    flex: 1,
    display: 'flex',
    flexDirection: 'column',
  },

  activityAction: {
    fontSize: '14px',
    fontWeight: 600,
    color: '#fff',
  },

  activityDetail: {
    fontSize: '13px',
    color: '#8F9BB3',
  },

  activityTime: {
    fontSize: '12px',
    color: '#5D6B82',
  },

  // Page Common
  pageContainer: {
    display: 'flex',
    flexDirection: 'column',
    gap: '24px',
  },

  pageHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },

  pageTitle: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '28px',
    fontWeight: 700,
    color: '#fff',
    marginBottom: '4px',
  },

  pageSubtitle: {
    fontSize: '15px',
    color: '#8F9BB3',
  },

  headerActions: {
    display: 'flex',
    gap: '12px',
  },

  // Jobs
  filtersBar: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  filterTabs: {
    display: 'flex',
    gap: '4px',
    background: '#1A2942',
    padding: '4px',
    borderRadius: '10px',
  },

  filterTab: {
    padding: '8px 16px',
    background: 'transparent',
    border: 'none',
    borderRadius: '8px',
    color: '#8F9BB3',
    fontSize: '14px',
    fontWeight: 500,
    cursor: 'pointer',
  },

  filterTabActive: {
    background: 'rgba(0, 212, 255, 0.1)',
    color: '#00D4FF',
  },

  filterActions: {
    display: 'flex',
    gap: '12px',
    alignItems: 'center',
  },

  iconBtn: {
    width: '40px',
    height: '40px',
    background: '#1A2942',
    border: '1px solid rgba(255, 255, 255, 0.06)',
    borderRadius: '10px',
    color: '#8F9BB3',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  viewToggle: {
    display: 'flex',
    gap: '4px',
    background: '#1A2942',
    padding: '4px',
    borderRadius: '8px',
  },

  viewBtn: {
    width: '32px',
    height: '32px',
    background: 'transparent',
    border: 'none',
    borderRadius: '6px',
    color: '#8F9BB3',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  viewBtnActive: {
    background: '#243B55',
    color: '#00D4FF',
  },

  jobsGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(3, 1fr)',
    gap: '20px',
  },

  jobsList: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },

  jobCard: {
    background: '#1A2942',
    borderRadius: '16px',
    padding: '24px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
    display: 'flex',
    flexDirection: 'column',
    gap: '16px',
  },

  jobCardHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  jobStatus: {
    padding: '6px 12px',
    borderRadius: '8px',
    fontSize: '12px',
    fontWeight: 500,
  },

  jobMenuBtn: {
    background: 'transparent',
    border: 'none',
    color: '#8F9BB3',
    cursor: 'pointer',
  },

  jobTitle: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '18px',
    fontWeight: 600,
    color: '#fff',
  },

  jobMeta: {
    display: 'flex',
    gap: '16px',
  },

  jobMetaItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    fontSize: '13px',
    color: '#8F9BB3',
  },

  jobSalary: {
    fontSize: '14px',
    fontWeight: 600,
    color: '#00E5A0',
  },

  jobStats: {
    display: 'flex',
    gap: '24px',
    padding: '16px 0',
    borderTop: '1px solid rgba(255, 255, 255, 0.06)',
    borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
  },

  jobStat: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },

  jobStatValue: {
    fontSize: '20px',
    fontWeight: 700,
    color: '#fff',
  },

  jobStatLabel: {
    fontSize: '12px',
    color: '#8F9BB3',
  },

  jobActions: {
    display: 'flex',
    gap: '8px',
  },

  jobActionBtn: {
    flex: 1,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '6px',
    padding: '10px',
    background: 'rgba(255, 255, 255, 0.05)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '10px',
    color: '#E4E9F2',
    fontSize: '13px',
    fontWeight: 500,
    cursor: 'pointer',
  },

  addJobCard: {
    background: 'transparent',
    borderRadius: '16px',
    padding: '24px',
    border: '2px dashed rgba(0, 212, 255, 0.3)',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '12px',
    cursor: 'pointer',
    minHeight: '280px',
  },

  addJobIcon: {
    width: '56px',
    height: '56px',
    background: 'rgba(0, 212, 255, 0.1)',
    borderRadius: '16px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    color: '#00D4FF',
  },

  addJobText: {
    fontSize: '16px',
    fontWeight: 600,
    color: '#00D4FF',
  },

  // Candidates Kanban
  viewModeBar: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  viewModeToggle: {
    display: 'flex',
    gap: '4px',
    background: '#1A2942',
    padding: '4px',
    borderRadius: '10px',
  },

  viewModeBtn: {
    padding: '8px 16px',
    background: 'transparent',
    border: 'none',
    borderRadius: '8px',
    color: '#8F9BB3',
    fontSize: '14px',
    fontWeight: 500,
    cursor: 'pointer',
  },

  viewModeBtnActive: {
    background: 'rgba(0, 212, 255, 0.1)',
    color: '#00D4FF',
  },

  candidateCount: {
    fontSize: '14px',
    color: '#8F9BB3',
  },

  kanbanBoard: {
    display: 'flex',
    gap: '16px',
    overflowX: 'auto',
    paddingBottom: '16px',
  },

  kanbanColumn: {
    minWidth: '300px',
    maxWidth: '300px',
    background: '#1A2942',
    borderRadius: '16px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
    display: 'flex',
    flexDirection: 'column',
    maxHeight: 'calc(100vh - 300px)',
  },

  kanbanColumnHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '16px 20px',
    borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
  },

  kanbanColumnTitle: {
    fontSize: '15px',
    fontWeight: 600,
    color: '#fff',
  },

  kanbanColumnCount: {
    background: 'rgba(0, 212, 255, 0.1)',
    color: '#00D4FF',
    padding: '4px 10px',
    borderRadius: '8px',
    fontSize: '13px',
    fontWeight: 600,
  },

  kanbanColumnContent: {
    flex: 1,
    overflowY: 'auto',
    padding: '12px',
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },

  kanbanCard: {
    background: '#243B55',
    borderRadius: '12px',
    padding: '16px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },

  kanbanCardHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  kanbanCardAvatar: {
    fontSize: '28px',
  },

  kanbanCardScore: {
    display: 'flex',
    alignItems: 'center',
    gap: '4px',
    color: '#FFB800',
    fontSize: '14px',
    fontWeight: 600,
  },

  kanbanCardName: {
    fontSize: '15px',
    fontWeight: 600,
    color: '#fff',
    margin: 0,
  },

  kanbanCardTitle: {
    fontSize: '13px',
    color: '#8F9BB3',
    margin: 0,
  },

  kanbanCardCompany: {
    fontSize: '12px',
    color: '#5D6B82',
    margin: 0,
  },

  kanbanCardSkills: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: '6px',
  },

  skillTag: {
    background: 'rgba(0, 212, 255, 0.1)',
    color: '#00D4FF',
    padding: '4px 8px',
    borderRadius: '6px',
    fontSize: '11px',
    fontWeight: 500,
  },

  kanbanCardFooter: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: '12px',
    borderTop: '1px solid rgba(255, 255, 255, 0.06)',
  },

  kanbanCardDate: {
    display: 'flex',
    alignItems: 'center',
    gap: '4px',
    fontSize: '12px',
    color: '#5D6B82',
  },

  kanbanCardAction: {
    background: 'transparent',
    border: 'none',
    color: '#8F9BB3',
    cursor: 'pointer',
  },

  kanbanAddBtn: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '8px',
    padding: '12px',
    background: 'transparent',
    border: '2px dashed rgba(255, 255, 255, 0.1)',
    borderRadius: '12px',
    color: '#8F9BB3',
    fontSize: '14px',
    cursor: 'pointer',
  },

  // Candidate List View
  candidatesListView: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px',
  },

  candidateListItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
    padding: '16px 20px',
    background: '#1A2942',
    borderRadius: '12px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  candidateListAvatar: {
    fontSize: '32px',
  },

  candidateListInfo: {
    flex: 1,
    minWidth: '200px',
  },

  candidateListName: {
    fontSize: '15px',
    fontWeight: 600,
    color: '#fff',
    margin: 0,
  },

  candidateListTitle: {
    fontSize: '13px',
    color: '#8F9BB3',
    margin: 0,
  },

  candidateListMeta: {
    minWidth: '150px',
  },

  candidateListLocation: {
    display: 'flex',
    alignItems: 'center',
    gap: '4px',
    fontSize: '13px',
    color: '#8F9BB3',
  },

  candidateListSkills: {
    display: 'flex',
    gap: '6px',
    minWidth: '200px',
  },

  skillTagSmall: {
    background: 'rgba(0, 212, 255, 0.1)',
    color: '#00D4FF',
    padding: '4px 8px',
    borderRadius: '6px',
    fontSize: '11px',
    fontWeight: 500,
  },

  candidateListScore: {
    minWidth: '80px',
  },

  scoreBar: {
    height: '8px',
    background: 'rgba(255, 255, 255, 0.1)',
    borderRadius: '4px',
    position: 'relative',
    overflow: 'hidden',
  },

  candidateListStatus: {
    padding: '6px 12px',
    borderRadius: '8px',
    fontSize: '12px',
    fontWeight: 500,
    minWidth: '100px',
    textAlign: 'center',
  },

  candidateListAction: {
    background: 'transparent',
    border: 'none',
    color: '#8F9BB3',
    cursor: 'pointer',
  },

  // Slideover Panel
  slideoverBackdrop: {
    position: 'fixed',
    inset: 0,
    background: 'rgba(0, 0, 0, 0.5)',
    backdropFilter: 'blur(4px)',
    zIndex: 200,
    display: 'flex',
    justifyContent: 'flex-end',
  },

  slideoverPanel: {
    width: '480px',
    height: '100vh',
    background: '#0D1B2A',
    borderLeft: '1px solid rgba(255, 255, 255, 0.1)',
    display: 'flex',
    flexDirection: 'column',
    animation: 'slideIn 0.3s ease',
  },

  slideoverHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '20px 24px',
    borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
  },

  closeBtn: {
    width: '36px',
    height: '36px',
    background: 'rgba(255, 255, 255, 0.05)',
    border: 'none',
    borderRadius: '10px',
    color: '#8F9BB3',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  slideoverActions: {
    display: 'flex',
    gap: '8px',
  },

  secondaryBtnSm: {
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    padding: '8px 16px',
    background: '#1A2942',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '8px',
    color: '#E4E9F2',
    fontSize: '13px',
    fontWeight: 500,
    cursor: 'pointer',
  },

  primaryBtnSm: {
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    padding: '8px 16px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    border: 'none',
    borderRadius: '8px',
    color: '#fff',
    fontSize: '13px',
    fontWeight: 500,
    cursor: 'pointer',
  },

  candidateProfile: {
    display: 'flex',
    alignItems: 'flex-start',
    gap: '20px',
    padding: '24px',
    borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
  },

  profileAvatar: {
    fontSize: '56px',
  },

  profileInfo: {
    flex: 1,
  },

  profileName: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '22px',
    fontWeight: 700,
    color: '#fff',
    margin: '0 0 4px 0',
  },

  profileTitle: {
    fontSize: '15px',
    color: '#E4E9F2',
    margin: '0 0 2px 0',
  },

  profileCompany: {
    fontSize: '14px',
    color: '#8F9BB3',
    margin: 0,
  },

  profileScore: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },

  scoreLarge: {
    position: 'relative',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  scoreLargeValue: {
    position: 'absolute',
    fontSize: '20px',
    fontWeight: 700,
    color: '#fff',
  },

  scoreLabel: {
    fontSize: '12px',
    color: '#8F9BB3',
    marginTop: '8px',
  },

  profileMeta: {
    display: 'flex',
    gap: '24px',
    padding: '16px 24px',
    borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
  },

  profileMetaItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    fontSize: '13px',
    color: '#8F9BB3',
  },

  profileTabs: {
    display: 'flex',
    gap: '4px',
    padding: '0 24px',
    borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
  },

  profileTab: {
    padding: '16px 20px',
    background: 'transparent',
    border: 'none',
    borderBottom: '2px solid transparent',
    color: '#8F9BB3',
    fontSize: '14px',
    fontWeight: 500,
    cursor: 'pointer',
  },

  profileTabActive: {
    borderBottomColor: '#00D4FF',
    color: '#00D4FF',
  },

  profileContent: {
    flex: 1,
    overflowY: 'auto',
    padding: '24px',
  },

  profileSection: {
    marginBottom: '24px',
  },

  sectionTitle: {
    fontSize: '14px',
    fontWeight: 600,
    color: '#8F9BB3',
    textTransform: 'uppercase',
    letterSpacing: '0.5px',
    marginBottom: '12px',
  },

  skillsGrid: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: '8px',
  },

  skillTagLarge: {
    background: 'rgba(0, 212, 255, 0.1)',
    color: '#00D4FF',
    padding: '8px 16px',
    borderRadius: '8px',
    fontSize: '13px',
    fontWeight: 500,
  },

  aiAnalysis: {
    background: 'linear-gradient(135deg, rgba(0, 212, 255, 0.1) 0%, rgba(123, 97, 255, 0.1) 100%)',
    borderRadius: '12px',
    padding: '20px',
    border: '1px solid rgba(0, 212, 255, 0.2)',
  },

  aiAnalysisHeader: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    color: '#00D4FF',
    fontSize: '14px',
    fontWeight: 600,
    marginBottom: '12px',
  },

  aiAnalysisText: {
    fontSize: '14px',
    color: '#C5CEE0',
    lineHeight: 1.6,
    marginBottom: '16px',
  },

  aiStrengths: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px',
  },

  aiStrengthItem: {
    fontSize: '13px',
    color: '#00E5A0',
  },

  contactList: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },

  contactItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    fontSize: '14px',
    color: '#E4E9F2',
  },

  slideoverFooter: {
    display: 'flex',
    gap: '12px',
    padding: '20px 24px',
    borderTop: '1px solid rgba(255, 255, 255, 0.06)',
  },

  rejectBtn: {
    flex: 1,
    padding: '14px',
    background: 'rgba(255, 61, 113, 0.1)',
    border: '1px solid rgba(255, 61, 113, 0.3)',
    borderRadius: '10px',
    color: '#FF3D71',
    fontSize: '14px',
    fontWeight: 600,
    cursor: 'pointer',
  },

  advanceBtn: {
    flex: 1,
    padding: '14px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    border: 'none',
    borderRadius: '10px',
    color: '#fff',
    fontSize: '14px',
    fontWeight: 600,
    cursor: 'pointer',
  },

  // Interviews
  interviewsGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(2, 1fr)',
    gap: '16px',
  },

  interviewCard: {
    background: '#1A2942',
    borderRadius: '16px',
    padding: '20px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  interviewCardHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: '16px',
  },

  interviewCardTime: {
    display: 'flex',
    flexDirection: 'column',
  },

  interviewCardTimeText: {
    fontSize: '20px',
    fontWeight: 700,
    color: '#fff',
  },

  interviewCardDate: {
    fontSize: '13px',
    color: '#8F9BB3',
  },

  interviewCardStatus: {
    padding: '6px 12px',
    borderRadius: '8px',
    fontSize: '12px',
    fontWeight: 500,
  },

  interviewCardBody: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
    marginBottom: '16px',
  },

  interviewCardAvatar: {
    fontSize: '40px',
  },

  interviewCardInfo: {
    flex: 1,
  },

  interviewCardName: {
    fontSize: '16px',
    fontWeight: 600,
    color: '#fff',
    margin: '0 0 4px 0',
  },

  interviewCardPosition: {
    fontSize: '14px',
    color: '#E4E9F2',
    margin: '0 0 2px 0',
  },

  interviewCardType: {
    fontSize: '13px',
    color: '#8F9BB3',
    margin: 0,
  },

  interviewCardFooter: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: '16px',
    borderTop: '1px solid rgba(255, 255, 255, 0.06)',
  },

  interviewCardInterviewer: {
    display: 'flex',
    alignItems: 'center',
    gap: '6px',
    fontSize: '13px',
    color: '#8F9BB3',
  },

  interviewCardActions: {
    display: 'flex',
    gap: '8px',
  },

  iconBtnSm: {
    width: '32px',
    height: '32px',
    background: 'rgba(255, 255, 255, 0.05)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '8px',
    color: '#8F9BB3',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  modalOverlay: {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    background: 'rgba(0, 0, 0, 0.7)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1000,
    backdropFilter: 'blur(4px)',
  },

  modalContent: {
    background: '#0D1B2A',
    borderRadius: '16px',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    width: '100%',
    maxWidth: '500px',
    maxHeight: '80vh',
    overflow: 'auto',
    boxShadow: '0 20px 60px rgba(0, 0, 0, 0.5)',
  },

  modalHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '20px 24px',
    borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
  },

  modalTitle: {
    fontSize: '20px',
    fontWeight: 600,
    color: '#fff',
    margin: 0,
  },

  modalCloseBtn: {
    width: '36px',
    height: '36px',
    background: 'rgba(255, 255, 255, 0.05)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '8px',
    color: '#8F9BB3',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  modalBody: {
    padding: '24px',
  },

  modalFooter: {
    display: 'flex',
    justifyContent: 'flex-end',
    gap: '12px',
    padding: '16px 24px',
    borderTop: '1px solid rgba(255, 255, 255, 0.1)',
  },

  jobDetailRow: {
    display: 'flex',
    justifyContent: 'space-between',
    padding: '12px 0',
    borderBottom: '1px solid rgba(255, 255, 255, 0.05)',
  },

  jobDetailLabel: {
    color: '#8F9BB3',
    fontSize: '14px',
  },

  jobDetailValue: {
    color: '#fff',
    fontSize: '14px',
    fontWeight: 500,
  },

  formGroup: {
    marginBottom: '20px',
  },

  formLabel: {
    display: 'block',
    color: '#8F9BB3',
    fontSize: '14px',
    marginBottom: '8px',
  },

  formInput: {
    width: '100%',
    padding: '12px 16px',
    background: 'rgba(255, 255, 255, 0.05)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '8px',
    color: '#fff',
    fontSize: '14px',
    outline: 'none',
    boxSizing: 'border-box',
  },

  formRow: {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: '16px',
  },

  fileUpload: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '24px',
    background: 'rgba(255, 255, 255, 0.02)',
    border: '2px dashed rgba(255, 255, 255, 0.1)',
    borderRadius: '8px',
    color: '#8F9BB3',
    cursor: 'pointer',
    gap: '8px',
    textAlign: 'center',
  },

  fileHint: {
    fontSize: '12px',
    color: '#6B7688',
  },
};
