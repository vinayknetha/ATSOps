-- ============================================================================
-- TALENTFORGE ATS - DATABASE SCHEMA
-- Version: 2.0
-- Database: PostgreSQL 15+
-- Approach: DB-First, Normalized (3NF+), Audit Columns on All Tables
-- ============================================================================

-- ============================================================================
-- EXTENSIONS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- Trigram for fuzzy search
CREATE EXTENSION IF NOT EXISTS "unaccent";       -- Accent-insensitive search

-- ============================================================================
-- CUSTOM TYPES (ENUMS)
-- ============================================================================

-- Organization/Subscription
CREATE TYPE subscription_tier AS ENUM ('free', 'starter', 'pro', 'business', 'enterprise');
CREATE TYPE org_status AS ENUM ('active', 'suspended', 'cancelled', 'trial');

-- User related
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'pending', 'locked');
CREATE TYPE user_role AS ENUM ('super_admin', 'admin', 'recruiter', 'hiring_manager', 'interviewer', 'viewer');

-- Job related
CREATE TYPE job_status AS ENUM ('draft', 'open', 'paused', 'closed', 'archived');
CREATE TYPE job_type AS ENUM ('full_time', 'part_time', 'contract', 'internship', 'temporary', 'freelance');
CREATE TYPE workplace_type AS ENUM ('onsite', 'remote', 'hybrid');
CREATE TYPE experience_level AS ENUM ('entry', 'associate', 'mid', 'senior', 'lead', 'manager', 'director', 'executive');

-- Candidate related
CREATE TYPE candidate_status AS ENUM ('active', 'passive', 'not_looking', 'archived');
CREATE TYPE candidate_source AS ENUM ('direct_apply', 'referral', 'linkedin', 'indeed', 'glassdoor', 'naukri', 'agency', 'career_site', 'job_fair', 'university', 'other');

-- Application related
CREATE TYPE application_status AS ENUM ('new', 'reviewed', 'shortlisted', 'interviewing', 'offer', 'hired', 'rejected', 'withdrawn');

-- Communication
CREATE TYPE communication_type AS ENUM ('email', 'sms', 'whatsapp', 'phone_call', 'in_app', 'system');
CREATE TYPE communication_direction AS ENUM ('inbound', 'outbound');
CREATE TYPE communication_status AS ENUM ('pending', 'sent', 'delivered', 'read', 'failed', 'bounced');

-- Activity
CREATE TYPE activity_type AS ENUM ('created', 'updated', 'deleted', 'viewed', 'status_changed', 'stage_changed', 'note_added', 'email_sent', 'interview_scheduled', 'score_updated', 'document_uploaded', 'comment_added');

-- ============================================================================
-- SECTION 1: LOOKUP/REFERENCE TABLES
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: countries
-- Purpose: ISO 3166-1 country codes
-- -----------------------------------------------------------------------------
CREATE TABLE countries (
    id SERIAL PRIMARY KEY,
    iso_code CHAR(2) NOT NULL UNIQUE,           -- ISO 3166-1 alpha-2
    iso_code_3 CHAR(3) NOT NULL UNIQUE,         -- ISO 3166-1 alpha-3
    name VARCHAR(100) NOT NULL,
    phone_code VARCHAR(10),
    currency_code CHAR(3),
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_countries_name ON countries(name);
CREATE INDEX idx_countries_iso ON countries(iso_code);

COMMENT ON TABLE countries IS 'ISO 3166-1 country reference data';

-- -----------------------------------------------------------------------------
-- Table: states_provinces
-- Purpose: States/Provinces within countries
-- -----------------------------------------------------------------------------
CREATE TABLE states_provinces (
    id SERIAL PRIMARY KEY,
    country_id INTEGER NOT NULL REFERENCES countries(id),
    code VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(country_id, code)
);

CREATE INDEX idx_states_country ON states_provinces(country_id);
CREATE INDEX idx_states_name ON states_provinces(name);

COMMENT ON TABLE states_provinces IS 'States and provinces within countries';

-- -----------------------------------------------------------------------------
-- Table: cities
-- Purpose: Cities within states/provinces
-- -----------------------------------------------------------------------------
CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    state_province_id INTEGER REFERENCES states_provinces(id),
    country_id INTEGER NOT NULL REFERENCES countries(id),
    name VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_cities_state ON cities(state_province_id);
CREATE INDEX idx_cities_country ON cities(country_id);
CREATE INDEX idx_cities_name ON cities(name);

COMMENT ON TABLE cities IS 'Cities reference data with geo coordinates';

-- -----------------------------------------------------------------------------
-- Table: industries
-- Purpose: Industry classification
-- -----------------------------------------------------------------------------
CREATE TABLE industries (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    name VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES industries(id),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_industries_parent ON industries(parent_id);
CREATE INDEX idx_industries_name ON industries(name);

COMMENT ON TABLE industries IS 'Hierarchical industry classification';

-- -----------------------------------------------------------------------------
-- Table: departments
-- Purpose: Common department names (template)
-- -----------------------------------------------------------------------------
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

COMMENT ON TABLE departments IS 'Standard department names template';

-- -----------------------------------------------------------------------------
-- Table: currencies
-- Purpose: Currency reference
-- -----------------------------------------------------------------------------
CREATE TABLE currencies (
    id SERIAL PRIMARY KEY,
    code CHAR(3) NOT NULL UNIQUE,               -- ISO 4217
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(5),
    decimal_places SMALLINT DEFAULT 2,
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

COMMENT ON TABLE currencies IS 'ISO 4217 currency codes';

-- -----------------------------------------------------------------------------
-- Table: languages
-- Purpose: Language reference
-- -----------------------------------------------------------------------------
CREATE TABLE languages (
    id SERIAL PRIMARY KEY,
    iso_code CHAR(2) NOT NULL UNIQUE,           -- ISO 639-1
    iso_code_3 CHAR(3) UNIQUE,                  -- ISO 639-2
    name VARCHAR(50) NOT NULL,
    native_name VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

COMMENT ON TABLE languages IS 'ISO 639 language codes';

-- -----------------------------------------------------------------------------
-- Table: education_levels
-- Purpose: Education level hierarchy
-- -----------------------------------------------------------------------------
CREATE TABLE education_levels (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    rank INTEGER NOT NULL,                       -- For comparison (higher = more advanced)
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

COMMENT ON TABLE education_levels IS 'Education level hierarchy (High School < Bachelor < Master < PhD)';

-- -----------------------------------------------------------------------------
-- Table: field_of_study
-- Purpose: Academic fields/majors
-- -----------------------------------------------------------------------------
CREATE TABLE fields_of_study (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    parent_id INTEGER REFERENCES fields_of_study(id),
    category VARCHAR(50),                        -- STEM, Business, Arts, etc.
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_fields_study_parent ON fields_of_study(parent_id);
CREATE INDEX idx_fields_study_category ON fields_of_study(category);

COMMENT ON TABLE fields_of_study IS 'Academic fields and majors';

-- ============================================================================
-- SECTION 2: SKILLS TAXONOMY
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: skill_categories
-- Purpose: Skill categorization
-- -----------------------------------------------------------------------------
CREATE TABLE skill_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id INTEGER REFERENCES skill_categories(id),
    icon VARCHAR(50),
    color VARCHAR(7),                            -- Hex color
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_skill_categories_parent ON skill_categories(parent_id);

COMMENT ON TABLE skill_categories IS 'Hierarchical skill categorization';

-- -----------------------------------------------------------------------------
-- Table: skills
-- Purpose: Master skills list with canonical names
-- -----------------------------------------------------------------------------
CREATE TABLE skills (
    id SERIAL PRIMARY KEY,
    canonical_name VARCHAR(150) NOT NULL UNIQUE, -- Official name
    display_name VARCHAR(150) NOT NULL,
    category_id INTEGER REFERENCES skill_categories(id),
    description TEXT,
    skill_type VARCHAR(20) DEFAULT 'hard',       -- hard, soft, tool, language
    is_verified BOOLEAN DEFAULT false,           -- Admin-verified skill
    usage_count INTEGER DEFAULT 0,               -- How often used
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_skills_category ON skills(category_id);
CREATE INDEX idx_skills_type ON skills(skill_type);
CREATE INDEX idx_skills_canonical ON skills(canonical_name);
CREATE INDEX idx_skills_display ON skills USING gin(display_name gin_trgm_ops);

COMMENT ON TABLE skills IS 'Master skills taxonomy with canonical names';

-- -----------------------------------------------------------------------------
-- Table: skill_aliases
-- Purpose: Alternative names/synonyms for skills
-- -----------------------------------------------------------------------------
CREATE TABLE skill_aliases (
    id SERIAL PRIMARY KEY,
    skill_id INTEGER NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    alias VARCHAR(150) NOT NULL,
    language_id INTEGER REFERENCES languages(id),
    is_primary BOOLEAN DEFAULT false,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    
    UNIQUE(skill_id, alias)
);

CREATE INDEX idx_skill_aliases_skill ON skill_aliases(skill_id);
CREATE INDEX idx_skill_aliases_alias ON skill_aliases USING gin(alias gin_trgm_ops);

COMMENT ON TABLE skill_aliases IS 'Skill synonyms and alternative names for matching';

-- -----------------------------------------------------------------------------
-- Table: skill_relationships
-- Purpose: Related skills (for suggestions)
-- -----------------------------------------------------------------------------
CREATE TABLE skill_relationships (
    id SERIAL PRIMARY KEY,
    skill_id INTEGER NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    related_skill_id INTEGER NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    relationship_type VARCHAR(30) NOT NULL,      -- 'related', 'prerequisite', 'superset', 'subset'
    strength DECIMAL(3,2) DEFAULT 0.5,           -- 0.0 to 1.0
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    
    UNIQUE(skill_id, related_skill_id, relationship_type),
    CHECK(skill_id != related_skill_id)
);

CREATE INDEX idx_skill_rel_skill ON skill_relationships(skill_id);
CREATE INDEX idx_skill_rel_related ON skill_relationships(related_skill_id);

COMMENT ON TABLE skill_relationships IS 'Relationships between skills for intelligent suggestions';
-- ============================================================================
-- TALENTFORGE ATS - DATABASE SCHEMA
-- Part 2: Organizations, Users, Authentication, Security
-- ============================================================================

-- ============================================================================
-- SECTION 3: ORGANIZATIONS (MULTI-TENANT)
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: organizations
-- Purpose: Tenant/Company accounts
-- -----------------------------------------------------------------------------
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,           -- URL-friendly identifier
    legal_name VARCHAR(200),
    
    -- Contact
    email VARCHAR(255),
    phone VARCHAR(30),
    website VARCHAR(255),
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city_id INTEGER REFERENCES cities(id),
    state_province_id INTEGER REFERENCES states_provinces(id),
    country_id INTEGER REFERENCES countries(id),
    postal_code VARCHAR(20),
    
    -- Business Info
    industry_id INTEGER REFERENCES industries(id),
    company_size VARCHAR(30),                    -- 1-10, 11-50, 51-200, etc.
    founded_year INTEGER,
    description TEXT,
    
    -- Branding
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    
    -- Subscription
    subscription_tier subscription_tier NOT NULL DEFAULT 'free',
    subscription_status org_status NOT NULL DEFAULT 'trial',
    trial_ends_at TIMESTAMPTZ,
    subscription_starts_at TIMESTAMPTZ,
    subscription_ends_at TIMESTAMPTZ,
    
    -- Limits (based on tier)
    max_users INTEGER DEFAULT 1,
    max_jobs INTEGER DEFAULT 1,
    max_candidates_per_month INTEGER DEFAULT 25,
    
    -- Settings (JSONB for flexibility)
    settings JSONB DEFAULT '{}',
    features_enabled JSONB DEFAULT '{}',
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    verified_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,                      -- Soft delete
    deleted_by UUID
);

CREATE INDEX idx_org_slug ON organizations(slug);
CREATE INDEX idx_org_industry ON organizations(industry_id);
CREATE INDEX idx_org_status ON organizations(subscription_status);
CREATE INDEX idx_org_tier ON organizations(subscription_tier);
CREATE INDEX idx_org_active ON organizations(is_active) WHERE is_active = true;
CREATE INDEX idx_org_deleted ON organizations(deleted_at) WHERE deleted_at IS NULL;

COMMENT ON TABLE organizations IS 'Multi-tenant organization accounts';

-- -----------------------------------------------------------------------------
-- Table: organization_departments
-- Purpose: Organization-specific departments
-- -----------------------------------------------------------------------------
CREATE TABLE organization_departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20),
    parent_id UUID REFERENCES organization_departments(id),
    head_user_id UUID,                           -- FK added after users table
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    
    UNIQUE(organization_id, name)
);

CREATE INDEX idx_org_dept_org ON organization_departments(organization_id);
CREATE INDEX idx_org_dept_parent ON organization_departments(parent_id);

COMMENT ON TABLE organization_departments IS 'Organization-specific department structure';

-- -----------------------------------------------------------------------------
-- Table: organization_locations
-- Purpose: Office locations for an organization
-- -----------------------------------------------------------------------------
CREATE TABLE organization_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,                  -- HQ, Branch Office, etc.
    location_type VARCHAR(30) DEFAULT 'office', -- office, warehouse, remote_hub
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city_id INTEGER REFERENCES cities(id),
    state_province_id INTEGER REFERENCES states_provinces(id),
    country_id INTEGER NOT NULL REFERENCES countries(id),
    postal_code VARCHAR(20),
    
    -- Contact
    phone VARCHAR(30),
    email VARCHAR(255),
    
    -- Geo
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50),
    
    is_headquarters BOOLEAN DEFAULT false,
    is_hiring_location BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

CREATE INDEX idx_org_loc_org ON organization_locations(organization_id);
CREATE INDEX idx_org_loc_country ON organization_locations(country_id);
CREATE INDEX idx_org_loc_city ON organization_locations(city_id);

COMMENT ON TABLE organization_locations IS 'Physical office locations for organizations';

-- ============================================================================
-- SECTION 4: USERS & AUTHENTICATION
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: users
-- Purpose: User accounts (recruiters, hiring managers, etc.)
-- -----------------------------------------------------------------------------
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Identity
    email VARCHAR(255) NOT NULL,
    email_verified_at TIMESTAMPTZ,
    phone VARCHAR(30),
    phone_verified_at TIMESTAMPTZ,
    
    -- Profile
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(200),
    avatar_url VARCHAR(500),
    job_title VARCHAR(100),
    department_id UUID REFERENCES organization_departments(id),
    
    -- Auth
    password_hash VARCHAR(255),
    password_changed_at TIMESTAMPTZ,
    must_change_password BOOLEAN DEFAULT false,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMPTZ,
    
    -- Role & Permissions
    role user_role NOT NULL DEFAULT 'viewer',
    permissions JSONB DEFAULT '[]',              -- Additional granular permissions
    
    -- Settings
    timezone VARCHAR(50) DEFAULT 'UTC',
    locale VARCHAR(10) DEFAULT 'en-US',
    preferences JSONB DEFAULT '{}',
    notification_settings JSONB DEFAULT '{}',
    
    -- Status
    status user_status NOT NULL DEFAULT 'pending',
    last_login_at TIMESTAMPTZ,
    last_activity_at TIMESTAMPTZ,
    invited_at TIMESTAMPTZ,
    invited_by UUID REFERENCES users(id),
    activated_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    
    UNIQUE(organization_id, email)
);

-- Add FK for department head
ALTER TABLE organization_departments 
    ADD CONSTRAINT fk_dept_head FOREIGN KEY (head_user_id) REFERENCES users(id);

CREATE INDEX idx_users_org ON users(organization_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_dept ON users(department_id);
CREATE INDEX idx_users_active ON users(organization_id, status) WHERE status = 'active';
CREATE INDEX idx_users_deleted ON users(deleted_at) WHERE deleted_at IS NULL;

COMMENT ON TABLE users IS 'System users with authentication and authorization';

-- -----------------------------------------------------------------------------
-- Table: user_sessions
-- Purpose: Active user sessions (JWT refresh tokens)
-- -----------------------------------------------------------------------------
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Token
    refresh_token_hash VARCHAR(255) NOT NULL,
    
    -- Session info
    ip_address INET,
    user_agent TEXT,
    device_type VARCHAR(30),                     -- desktop, mobile, tablet
    device_name VARCHAR(100),
    browser VARCHAR(50),
    os VARCHAR(50),
    
    -- Location (from IP)
    country_code CHAR(2),
    city VARCHAR(100),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    last_used_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    revoked_reason VARCHAR(100),
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_sessions_token ON user_sessions(refresh_token_hash);
CREATE INDEX idx_sessions_active ON user_sessions(user_id, is_active) WHERE is_active = true;
CREATE INDEX idx_sessions_expires ON user_sessions(expires_at);

COMMENT ON TABLE user_sessions IS 'Active user sessions for JWT refresh token management';

-- -----------------------------------------------------------------------------
-- Table: user_oauth_accounts
-- Purpose: OAuth provider connections (Google, Microsoft, LinkedIn)
-- -----------------------------------------------------------------------------
CREATE TABLE user_oauth_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    provider VARCHAR(30) NOT NULL,               -- google, microsoft, linkedin
    provider_user_id VARCHAR(255) NOT NULL,
    provider_email VARCHAR(255),
    
    -- Tokens (encrypted)
    access_token_encrypted TEXT,
    refresh_token_encrypted TEXT,
    token_expires_at TIMESTAMPTZ,
    
    -- Profile from provider
    provider_profile JSONB DEFAULT '{}',
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    connected_at TIMESTAMPTZ DEFAULT NOW(),
    last_used_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(provider, provider_user_id),
    UNIQUE(user_id, provider)
);

CREATE INDEX idx_oauth_user ON user_oauth_accounts(user_id);
CREATE INDEX idx_oauth_provider ON user_oauth_accounts(provider, provider_user_id);

COMMENT ON TABLE user_oauth_accounts IS 'OAuth provider connections for social login';

-- -----------------------------------------------------------------------------
-- Table: user_mfa
-- Purpose: Multi-factor authentication settings
-- -----------------------------------------------------------------------------
CREATE TABLE user_mfa (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    mfa_type VARCHAR(20) NOT NULL,               -- totp, sms, email
    
    -- TOTP
    totp_secret_encrypted TEXT,
    
    -- SMS/Email
    phone_number VARCHAR(30),
    email VARCHAR(255),
    
    -- Status
    is_enabled BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    
    -- Backup codes
    backup_codes_hash TEXT[],
    backup_codes_used INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(user_id, mfa_type)
);

CREATE INDEX idx_mfa_user ON user_mfa(user_id);

COMMENT ON TABLE user_mfa IS 'Multi-factor authentication configuration';

-- -----------------------------------------------------------------------------
-- Table: password_reset_tokens
-- Purpose: Password reset requests
-- -----------------------------------------------------------------------------
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    token_hash VARCHAR(255) NOT NULL,
    
    -- Request info
    ip_address INET,
    user_agent TEXT,
    
    -- Status
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_pwd_reset_user ON password_reset_tokens(user_id);
CREATE INDEX idx_pwd_reset_token ON password_reset_tokens(token_hash);
CREATE INDEX idx_pwd_reset_expires ON password_reset_tokens(expires_at);

COMMENT ON TABLE password_reset_tokens IS 'Password reset token tracking';

-- -----------------------------------------------------------------------------
-- Table: user_invitations
-- Purpose: Pending user invitations
-- -----------------------------------------------------------------------------
CREATE TABLE user_invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    email VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'viewer',
    department_id UUID REFERENCES organization_departments(id),
    
    -- Token
    token_hash VARCHAR(255) NOT NULL,
    
    -- Status
    expires_at TIMESTAMPTZ NOT NULL,
    accepted_at TIMESTAMPTZ,
    accepted_user_id UUID REFERENCES users(id),
    revoked_at TIMESTAMPTZ,
    
    -- Personal message
    personal_message TEXT,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID NOT NULL REFERENCES users(id),
    
    UNIQUE(organization_id, email)
);

CREATE INDEX idx_invitations_org ON user_invitations(organization_id);
CREATE INDEX idx_invitations_email ON user_invitations(email);
CREATE INDEX idx_invitations_token ON user_invitations(token_hash);

COMMENT ON TABLE user_invitations IS 'Pending user invitations to organizations';

-- ============================================================================
-- SECTION 5: PERMISSIONS & ACCESS CONTROL
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: permissions
-- Purpose: Granular permission definitions
-- -----------------------------------------------------------------------------
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,           -- e.g., 'jobs.create', 'candidates.delete'
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,               -- jobs, candidates, reports, settings
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_permissions_category ON permissions(category);
CREATE INDEX idx_permissions_code ON permissions(code);

COMMENT ON TABLE permissions IS 'Granular permission definitions';

-- -----------------------------------------------------------------------------
-- Table: role_permissions
-- Purpose: Default permissions for each role
-- -----------------------------------------------------------------------------
CREATE TABLE role_permissions (
    id SERIAL PRIMARY KEY,
    role user_role NOT NULL,
    permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    
    UNIQUE(role, permission_id)
);

CREATE INDEX idx_role_perms_role ON role_permissions(role);

COMMENT ON TABLE role_permissions IS 'Default permissions assigned to each role';

-- -----------------------------------------------------------------------------
-- Table: user_permission_overrides
-- Purpose: User-specific permission overrides
-- -----------------------------------------------------------------------------
CREATE TABLE user_permission_overrides (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    
    is_granted BOOLEAN NOT NULL,                 -- true = grant, false = deny
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(user_id, permission_id)
);

CREATE INDEX idx_user_perm_user ON user_permission_overrides(user_id);

COMMENT ON TABLE user_permission_overrides IS 'User-specific permission grants or denials';

-- ============================================================================
-- SECTION 6: AUDIT & ACTIVITY LOGGING
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: audit_logs
-- Purpose: Comprehensive audit trail for compliance
-- -----------------------------------------------------------------------------
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id),
    user_id UUID REFERENCES users(id),
    
    -- What happened
    action VARCHAR(50) NOT NULL,                 -- create, update, delete, login, export, etc.
    entity_type VARCHAR(50) NOT NULL,            -- user, candidate, job, application, etc.
    entity_id UUID,
    
    -- Details
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    
    -- Context
    ip_address INET,
    user_agent TEXT,
    request_id UUID,
    
    -- Additional metadata
    metadata JSONB DEFAULT '{}',
    
    -- Timestamp (no updated_at - logs are immutable)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Partitioning by month for performance (large table)
-- In production, implement table partitioning

CREATE INDEX idx_audit_org ON audit_logs(organization_id);
CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_org_created ON audit_logs(organization_id, created_at DESC);

COMMENT ON TABLE audit_logs IS 'Immutable audit trail for compliance and debugging';

-- -----------------------------------------------------------------------------
-- Table: activity_feed
-- Purpose: User-facing activity feed (less detailed than audit)
-- -----------------------------------------------------------------------------
CREATE TABLE activity_feed (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    
    -- What happened
    activity_type activity_type NOT NULL,
    
    -- Related entities
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    related_entity_type VARCHAR(50),
    related_entity_id UUID,
    
    -- Display
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    
    -- Visibility
    is_public BOOLEAN DEFAULT true,              -- Visible to all org users
    visible_to_user_ids UUID[],                  -- If not public, who can see
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_activity_org ON activity_feed(organization_id);
CREATE INDEX idx_activity_user ON activity_feed(user_id);
CREATE INDEX idx_activity_entity ON activity_feed(entity_type, entity_id);
CREATE INDEX idx_activity_created ON activity_feed(organization_id, created_at DESC);
CREATE INDEX idx_activity_type ON activity_feed(activity_type);

COMMENT ON TABLE activity_feed IS 'User-facing activity stream';
-- ============================================================================
-- TALENTFORGE ATS - DATABASE SCHEMA
-- Part 3: Candidates, Education, Experience, Skills, Documents
-- ============================================================================

-- ============================================================================
-- SECTION 7: CANDIDATES
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: candidates
-- Purpose: Core candidate/applicant records
-- -----------------------------------------------------------------------------
CREATE TABLE candidates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Identity
    email VARCHAR(255) NOT NULL,
    email_verified_at TIMESTAMPTZ,
    secondary_email VARCHAR(255),
    phone VARCHAR(30),
    phone_country_code VARCHAR(5),
    secondary_phone VARCHAR(30),
    
    -- Name
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    preferred_name VARCHAR(100),
    
    -- Professional
    headline VARCHAR(255),                       -- "Senior Software Engineer at Google"
    current_title VARCHAR(150),
    current_company VARCHAR(200),
    
    -- Location
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city_id INTEGER REFERENCES cities(id),
    state_province_id INTEGER REFERENCES states_provinces(id),
    country_id INTEGER REFERENCES countries(id),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50),
    
    -- Work preferences
    willing_to_relocate BOOLEAN,
    preferred_locations JSONB DEFAULT '[]',      -- Array of location preferences
    preferred_workplace_type workplace_type,
    preferred_job_types job_type[] DEFAULT '{}',
    
    -- Compensation
    current_salary_amount DECIMAL(15, 2),
    current_salary_currency_id INTEGER REFERENCES currencies(id),
    expected_salary_min DECIMAL(15, 2),
    expected_salary_max DECIMAL(15, 2),
    expected_salary_currency_id INTEGER REFERENCES currencies(id),
    salary_negotiable BOOLEAN DEFAULT true,
    
    -- Experience summary
    total_experience_years DECIMAL(4, 1),
    total_experience_months INTEGER,
    
    -- Source
    source candidate_source,
    source_details VARCHAR(255),                 -- Specific campaign, referrer name, etc.
    referrer_user_id UUID REFERENCES users(id),
    referrer_candidate_id UUID REFERENCES candidates(id),
    
    -- Social/Links
    linkedin_url VARCHAR(500),
    github_url VARCHAR(500),
    portfolio_url VARCHAR(500),
    personal_website VARCHAR(500),
    twitter_url VARCHAR(500),
    social_links JSONB DEFAULT '{}',
    
    -- Resume/Profile
    resume_url VARCHAR(500),
    resume_text TEXT,                            -- Extracted plain text
    resume_parsed_at TIMESTAMPTZ,
    resume_parsing_confidence DECIMAL(3, 2),
    profile_summary TEXT,
    
    -- Generated Portfolio
    portfolio_generated BOOLEAN DEFAULT false,
    portfolio_slug VARCHAR(100),
    portfolio_theme VARCHAR(50),
    portfolio_url VARCHAR(500),
    portfolio_views INTEGER DEFAULT 0,
    
    -- Status
    status candidate_status NOT NULL DEFAULT 'active',
    availability_date DATE,
    notice_period_days INTEGER,
    
    -- Tags and notes
    tags TEXT[] DEFAULT '{}',
    internal_notes TEXT,
    
    -- Privacy
    do_not_contact BOOLEAN DEFAULT false,
    do_not_contact_reason TEXT,
    gdpr_consent_at TIMESTAMPTZ,
    gdpr_consent_ip INET,
    marketing_consent BOOLEAN DEFAULT false,
    
    -- Matching cache (denormalized for performance)
    skills_vector VECTOR(384),                   -- For semantic search (if using pgvector)
    search_vector TSVECTOR,                      -- For full-text search
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    
    UNIQUE(organization_id, email)
);

CREATE INDEX idx_candidates_org ON candidates(organization_id);
CREATE INDEX idx_candidates_email ON candidates(email);
CREATE INDEX idx_candidates_name ON candidates(last_name, first_name);
CREATE INDEX idx_candidates_status ON candidates(organization_id, status);
CREATE INDEX idx_candidates_source ON candidates(source);
CREATE INDEX idx_candidates_location ON candidates(country_id, city_id);
CREATE INDEX idx_candidates_experience ON candidates(total_experience_years);
CREATE INDEX idx_candidates_portfolio ON candidates(portfolio_slug) WHERE portfolio_slug IS NOT NULL;
CREATE INDEX idx_candidates_search ON candidates USING gin(search_vector);
CREATE INDEX idx_candidates_tags ON candidates USING gin(tags);
CREATE INDEX idx_candidates_deleted ON candidates(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_candidates_created ON candidates(organization_id, created_at DESC);

COMMENT ON TABLE candidates IS 'Core candidate records with comprehensive profile data';

-- -----------------------------------------------------------------------------
-- Table: candidate_experience
-- Purpose: Work experience entries
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_experience (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Company
    company_name VARCHAR(200) NOT NULL,
    company_linkedin_url VARCHAR(500),
    company_website VARCHAR(500),
    company_industry_id INTEGER REFERENCES industries(id),
    company_size VARCHAR(30),
    
    -- Role
    title VARCHAR(150) NOT NULL,
    department VARCHAR(100),
    employment_type job_type,
    
    -- Location
    location_city_id INTEGER REFERENCES cities(id),
    location_country_id INTEGER REFERENCES countries(id),
    location_text VARCHAR(200),                  -- Fallback if city not matched
    is_remote BOOLEAN DEFAULT false,
    
    -- Duration
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT false,
    duration_months INTEGER,                     -- Calculated
    
    -- Details
    description TEXT,
    responsibilities TEXT,
    achievements TEXT,
    
    -- Skills used (linked separately in candidate_experience_skills)
    
    -- Verification
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    verification_method VARCHAR(50),
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_exp_candidate ON candidate_experience(candidate_id);
CREATE INDEX idx_exp_company ON candidate_experience(company_name);
CREATE INDEX idx_exp_title ON candidate_experience(title);
CREATE INDEX idx_exp_dates ON candidate_experience(start_date, end_date);
CREATE INDEX idx_exp_current ON candidate_experience(candidate_id, is_current) WHERE is_current = true;

COMMENT ON TABLE candidate_experience IS 'Work experience history for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_experience_skills
-- Purpose: Skills used in each experience entry
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_experience_skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experience_id UUID NOT NULL REFERENCES candidate_experience(id) ON DELETE CASCADE,
    skill_id INTEGER NOT NULL REFERENCES skills(id),
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(experience_id, skill_id)
);

CREATE INDEX idx_exp_skills_exp ON candidate_experience_skills(experience_id);
CREATE INDEX idx_exp_skills_skill ON candidate_experience_skills(skill_id);

COMMENT ON TABLE candidate_experience_skills IS 'Skills used in each work experience';

-- -----------------------------------------------------------------------------
-- Table: candidate_education
-- Purpose: Education history
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_education (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Institution
    institution_name VARCHAR(250) NOT NULL,
    institution_type VARCHAR(50),                -- university, college, bootcamp, online
    institution_country_id INTEGER REFERENCES countries(id),
    institution_city VARCHAR(100),
    institution_website VARCHAR(500),
    
    -- Degree
    education_level_id INTEGER REFERENCES education_levels(id),
    degree_name VARCHAR(150),                    -- Bachelor of Science, MBA, etc.
    field_of_study_id INTEGER REFERENCES fields_of_study(id),
    field_of_study_text VARCHAR(150),            -- Fallback
    major VARCHAR(150),
    minor VARCHAR(150),
    specialization VARCHAR(150),
    
    -- Duration
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT false,
    
    -- Performance
    gpa DECIMAL(4, 2),
    gpa_scale DECIMAL(4, 2) DEFAULT 4.0,
    percentage DECIMAL(5, 2),
    grade VARCHAR(20),
    honors VARCHAR(100),                         -- Cum Laude, Summa Cum Laude, etc.
    
    -- Details
    description TEXT,
    activities TEXT,
    thesis_title VARCHAR(500),
    
    -- Verification
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_edu_candidate ON candidate_education(candidate_id);
CREATE INDEX idx_edu_institution ON candidate_education(institution_name);
CREATE INDEX idx_edu_level ON candidate_education(education_level_id);
CREATE INDEX idx_edu_field ON candidate_education(field_of_study_id);
CREATE INDEX idx_edu_dates ON candidate_education(start_date, end_date);

COMMENT ON TABLE candidate_education IS 'Education history for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_skills
-- Purpose: Candidate skills with proficiency
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    skill_id INTEGER NOT NULL REFERENCES skills(id),
    
    -- Proficiency
    proficiency_level VARCHAR(20),               -- beginner, intermediate, advanced, expert
    proficiency_score INTEGER CHECK (proficiency_score BETWEEN 1 AND 10),
    years_of_experience DECIMAL(4, 1),
    
    -- Source
    source VARCHAR(30) DEFAULT 'parsed',         -- parsed, self_reported, verified, inferred
    is_primary BOOLEAN DEFAULT false,            -- Top/highlighted skill
    
    -- Last used
    last_used_date DATE,
    
    -- Verification
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    verified_by_assessment_id UUID,
    
    -- Display
    is_visible BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(candidate_id, skill_id)
);

CREATE INDEX idx_cand_skills_candidate ON candidate_skills(candidate_id);
CREATE INDEX idx_cand_skills_skill ON candidate_skills(skill_id);
CREATE INDEX idx_cand_skills_proficiency ON candidate_skills(proficiency_level);
CREATE INDEX idx_cand_skills_primary ON candidate_skills(candidate_id, is_primary) WHERE is_primary = true;

COMMENT ON TABLE candidate_skills IS 'Candidate skills with proficiency levels';

-- -----------------------------------------------------------------------------
-- Table: candidate_certifications
-- Purpose: Professional certifications
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_certifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Certification
    name VARCHAR(200) NOT NULL,
    issuing_organization VARCHAR(200) NOT NULL,
    credential_id VARCHAR(100),
    credential_url VARCHAR(500),
    
    -- Dates
    issue_date DATE,
    expiry_date DATE,
    is_permanent BOOLEAN DEFAULT false,
    
    -- Details
    description TEXT,
    
    -- Related skills
    related_skill_ids INTEGER[] DEFAULT '{}',
    
    -- Verification
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_cert_candidate ON candidate_certifications(candidate_id);
CREATE INDEX idx_cert_name ON candidate_certifications(name);
CREATE INDEX idx_cert_org ON candidate_certifications(issuing_organization);
CREATE INDEX idx_cert_expiry ON candidate_certifications(expiry_date);

COMMENT ON TABLE candidate_certifications IS 'Professional certifications and licenses';

-- -----------------------------------------------------------------------------
-- Table: candidate_languages
-- Purpose: Language proficiencies
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_languages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    language_id INTEGER NOT NULL REFERENCES languages(id),
    
    -- Proficiency (CEFR scale)
    reading_level VARCHAR(10),                   -- A1, A2, B1, B2, C1, C2, Native
    writing_level VARCHAR(10),
    speaking_level VARCHAR(10),
    listening_level VARCHAR(10),
    overall_level VARCHAR(10),
    
    is_native BOOLEAN DEFAULT false,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(candidate_id, language_id)
);

CREATE INDEX idx_cand_lang_candidate ON candidate_languages(candidate_id);
CREATE INDEX idx_cand_lang_language ON candidate_languages(language_id);

COMMENT ON TABLE candidate_languages IS 'Language proficiencies for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_projects
-- Purpose: Notable projects/portfolio items
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Project details
    name VARCHAR(200) NOT NULL,
    description TEXT,
    role VARCHAR(150),
    
    -- Links
    url VARCHAR(500),
    repository_url VARCHAR(500),
    demo_url VARCHAR(500),
    
    -- Media
    thumbnail_url VARCHAR(500),
    images JSONB DEFAULT '[]',
    
    -- Related experience
    experience_id UUID REFERENCES candidate_experience(id),
    
    -- Duration
    start_date DATE,
    end_date DATE,
    is_ongoing BOOLEAN DEFAULT false,
    
    -- Technologies
    technologies TEXT[],
    
    -- Display
    is_featured BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_projects_candidate ON candidate_projects(candidate_id);
CREATE INDEX idx_projects_featured ON candidate_projects(candidate_id, is_featured) WHERE is_featured = true;

COMMENT ON TABLE candidate_projects IS 'Portfolio projects for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_publications
-- Purpose: Publications, papers, articles
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_publications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Publication details
    title VARCHAR(500) NOT NULL,
    publication_type VARCHAR(50),                -- article, paper, book, patent, blog
    
    publisher VARCHAR(200),
    journal_name VARCHAR(200),
    
    -- Authors
    authors TEXT,
    is_primary_author BOOLEAN DEFAULT false,
    
    -- Links
    url VARCHAR(500),
    doi VARCHAR(100),
    
    -- Date
    publication_date DATE,
    
    -- Details
    abstract TEXT,
    citation_count INTEGER,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_pub_candidate ON candidate_publications(candidate_id);
CREATE INDEX idx_pub_type ON candidate_publications(publication_type);

COMMENT ON TABLE candidate_publications IS 'Publications and patents for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_awards
-- Purpose: Awards and honors
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_awards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    title VARCHAR(200) NOT NULL,
    issuer VARCHAR(200),
    date_received DATE,
    description TEXT,
    url VARCHAR(500),
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_awards_candidate ON candidate_awards(candidate_id);

COMMENT ON TABLE candidate_awards IS 'Awards and honors for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_references
-- Purpose: Professional references
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_references (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Reference person
    name VARCHAR(150) NOT NULL,
    title VARCHAR(150),
    company VARCHAR(200),
    relationship VARCHAR(100),                   -- Manager, Colleague, Client, etc.
    
    -- Contact
    email VARCHAR(255),
    phone VARCHAR(30),
    linkedin_url VARCHAR(500),
    
    -- Status
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    reference_letter_url VARCHAR(500),
    
    -- Privacy
    can_contact BOOLEAN DEFAULT true,
    contact_notes TEXT,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_refs_candidate ON candidate_references(candidate_id);

COMMENT ON TABLE candidate_references IS 'Professional references for candidates';
-- ============================================================================
-- TALENTFORGE ATS - DATABASE SCHEMA
-- Part 4: Jobs, Requirements, Pipeline Stages
-- ============================================================================

-- ============================================================================
-- SECTION 8: JOBS & REQUISITIONS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: jobs
-- Purpose: Job postings/requisitions
-- -----------------------------------------------------------------------------
CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Basic Info
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(250),
    reference_code VARCHAR(50),                  -- Internal job code (REQ-2024-001)
    
    -- Department & Location
    department_id UUID REFERENCES organization_departments(id),
    location_id UUID REFERENCES organization_locations(id),
    hiring_manager_id UUID REFERENCES users(id),
    
    -- Job Details
    job_type job_type NOT NULL DEFAULT 'full_time',
    workplace_type workplace_type NOT NULL DEFAULT 'onsite',
    experience_level experience_level,
    
    -- Description
    summary TEXT,
    description TEXT NOT NULL,
    responsibilities TEXT,
    qualifications TEXT,
    benefits TEXT,
    
    -- Requirements (denormalized for display, detailed in job_requirements)
    experience_min_years DECIMAL(4, 1),
    experience_max_years DECIMAL(4, 1),
    education_level_id INTEGER REFERENCES education_levels(id),
    
    -- Compensation
    salary_min DECIMAL(15, 2),
    salary_max DECIMAL(15, 2),
    salary_currency_id INTEGER REFERENCES currencies(id),
    salary_period VARCHAR(20) DEFAULT 'yearly',  -- hourly, monthly, yearly
    salary_visible BOOLEAN DEFAULT false,
    compensation_notes TEXT,
    
    -- Headcount
    positions_total INTEGER DEFAULT 1,
    positions_filled INTEGER DEFAULT 0,
    
    -- Location flexibility
    remote_allowed BOOLEAN DEFAULT false,
    relocation_assistance BOOLEAN DEFAULT false,
    visa_sponsorship BOOLEAN DEFAULT false,
    
    -- Status & Dates
    status job_status NOT NULL DEFAULT 'draft',
    published_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ,
    closed_reason VARCHAR(100),
    
    -- Target dates
    target_start_date DATE,
    target_fill_date DATE,
    
    -- SEO & Display
    meta_title VARCHAR(200),
    meta_description VARCHAR(500),
    
    -- Settings
    settings JSONB DEFAULT '{}',
    is_featured BOOLEAN DEFAULT false,
    is_confidential BOOLEAN DEFAULT false,
    
    -- Application settings
    application_email VARCHAR(255),
    external_apply_url VARCHAR(500),
    application_instructions TEXT,
    
    -- Scoring weights (customize per job)
    scoring_weights JSONB DEFAULT '{
        "required_skills": 0.40,
        "preferred_skills": 0.25,
        "experience": 0.20,
        "education": 0.10,
        "location": 0.05
    }',
    
    -- Statistics (denormalized)
    total_applications INTEGER DEFAULT 0,
    new_applications INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    
    -- Search
    search_vector TSVECTOR,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    
    UNIQUE(organization_id, slug),
    UNIQUE(organization_id, reference_code)
);

CREATE INDEX idx_jobs_org ON jobs(organization_id);
CREATE INDEX idx_jobs_status ON jobs(organization_id, status);
CREATE INDEX idx_jobs_dept ON jobs(department_id);
CREATE INDEX idx_jobs_location ON jobs(location_id);
CREATE INDEX idx_jobs_manager ON jobs(hiring_manager_id);
CREATE INDEX idx_jobs_type ON jobs(job_type);
CREATE INDEX idx_jobs_experience ON jobs(experience_level);
CREATE INDEX idx_jobs_published ON jobs(organization_id, published_at DESC) WHERE status = 'open';
CREATE INDEX idx_jobs_search ON jobs USING gin(search_vector);
CREATE INDEX idx_jobs_deleted ON jobs(deleted_at) WHERE deleted_at IS NULL;

COMMENT ON TABLE jobs IS 'Job postings and requisitions';

-- -----------------------------------------------------------------------------
-- Table: job_requirements
-- Purpose: Detailed job requirements (skills, certifications, etc.)
-- -----------------------------------------------------------------------------
CREATE TABLE job_requirements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    
    requirement_type VARCHAR(30) NOT NULL,       -- skill, certification, education, language, other
    
    -- For skills
    skill_id INTEGER REFERENCES skills(id),
    skill_name_override VARCHAR(150),            -- If skill not in taxonomy
    
    -- For education
    education_level_id INTEGER REFERENCES education_levels(id),
    field_of_study_id INTEGER REFERENCES fields_of_study(id),
    
    -- For languages
    language_id INTEGER REFERENCES languages(id),
    language_level VARCHAR(10),
    
    -- For certifications
    certification_name VARCHAR(200),
    
    -- Generic
    description TEXT,
    
    -- Priority
    is_required BOOLEAN NOT NULL DEFAULT true,   -- Required vs Preferred
    priority INTEGER DEFAULT 0,                  -- For weighting
    
    -- Experience with this requirement
    min_years DECIMAL(4, 1),
    max_years DECIMAL(4, 1),
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_job_req_job ON job_requirements(job_id);
CREATE INDEX idx_job_req_type ON job_requirements(requirement_type);
CREATE INDEX idx_job_req_skill ON job_requirements(skill_id);
CREATE INDEX idx_job_req_required ON job_requirements(job_id, is_required);

COMMENT ON TABLE job_requirements IS 'Detailed job requirements for matching';

-- -----------------------------------------------------------------------------
-- Table: job_questions
-- Purpose: Screening questions for job applications
-- -----------------------------------------------------------------------------
CREATE TABLE job_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    
    question_text TEXT NOT NULL,
    question_type VARCHAR(30) NOT NULL,          -- text, textarea, single_choice, multi_choice, number, date, file
    
    -- Options (for choice questions)
    options JSONB DEFAULT '[]',                  -- [{value: 'yes', label: 'Yes', score: 10}, ...]
    
    -- Validation
    is_required BOOLEAN DEFAULT true,
    min_value INTEGER,
    max_value INTEGER,
    min_length INTEGER,
    max_length INTEGER,
    
    -- Scoring
    has_scoring BOOLEAN DEFAULT false,
    knockout_answer VARCHAR(255),                -- Auto-reject if this answer
    ideal_answer VARCHAR(255),
    max_score INTEGER DEFAULT 0,
    
    -- Display
    placeholder TEXT,
    help_text TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_job_questions_job ON job_questions(job_id);
CREATE INDEX idx_job_questions_order ON job_questions(job_id, sort_order);

COMMENT ON TABLE job_questions IS 'Screening questions for job applications';

-- -----------------------------------------------------------------------------
-- Table: job_team_members
-- Purpose: Hiring team for a job
-- -----------------------------------------------------------------------------
CREATE TABLE job_team_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    role VARCHAR(50) NOT NULL,                   -- recruiter, hiring_manager, interviewer, coordinator
    
    -- Permissions for this job
    can_view_applications BOOLEAN DEFAULT true,
    can_review_candidates BOOLEAN DEFAULT true,
    can_schedule_interviews BOOLEAN DEFAULT false,
    can_make_offers BOOLEAN DEFAULT false,
    can_edit_job BOOLEAN DEFAULT false,
    
    -- Notification preferences
    notify_new_applications BOOLEAN DEFAULT true,
    notify_stage_changes BOOLEAN DEFAULT true,
    notify_comments BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(job_id, user_id)
);

CREATE INDEX idx_job_team_job ON job_team_members(job_id);
CREATE INDEX idx_job_team_user ON job_team_members(user_id);
CREATE INDEX idx_job_team_role ON job_team_members(role);

COMMENT ON TABLE job_team_members IS 'Hiring team members assigned to jobs';

-- ============================================================================
-- SECTION 9: PIPELINE STAGES
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: pipeline_templates
-- Purpose: Reusable pipeline stage templates
-- -----------------------------------------------------------------------------
CREATE TABLE pipeline_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT false,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    
    UNIQUE(organization_id, name)
);

CREATE INDEX idx_pipeline_tmpl_org ON pipeline_templates(organization_id);

COMMENT ON TABLE pipeline_templates IS 'Reusable pipeline templates';

-- -----------------------------------------------------------------------------
-- Table: pipeline_template_stages
-- Purpose: Stages within pipeline templates
-- -----------------------------------------------------------------------------
CREATE TABLE pipeline_template_stages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id UUID NOT NULL REFERENCES pipeline_templates(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    stage_type VARCHAR(30) NOT NULL,             -- application, screening, interview, offer, hired, rejected
    color VARCHAR(7),
    
    -- Behavior
    is_terminal BOOLEAN DEFAULT false,           -- End states (hired, rejected)
    is_rejection BOOLEAN DEFAULT false,
    auto_email_template_id UUID,
    
    -- SLA
    target_days INTEGER,                         -- Target time in this stage
    
    -- Display
    sort_order INTEGER NOT NULL,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_pipeline_stages_template ON pipeline_template_stages(template_id);
CREATE INDEX idx_pipeline_stages_order ON pipeline_template_stages(template_id, sort_order);

COMMENT ON TABLE pipeline_template_stages IS 'Stages within pipeline templates';

-- -----------------------------------------------------------------------------
-- Table: job_pipeline_stages
-- Purpose: Pipeline stages for a specific job
-- -----------------------------------------------------------------------------
CREATE TABLE job_pipeline_stages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    stage_type VARCHAR(30) NOT NULL,
    color VARCHAR(7),
    
    -- Behavior
    is_terminal BOOLEAN DEFAULT false,
    is_rejection BOOLEAN DEFAULT false,
    auto_email_template_id UUID,
    
    -- Actions on enter
    on_enter_actions JSONB DEFAULT '[]',         -- Automated actions when entering stage
    
    -- SLA
    target_days INTEGER,
    
    -- Statistics (denormalized)
    candidate_count INTEGER DEFAULT 0,
    
    -- Display
    sort_order INTEGER NOT NULL,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_job_stages_job ON job_pipeline_stages(job_id);
CREATE INDEX idx_job_stages_order ON job_pipeline_stages(job_id, sort_order);
CREATE INDEX idx_job_stages_type ON job_pipeline_stages(stage_type);

COMMENT ON TABLE job_pipeline_stages IS 'Pipeline stages for specific jobs';

-- ============================================================================
-- SECTION 10: JOB POSTINGS & DISTRIBUTION
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: job_boards
-- Purpose: Available job boards for posting
-- -----------------------------------------------------------------------------
CREATE TABLE job_boards (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE,
    website VARCHAR(255),
    logo_url VARCHAR(500),
    
    -- API details
    api_available BOOLEAN DEFAULT false,
    api_documentation_url VARCHAR(500),
    
    -- Supported features
    supports_apply BOOLEAN DEFAULT false,
    supports_screening_questions BOOLEAN DEFAULT false,
    
    -- Geographic coverage
    countries INTEGER[] DEFAULT '{}',            -- Country IDs
    
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE job_boards IS 'Available job boards for posting';

-- -----------------------------------------------------------------------------
-- Table: job_postings
-- Purpose: Job posts to external boards
-- -----------------------------------------------------------------------------
CREATE TABLE job_postings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    job_board_id INTEGER NOT NULL REFERENCES job_boards(id),
    
    -- External reference
    external_id VARCHAR(255),
    external_url VARCHAR(500),
    
    -- Status
    status VARCHAR(30) NOT NULL DEFAULT 'draft', -- draft, pending, active, paused, expired, removed
    
    -- Dates
    posted_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    removed_at TIMESTAMPTZ,
    
    -- Cost
    cost_amount DECIMAL(10, 2),
    cost_currency_id INTEGER REFERENCES currencies(id),
    is_sponsored BOOLEAN DEFAULT false,
    
    -- Statistics
    views INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    applications INTEGER DEFAULT 0,
    
    -- Errors
    last_error TEXT,
    last_error_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_job_postings_job ON job_postings(job_id);
CREATE INDEX idx_job_postings_board ON job_postings(job_board_id);
CREATE INDEX idx_job_postings_status ON job_postings(status);
CREATE INDEX idx_job_postings_external ON job_postings(job_board_id, external_id);

COMMENT ON TABLE job_postings IS 'Job distribution to external boards';
-- ============================================================================
-- TALENTFORGE ATS - DATABASE SCHEMA
-- Part 5: Applications, Scoring, Interviews, Offers
-- ============================================================================

-- ============================================================================
-- SECTION 11: APPLICATIONS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: applications
-- Purpose: Candidate applications to jobs
-- -----------------------------------------------------------------------------
CREATE TABLE applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Current stage
    current_stage_id UUID REFERENCES job_pipeline_stages(id),
    status application_status NOT NULL DEFAULT 'new',
    
    -- Source
    source candidate_source,
    source_details VARCHAR(255),
    referrer_user_id UUID REFERENCES users(id),
    job_posting_id UUID REFERENCES job_postings(id),
    
    -- Resume used
    resume_url VARCHAR(500),
    resume_version INTEGER DEFAULT 1,
    cover_letter TEXT,
    
    -- Scores (denormalized for performance)
    overall_score DECIMAL(5, 2),
    required_skills_score DECIMAL(5, 2),
    preferred_skills_score DECIMAL(5, 2),
    experience_score DECIMAL(5, 2),
    education_score DECIMAL(5, 2),
    location_score DECIMAL(5, 2),
    screening_score DECIMAL(5, 2),
    interview_score DECIMAL(5, 2),
    
    -- Detailed score breakdown (JSONB for flexibility)
    score_breakdown JSONB DEFAULT '{}',
    
    -- AI Analysis
    ai_summary TEXT,
    ai_strengths TEXT[],
    ai_concerns TEXT[],
    ai_recommendation VARCHAR(30),               -- strong_yes, yes, maybe, no, strong_no
    
    -- Recruiter evaluation
    recruiter_rating INTEGER CHECK (recruiter_rating BETWEEN 1 AND 5),
    recruiter_notes TEXT,
    
    -- Dates
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_activity_at TIMESTAMPTZ DEFAULT NOW(),
    moved_to_stage_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Outcome
    outcome VARCHAR(30),                         -- hired, rejected, withdrawn, offer_declined
    outcome_at TIMESTAMPTZ,
    outcome_reason VARCHAR(255),
    rejection_reason_id UUID,
    
    -- Flags
    is_starred BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false,
    is_duplicate BOOLEAN DEFAULT false,
    duplicate_of_id UUID REFERENCES applications(id),
    
    -- Tags
    tags TEXT[] DEFAULT '{}',
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    
    UNIQUE(job_id, candidate_id)
);

CREATE INDEX idx_applications_org ON applications(organization_id);
CREATE INDEX idx_applications_job ON applications(job_id);
CREATE INDEX idx_applications_candidate ON applications(candidate_id);
CREATE INDEX idx_applications_stage ON applications(current_stage_id);
CREATE INDEX idx_applications_status ON applications(status);
CREATE INDEX idx_applications_score ON applications(job_id, overall_score DESC);
CREATE INDEX idx_applications_applied ON applications(job_id, applied_at DESC);
CREATE INDEX idx_applications_starred ON applications(job_id, is_starred) WHERE is_starred = true;
CREATE INDEX idx_applications_outcome ON applications(outcome);
CREATE INDEX idx_applications_deleted ON applications(deleted_at) WHERE deleted_at IS NULL;

COMMENT ON TABLE applications IS 'Job applications linking candidates to jobs';

-- -----------------------------------------------------------------------------
-- Table: application_stage_history
-- Purpose: Track stage transitions
-- -----------------------------------------------------------------------------
CREATE TABLE application_stage_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    
    from_stage_id UUID REFERENCES job_pipeline_stages(id),
    to_stage_id UUID NOT NULL REFERENCES job_pipeline_stages(id),
    
    -- Duration in previous stage
    duration_seconds INTEGER,
    
    -- Who moved and why
    moved_by_user_id UUID REFERENCES users(id),
    reason TEXT,
    notes TEXT,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_stage_history_app ON application_stage_history(application_id);
CREATE INDEX idx_stage_history_to ON application_stage_history(to_stage_id);
CREATE INDEX idx_stage_history_created ON application_stage_history(application_id, created_at);

COMMENT ON TABLE application_stage_history IS 'Application stage transition history';

-- -----------------------------------------------------------------------------
-- Table: application_answers
-- Purpose: Answers to screening questions
-- -----------------------------------------------------------------------------
CREATE TABLE application_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES job_questions(id) ON DELETE CASCADE,
    
    -- Answer
    answer_text TEXT,
    answer_value VARCHAR(255),                   -- For choice questions
    answer_values TEXT[],                        -- For multi-choice
    answer_number DECIMAL(15, 2),
    answer_date DATE,
    answer_file_url VARCHAR(500),
    
    -- Scoring
    score INTEGER DEFAULT 0,
    is_knockout BOOLEAN DEFAULT false,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(application_id, question_id)
);

CREATE INDEX idx_app_answers_app ON application_answers(application_id);
CREATE INDEX idx_app_answers_question ON application_answers(question_id);

COMMENT ON TABLE application_answers IS 'Screening question answers';

-- -----------------------------------------------------------------------------
-- Table: application_skill_matches
-- Purpose: Detailed skill matching results
-- -----------------------------------------------------------------------------
CREATE TABLE application_skill_matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    job_requirement_id UUID NOT NULL REFERENCES job_requirements(id) ON DELETE CASCADE,
    candidate_skill_id UUID REFERENCES candidate_skills(id),
    
    -- Match details
    is_matched BOOLEAN NOT NULL DEFAULT false,
    match_type VARCHAR(30),                      -- exact, synonym, related, partial
    match_confidence DECIMAL(3, 2),              -- 0.0 to 1.0
    
    -- Experience comparison
    required_years DECIMAL(4, 1),
    candidate_years DECIMAL(4, 1),
    years_match BOOLEAN,
    
    -- Score contribution
    score_contribution DECIMAL(5, 2),
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(application_id, job_requirement_id)
);

CREATE INDEX idx_skill_match_app ON application_skill_matches(application_id);
CREATE INDEX idx_skill_match_req ON application_skill_matches(job_requirement_id);
CREATE INDEX idx_skill_match_matched ON application_skill_matches(application_id, is_matched);

COMMENT ON TABLE application_skill_matches IS 'Detailed skill matching analysis';

-- ============================================================================
-- SECTION 12: INTERVIEWS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: interview_types
-- Purpose: Types of interviews (Phone, Technical, etc.)
-- -----------------------------------------------------------------------------
CREATE TABLE interview_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    default_duration_minutes INTEGER DEFAULT 60,
    
    -- Instructions
    interviewer_instructions TEXT,
    candidate_instructions TEXT,
    
    -- Settings
    requires_scorecard BOOLEAN DEFAULT true,
    scorecard_template_id UUID,
    
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(organization_id, name)
);

CREATE INDEX idx_interview_types_org ON interview_types(organization_id);

COMMENT ON TABLE interview_types IS 'Interview type definitions';

-- -----------------------------------------------------------------------------
-- Table: interviews
-- Purpose: Scheduled interviews
-- -----------------------------------------------------------------------------
CREATE TABLE interviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    interview_type_id UUID REFERENCES interview_types(id),
    
    -- Scheduling
    scheduled_at TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER NOT NULL DEFAULT 60,
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    
    -- Location
    location_type VARCHAR(30) NOT NULL,          -- in_person, phone, video
    location_details TEXT,
    
    -- Video conferencing
    video_platform VARCHAR(30),                  -- zoom, teams, meet, other
    video_link VARCHAR(500),
    video_meeting_id VARCHAR(100),
    video_password VARCHAR(50),
    
    -- Phone
    phone_number VARCHAR(30),
    
    -- In-person
    address TEXT,
    room VARCHAR(100),
    
    -- Status
    status VARCHAR(30) NOT NULL DEFAULT 'scheduled', -- scheduled, confirmed, completed, cancelled, no_show
    
    -- Calendar
    calendar_event_id VARCHAR(255),
    calendar_provider VARCHAR(30),
    
    -- Candidate
    candidate_confirmed_at TIMESTAMPTZ,
    candidate_reminder_sent_at TIMESTAMPTZ,
    
    -- Completion
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    actual_duration_minutes INTEGER,
    
    -- Cancellation
    cancelled_at TIMESTAMPTZ,
    cancelled_by_user_id UUID REFERENCES users(id),
    cancellation_reason TEXT,
    
    -- Notes
    internal_notes TEXT,
    candidate_notes TEXT,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_interviews_app ON interviews(application_id);
CREATE INDEX idx_interviews_type ON interviews(interview_type_id);
CREATE INDEX idx_interviews_scheduled ON interviews(scheduled_at);
CREATE INDEX idx_interviews_status ON interviews(status);

COMMENT ON TABLE interviews IS 'Scheduled interview sessions';

-- -----------------------------------------------------------------------------
-- Table: interview_participants
-- Purpose: Interviewers for each interview
-- -----------------------------------------------------------------------------
CREATE TABLE interview_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    interview_id UUID NOT NULL REFERENCES interviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    role VARCHAR(30) NOT NULL DEFAULT 'interviewer', -- interviewer, lead, observer, coordinator
    
    -- Status
    status VARCHAR(30) DEFAULT 'pending',        -- pending, accepted, declined, tentative
    response_at TIMESTAMPTZ,
    decline_reason TEXT,
    
    -- Attendance
    attended BOOLEAN,
    
    -- Feedback
    feedback_submitted_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    
    UNIQUE(interview_id, user_id)
);

CREATE INDEX idx_interview_part_interview ON interview_participants(interview_id);
CREATE INDEX idx_interview_part_user ON interview_participants(user_id);

COMMENT ON TABLE interview_participants IS 'Interviewers assigned to interviews';

-- -----------------------------------------------------------------------------
-- Table: scorecard_templates
-- Purpose: Interview scorecard templates
-- -----------------------------------------------------------------------------
CREATE TABLE scorecard_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(organization_id, name)
);

CREATE INDEX idx_scorecard_tmpl_org ON scorecard_templates(organization_id);

COMMENT ON TABLE scorecard_templates IS 'Interview scorecard templates';

-- -----------------------------------------------------------------------------
-- Table: scorecard_criteria
-- Purpose: Criteria within scorecard templates
-- -----------------------------------------------------------------------------
CREATE TABLE scorecard_criteria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id UUID NOT NULL REFERENCES scorecard_templates(id) ON DELETE CASCADE,
    
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category VARCHAR(50),                        -- technical, behavioral, communication, culture_fit
    
    -- Scoring
    score_type VARCHAR(20) DEFAULT 'rating',     -- rating, yes_no, text
    min_score INTEGER DEFAULT 1,
    max_score INTEGER DEFAULT 5,
    weight DECIMAL(3, 2) DEFAULT 1.0,
    
    -- Options (for custom scales)
    score_labels JSONB DEFAULT '{}',             -- {1: "Poor", 2: "Fair", ...}
    
    -- Required
    is_required BOOLEAN DEFAULT true,
    
    sort_order INTEGER NOT NULL DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_scorecard_criteria_template ON scorecard_criteria(template_id);

COMMENT ON TABLE scorecard_criteria IS 'Criteria within scorecard templates';

-- -----------------------------------------------------------------------------
-- Table: interview_feedback
-- Purpose: Interviewer feedback/scorecards
-- -----------------------------------------------------------------------------
CREATE TABLE interview_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    interview_id UUID NOT NULL REFERENCES interviews(id) ON DELETE CASCADE,
    participant_id UUID NOT NULL REFERENCES interview_participants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Template used
    scorecard_template_id UUID REFERENCES scorecard_templates(id),
    
    -- Overall assessment
    overall_score INTEGER CHECK (overall_score BETWEEN 1 AND 5),
    recommendation VARCHAR(30),                  -- strong_yes, yes, maybe, no, strong_no
    
    -- Summary
    strengths TEXT,
    concerns TEXT,
    summary TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft',          -- draft, submitted
    submitted_at TIMESTAMPTZ,
    
    -- Private notes (not shared with hiring team)
    private_notes TEXT,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(interview_id, user_id)
);

CREATE INDEX idx_feedback_interview ON interview_feedback(interview_id);
CREATE INDEX idx_feedback_user ON interview_feedback(user_id);
CREATE INDEX idx_feedback_participant ON interview_feedback(participant_id);

COMMENT ON TABLE interview_feedback IS 'Interviewer feedback and scorecards';

-- -----------------------------------------------------------------------------
-- Table: interview_feedback_scores
-- Purpose: Individual criterion scores
-- -----------------------------------------------------------------------------
CREATE TABLE interview_feedback_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    feedback_id UUID NOT NULL REFERENCES interview_feedback(id) ON DELETE CASCADE,
    criterion_id UUID NOT NULL REFERENCES scorecard_criteria(id),
    
    score INTEGER,
    notes TEXT,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(feedback_id, criterion_id)
);

CREATE INDEX idx_feedback_scores_feedback ON interview_feedback_scores(feedback_id);

COMMENT ON TABLE interview_feedback_scores IS 'Individual criterion scores in feedback';

-- ============================================================================
-- SECTION 13: OFFERS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: rejection_reasons
-- Purpose: Standard rejection reasons
-- -----------------------------------------------------------------------------
CREATE TABLE rejection_reasons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category VARCHAR(50),                        -- qualifications, experience, culture_fit, compensation, other
    
    -- Template
    email_template_id UUID,
    
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_rejection_reasons_org ON rejection_reasons(organization_id);

COMMENT ON TABLE rejection_reasons IS 'Standard rejection reasons';

-- -----------------------------------------------------------------------------
-- Table: offers
-- Purpose: Job offers to candidates
-- -----------------------------------------------------------------------------
CREATE TABLE offers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    
    -- Offer details
    title VARCHAR(200) NOT NULL,
    department_id UUID REFERENCES organization_departments(id),
    location_id UUID REFERENCES organization_locations(id),
    reports_to_user_id UUID REFERENCES users(id),
    
    -- Compensation
    base_salary DECIMAL(15, 2) NOT NULL,
    salary_currency_id INTEGER NOT NULL REFERENCES currencies(id),
    salary_period VARCHAR(20) DEFAULT 'yearly',
    
    -- Variable compensation
    bonus_amount DECIMAL(15, 2),
    bonus_type VARCHAR(30),                      -- signing, annual, performance
    commission_structure TEXT,
    
    -- Equity
    equity_shares INTEGER,
    equity_type VARCHAR(30),                     -- options, rsu, espp
    equity_vesting_schedule TEXT,
    
    -- Benefits
    benefits_summary TEXT,
    benefits_details JSONB DEFAULT '{}',
    
    -- Dates
    start_date DATE NOT NULL,
    offer_expiry_date DATE,
    
    -- Documents
    offer_letter_url VARCHAR(500),
    offer_letter_generated_at TIMESTAMPTZ,
    signed_offer_url VARCHAR(500),
    
    -- Status
    status VARCHAR(30) NOT NULL DEFAULT 'draft', -- draft, pending_approval, approved, sent, viewed, accepted, declined, expired, withdrawn
    
    -- Approvals
    requires_approval BOOLEAN DEFAULT true,
    approved_at TIMESTAMPTZ,
    approved_by_user_id UUID REFERENCES users(id),
    
    -- Sent
    sent_at TIMESTAMPTZ,
    sent_by_user_id UUID REFERENCES users(id),
    viewed_at TIMESTAMPTZ,
    
    -- Response
    responded_at TIMESTAMPTZ,
    response VARCHAR(20),                        -- accepted, declined, negotiating
    decline_reason TEXT,
    
    -- Negotiation
    negotiation_notes TEXT,
    revised_from_offer_id UUID REFERENCES offers(id),
    revision_number INTEGER DEFAULT 1,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_offers_app ON offers(application_id);
CREATE INDEX idx_offers_status ON offers(status);
CREATE INDEX idx_offers_start ON offers(start_date);

COMMENT ON TABLE offers IS 'Job offers to candidates';

-- -----------------------------------------------------------------------------
-- Table: offer_approvers
-- Purpose: Approval workflow for offers
-- -----------------------------------------------------------------------------
CREATE TABLE offer_approvers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    offer_id UUID NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    
    approval_order INTEGER NOT NULL DEFAULT 1,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending',        -- pending, approved, rejected
    responded_at TIMESTAMPTZ,
    notes TEXT,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(offer_id, user_id)
);

CREATE INDEX idx_offer_approvers_offer ON offer_approvers(offer_id);
CREATE INDEX idx_offer_approvers_user ON offer_approvers(user_id);

COMMENT ON TABLE offer_approvers IS 'Offer approval workflow';
-- ============================================================================
-- TALENTFORGE ATS - DATABASE SCHEMA
-- Part 6: Communications, Documents, Notes, Tags
-- ============================================================================

-- ============================================================================
-- SECTION 14: COMMUNICATIONS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: email_templates
-- Purpose: Reusable email templates
-- -----------------------------------------------------------------------------
CREATE TABLE email_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category VARCHAR(50),                        -- application, interview, offer, rejection, general
    
    -- Content
    subject VARCHAR(500) NOT NULL,
    body_html TEXT NOT NULL,
    body_text TEXT,
    
    -- Merge fields used
    merge_fields TEXT[] DEFAULT '{}',
    
    -- Attachments
    default_attachments JSONB DEFAULT '[]',
    
    -- Settings
    is_system BOOLEAN DEFAULT false,             -- System templates can't be deleted
    is_active BOOLEAN DEFAULT true,
    
    -- Usage tracking
    usage_count INTEGER DEFAULT 0,
    last_used_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    
    UNIQUE(organization_id, name)
);

CREATE INDEX idx_email_tmpl_org ON email_templates(organization_id);
CREATE INDEX idx_email_tmpl_category ON email_templates(category);

COMMENT ON TABLE email_templates IS 'Reusable email templates with merge fields';

-- -----------------------------------------------------------------------------
-- Table: communications
-- Purpose: All communications with candidates
-- -----------------------------------------------------------------------------
CREATE TABLE communications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    application_id UUID REFERENCES applications(id),
    
    -- Type
    communication_type communication_type NOT NULL,
    direction communication_direction NOT NULL,
    
    -- Participants
    from_user_id UUID REFERENCES users(id),
    from_address VARCHAR(255),
    to_addresses TEXT[] NOT NULL,
    cc_addresses TEXT[] DEFAULT '{}',
    bcc_addresses TEXT[] DEFAULT '{}',
    
    -- Content
    subject VARCHAR(500),
    body_html TEXT,
    body_text TEXT,
    
    -- Template
    template_id UUID REFERENCES email_templates(id),
    
    -- Status
    status communication_status NOT NULL DEFAULT 'pending',
    
    -- Delivery tracking
    scheduled_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    opened_at TIMESTAMPTZ,
    clicked_at TIMESTAMPTZ,
    bounced_at TIMESTAMPTZ,
    
    -- Tracking details
    open_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    clicked_links JSONB DEFAULT '[]',
    
    -- External references
    external_message_id VARCHAR(255),            -- SendGrid message ID, etc.
    thread_id VARCHAR(255),
    in_reply_to_id UUID REFERENCES communications(id),
    
    -- Error handling
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_comms_org ON communications(organization_id);
CREATE INDEX idx_comms_candidate ON communications(candidate_id);
CREATE INDEX idx_comms_application ON communications(application_id);
CREATE INDEX idx_comms_type ON communications(communication_type);
CREATE INDEX idx_comms_status ON communications(status);
CREATE INDEX idx_comms_created ON communications(organization_id, created_at DESC);
CREATE INDEX idx_comms_thread ON communications(thread_id);
CREATE INDEX idx_comms_external ON communications(external_message_id);

COMMENT ON TABLE communications IS 'All communications with candidates';

-- -----------------------------------------------------------------------------
-- Table: communication_attachments
-- Purpose: Attachments on communications
-- -----------------------------------------------------------------------------
CREATE TABLE communication_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    communication_id UUID NOT NULL REFERENCES communications(id) ON DELETE CASCADE,
    
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_comm_attach_comm ON communication_attachments(communication_id);

COMMENT ON TABLE communication_attachments IS 'Attachments on communications';

-- ============================================================================
-- SECTION 15: DOCUMENTS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: document_types
-- Purpose: Types of documents
-- -----------------------------------------------------------------------------
CREATE TABLE document_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),                        -- resume, cover_letter, portfolio, id, education, employment, other
    allowed_extensions TEXT[] DEFAULT '{}',
    max_size_mb INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE document_types IS 'Document type definitions';

-- -----------------------------------------------------------------------------
-- Table: documents
-- Purpose: Candidate and application documents
-- -----------------------------------------------------------------------------
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    candidate_id UUID REFERENCES candidates(id) ON DELETE CASCADE,
    application_id UUID REFERENCES applications(id),
    
    -- Type
    document_type_id INTEGER REFERENCES document_types(id),
    
    -- File info
    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_size INTEGER NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_extension VARCHAR(10),
    
    -- Metadata
    title VARCHAR(255),
    description TEXT,
    
    -- Processing
    is_parsed BOOLEAN DEFAULT false,
    parsed_at TIMESTAMPTZ,
    parsed_text TEXT,
    parsing_confidence DECIMAL(3, 2),
    
    -- Version control
    version INTEGER DEFAULT 1,
    previous_version_id UUID REFERENCES documents(id),
    is_current BOOLEAN DEFAULT true,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active',         -- active, archived, deleted
    
    -- Security
    is_confidential BOOLEAN DEFAULT false,
    access_level VARCHAR(20) DEFAULT 'team',     -- team, hiring_manager_only, admin_only
    
    -- Expiry
    expires_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

CREATE INDEX idx_docs_org ON documents(organization_id);
CREATE INDEX idx_docs_candidate ON documents(candidate_id);
CREATE INDEX idx_docs_application ON documents(application_id);
CREATE INDEX idx_docs_type ON documents(document_type_id);
CREATE INDEX idx_docs_status ON documents(status);

COMMENT ON TABLE documents IS 'All documents (resumes, portfolios, etc.)';

-- ============================================================================
-- SECTION 16: NOTES & COMMENTS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: notes
-- Purpose: Notes on candidates and applications
-- -----------------------------------------------------------------------------
CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Related entity
    entity_type VARCHAR(30) NOT NULL,            -- candidate, application, job, interview
    entity_id UUID NOT NULL,
    
    -- Parent note (for replies)
    parent_id UUID REFERENCES notes(id),
    
    -- Content
    content TEXT NOT NULL,
    content_html TEXT,
    
    -- Mentions
    mentioned_user_ids UUID[] DEFAULT '{}',
    
    -- Type
    note_type VARCHAR(30) DEFAULT 'general',     -- general, feedback, action_item, follow_up
    
    -- Priority
    is_pinned BOOLEAN DEFAULT false,
    
    -- Visibility
    is_private BOOLEAN DEFAULT false,            -- Only visible to author
    visibility VARCHAR(20) DEFAULT 'team',       -- team, hiring_team, private
    
    -- Action items
    is_action_item BOOLEAN DEFAULT false,
    action_due_date TIMESTAMPTZ,
    action_assigned_to_id UUID REFERENCES users(id),
    action_completed_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

CREATE INDEX idx_notes_org ON notes(organization_id);
CREATE INDEX idx_notes_entity ON notes(entity_type, entity_id);
CREATE INDEX idx_notes_parent ON notes(parent_id);
CREATE INDEX idx_notes_author ON notes(created_by);
CREATE INDEX idx_notes_pinned ON notes(entity_type, entity_id, is_pinned) WHERE is_pinned = true;
CREATE INDEX idx_notes_action ON notes(action_assigned_to_id, action_completed_at) WHERE is_action_item = true;

COMMENT ON TABLE notes IS 'Notes and comments on various entities';

-- -----------------------------------------------------------------------------
-- Table: note_reactions
-- Purpose: Reactions/likes on notes
-- -----------------------------------------------------------------------------
CREATE TABLE note_reactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    note_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    reaction VARCHAR(20) NOT NULL,               -- like, thumbs_up, etc.
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(note_id, user_id, reaction)
);

CREATE INDEX idx_note_reactions_note ON note_reactions(note_id);

COMMENT ON TABLE note_reactions IS 'Reactions on notes';

-- ============================================================================
-- SECTION 17: TAGS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: tags
-- Purpose: Organization-wide tags
-- -----------------------------------------------------------------------------
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(7),
    
    -- Scope
    entity_types TEXT[] DEFAULT '{}',            -- Which entities can use this tag
    
    -- Usage
    usage_count INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(organization_id, slug)
);

CREATE INDEX idx_tags_org ON tags(organization_id);
CREATE INDEX idx_tags_name ON tags USING gin(name gin_trgm_ops);

COMMENT ON TABLE tags IS 'Organization-wide tags for categorization';

-- -----------------------------------------------------------------------------
-- Table: entity_tags
-- Purpose: Tag assignments to entities
-- -----------------------------------------------------------------------------
CREATE TABLE entity_tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    
    entity_type VARCHAR(30) NOT NULL,
    entity_id UUID NOT NULL,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    
    UNIQUE(tag_id, entity_type, entity_id)
);

CREATE INDEX idx_entity_tags_tag ON entity_tags(tag_id);
CREATE INDEX idx_entity_tags_entity ON entity_tags(entity_type, entity_id);

COMMENT ON TABLE entity_tags IS 'Tag assignments to various entities';

-- ============================================================================
-- SECTION 18: SAVED SEARCHES & VIEWS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: saved_searches
-- Purpose: Saved search queries
-- -----------------------------------------------------------------------------
CREATE TABLE saved_searches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    name VARCHAR(150) NOT NULL,
    description TEXT,
    
    -- Search parameters
    entity_type VARCHAR(30) NOT NULL,            -- candidate, job, application
    filters JSONB NOT NULL DEFAULT '{}',
    sort_field VARCHAR(50),
    sort_direction VARCHAR(4) DEFAULT 'desc',
    
    -- Display
    columns JSONB DEFAULT '[]',
    
    -- Sharing
    is_shared BOOLEAN DEFAULT false,
    shared_with_user_ids UUID[] DEFAULT '{}',
    
    -- Usage
    last_used_at TIMESTAMPTZ,
    usage_count INTEGER DEFAULT 0,
    
    -- Alerts
    has_alerts BOOLEAN DEFAULT false,
    alert_frequency VARCHAR(20),                 -- daily, weekly, immediately
    last_alert_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_saved_search_org ON saved_searches(organization_id);
CREATE INDEX idx_saved_search_user ON saved_searches(user_id);
CREATE INDEX idx_saved_search_entity ON saved_searches(entity_type);

COMMENT ON TABLE saved_searches IS 'Saved search queries and filters';

-- -----------------------------------------------------------------------------
-- Table: candidate_lists
-- Purpose: Custom candidate lists/pools
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_lists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    name VARCHAR(150) NOT NULL,
    description TEXT,
    list_type VARCHAR(30) DEFAULT 'manual',      -- manual, smart (auto-populated)
    
    -- For smart lists
    smart_filters JSONB DEFAULT '{}',
    
    -- Sharing
    is_shared BOOLEAN DEFAULT false,
    owner_user_id UUID NOT NULL REFERENCES users(id),
    
    -- Statistics
    candidate_count INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID
);

CREATE INDEX idx_cand_lists_org ON candidate_lists(organization_id);
CREATE INDEX idx_cand_lists_owner ON candidate_lists(owner_user_id);

COMMENT ON TABLE candidate_lists IS 'Custom candidate pools and lists';

-- -----------------------------------------------------------------------------
-- Table: candidate_list_members
-- Purpose: Candidates in lists
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_list_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    list_id UUID NOT NULL REFERENCES candidate_lists(id) ON DELETE CASCADE,
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    notes TEXT,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    
    UNIQUE(list_id, candidate_id)
);

CREATE INDEX idx_list_members_list ON candidate_list_members(list_id);
CREATE INDEX idx_list_members_candidate ON candidate_list_members(candidate_id);

COMMENT ON TABLE candidate_list_members IS 'Candidates assigned to lists';
-- ============================================================================
-- TALENTFORGE ATS - DATABASE SCHEMA
-- Part 7: Integrations, Webhooks, Analytics, Billing
-- ============================================================================

-- ============================================================================
-- SECTION 19: INTEGRATIONS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: integration_providers
-- Purpose: Available integration providers
-- -----------------------------------------------------------------------------
CREATE TABLE integration_providers (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,               -- calendar, job_board, hris, assessment, communication
    
    -- Display
    logo_url VARCHAR(500),
    website_url VARCHAR(500),
    documentation_url VARCHAR(500),
    
    -- OAuth
    oauth_authorize_url VARCHAR(500),
    oauth_token_url VARCHAR(500),
    oauth_scopes TEXT[],
    
    -- Settings schema
    settings_schema JSONB DEFAULT '{}',
    
    -- Availability
    is_active BOOLEAN DEFAULT true,
    is_beta BOOLEAN DEFAULT false,
    required_tier subscription_tier,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_int_providers_category ON integration_providers(category);

COMMENT ON TABLE integration_providers IS 'Available third-party integration providers';

-- -----------------------------------------------------------------------------
-- Table: organization_integrations
-- Purpose: Organization's active integrations
-- -----------------------------------------------------------------------------
CREATE TABLE organization_integrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    provider_id INTEGER NOT NULL REFERENCES integration_providers(id),
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, active, error, disabled
    
    -- OAuth tokens (encrypted)
    access_token_encrypted TEXT,
    refresh_token_encrypted TEXT,
    token_expires_at TIMESTAMPTZ,
    token_scopes TEXT[],
    
    -- API keys (if not OAuth)
    api_key_encrypted TEXT,
    api_secret_encrypted TEXT,
    
    -- Provider-specific settings
    settings JSONB DEFAULT '{}',
    
    -- External account info
    external_account_id VARCHAR(255),
    external_account_name VARCHAR(255),
    
    -- Sync status
    last_sync_at TIMESTAMPTZ,
    last_sync_status VARCHAR(20),
    last_sync_error TEXT,
    sync_frequency_minutes INTEGER DEFAULT 60,
    
    -- Usage
    api_calls_today INTEGER DEFAULT 0,
    api_calls_month INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(organization_id, provider_id)
);

CREATE INDEX idx_org_int_org ON organization_integrations(organization_id);
CREATE INDEX idx_org_int_provider ON organization_integrations(provider_id);
CREATE INDEX idx_org_int_status ON organization_integrations(status);

COMMENT ON TABLE organization_integrations IS 'Active integrations for organizations';

-- -----------------------------------------------------------------------------
-- Table: integration_sync_logs
-- Purpose: Integration sync history
-- -----------------------------------------------------------------------------
CREATE TABLE integration_sync_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    integration_id UUID NOT NULL REFERENCES organization_integrations(id) ON DELETE CASCADE,
    
    sync_type VARCHAR(30) NOT NULL,              -- full, incremental, webhook
    direction VARCHAR(10) NOT NULL,              -- inbound, outbound
    
    -- Status
    status VARCHAR(20) NOT NULL,                 -- started, completed, failed, partial
    
    -- Stats
    records_processed INTEGER DEFAULT 0,
    records_created INTEGER DEFAULT 0,
    records_updated INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    
    -- Timing
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    duration_seconds INTEGER,
    
    -- Errors
    error_message TEXT,
    error_details JSONB,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sync_logs_int ON integration_sync_logs(integration_id);
CREATE INDEX idx_sync_logs_created ON integration_sync_logs(integration_id, created_at DESC);

COMMENT ON TABLE integration_sync_logs IS 'Integration synchronization history';

-- ============================================================================
-- SECTION 20: WEBHOOKS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: webhook_endpoints
-- Purpose: Customer webhook endpoints
-- -----------------------------------------------------------------------------
CREATE TABLE webhook_endpoints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    url VARCHAR(500) NOT NULL,
    description TEXT,
    
    -- Authentication
    secret_key VARCHAR(255) NOT NULL,            -- For HMAC signing
    auth_type VARCHAR(20) DEFAULT 'hmac',        -- hmac, bearer, basic
    auth_header_name VARCHAR(50) DEFAULT 'X-Webhook-Signature',
    
    -- Events
    subscribed_events TEXT[] NOT NULL,           -- candidate.created, application.stage_changed, etc.
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Reliability
    retry_count INTEGER DEFAULT 3,
    timeout_seconds INTEGER DEFAULT 30,
    
    -- Statistics
    total_deliveries INTEGER DEFAULT 0,
    successful_deliveries INTEGER DEFAULT 0,
    failed_deliveries INTEGER DEFAULT 0,
    
    -- Last delivery
    last_delivery_at TIMESTAMPTZ,
    last_delivery_status VARCHAR(20),
    last_delivery_response_code INTEGER,
    
    -- Health
    consecutive_failures INTEGER DEFAULT 0,
    disabled_at TIMESTAMPTZ,
    disabled_reason TEXT,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_webhook_org ON webhook_endpoints(organization_id);
CREATE INDEX idx_webhook_active ON webhook_endpoints(organization_id, is_active) WHERE is_active = true;

COMMENT ON TABLE webhook_endpoints IS 'Customer webhook endpoints';

-- -----------------------------------------------------------------------------
-- Table: webhook_deliveries
-- Purpose: Webhook delivery attempts
-- -----------------------------------------------------------------------------
CREATE TABLE webhook_deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    endpoint_id UUID NOT NULL REFERENCES webhook_endpoints(id) ON DELETE CASCADE,
    
    -- Event
    event_type VARCHAR(100) NOT NULL,
    event_id UUID NOT NULL,
    
    -- Payload
    payload JSONB NOT NULL,
    
    -- Request
    request_headers JSONB,
    request_body TEXT,
    
    -- Response
    response_code INTEGER,
    response_headers JSONB,
    response_body TEXT,
    
    -- Status
    status VARCHAR(20) NOT NULL,                 -- pending, success, failed, retrying
    
    -- Timing
    attempted_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_ms INTEGER,
    
    -- Retries
    attempt_number INTEGER DEFAULT 1,
    next_retry_at TIMESTAMPTZ,
    
    -- Error
    error_message TEXT,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_webhook_del_endpoint ON webhook_deliveries(endpoint_id);
CREATE INDEX idx_webhook_del_event ON webhook_deliveries(event_type, event_id);
CREATE INDEX idx_webhook_del_status ON webhook_deliveries(status);
CREATE INDEX idx_webhook_del_retry ON webhook_deliveries(next_retry_at) WHERE status = 'retrying';

COMMENT ON TABLE webhook_deliveries IS 'Webhook delivery attempts and results';

-- ============================================================================
-- SECTION 21: ANALYTICS & REPORTING
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: report_definitions
-- Purpose: Custom report definitions
-- -----------------------------------------------------------------------------
CREATE TABLE report_definitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    name VARCHAR(150) NOT NULL,
    description TEXT,
    report_type VARCHAR(50) NOT NULL,            -- pipeline, source, time_to_hire, diversity, recruiter_performance
    
    -- Configuration
    filters JSONB DEFAULT '{}',
    groupings JSONB DEFAULT '[]',
    metrics JSONB DEFAULT '[]',
    date_range_type VARCHAR(30),                 -- last_7_days, last_30_days, custom, etc.
    custom_date_start DATE,
    custom_date_end DATE,
    
    -- Display
    chart_type VARCHAR(30),                      -- bar, line, pie, table, funnel
    display_options JSONB DEFAULT '{}',
    
    -- Sharing
    is_shared BOOLEAN DEFAULT false,
    
    -- Scheduling
    is_scheduled BOOLEAN DEFAULT false,
    schedule_frequency VARCHAR(20),              -- daily, weekly, monthly
    schedule_day INTEGER,                        -- Day of week (1-7) or month (1-31)
    schedule_time TIME,
    schedule_recipients TEXT[] DEFAULT '{}',
    last_sent_at TIMESTAMPTZ,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_report_def_org ON report_definitions(organization_id);
CREATE INDEX idx_report_def_type ON report_definitions(report_type);

COMMENT ON TABLE report_definitions IS 'Custom report definitions';

-- -----------------------------------------------------------------------------
-- Table: analytics_snapshots
-- Purpose: Daily analytics snapshots for historical tracking
-- -----------------------------------------------------------------------------
CREATE TABLE analytics_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    snapshot_date DATE NOT NULL,
    
    -- Pipeline metrics
    total_candidates INTEGER DEFAULT 0,
    active_candidates INTEGER DEFAULT 0,
    total_jobs INTEGER DEFAULT 0,
    open_jobs INTEGER DEFAULT 0,
    total_applications INTEGER DEFAULT 0,
    
    -- Stage distribution
    applications_by_stage JSONB DEFAULT '{}',
    
    -- Activity metrics
    new_candidates_today INTEGER DEFAULT 0,
    new_applications_today INTEGER DEFAULT 0,
    interviews_scheduled_today INTEGER DEFAULT 0,
    offers_sent_today INTEGER DEFAULT 0,
    hires_today INTEGER DEFAULT 0,
    
    -- Source metrics
    applications_by_source JSONB DEFAULT '{}',
    
    -- Time metrics (averages in days)
    avg_time_to_hire DECIMAL(10, 2),
    avg_time_in_stage JSONB DEFAULT '{}',
    
    -- Conversion rates
    application_to_interview_rate DECIMAL(5, 4),
    interview_to_offer_rate DECIMAL(5, 4),
    offer_acceptance_rate DECIMAL(5, 4),
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(organization_id, snapshot_date)
);

CREATE INDEX idx_analytics_snap_org ON analytics_snapshots(organization_id);
CREATE INDEX idx_analytics_snap_date ON analytics_snapshots(organization_id, snapshot_date DESC);

COMMENT ON TABLE analytics_snapshots IS 'Daily analytics snapshots for trend analysis';

-- -----------------------------------------------------------------------------
-- Table: job_analytics
-- Purpose: Per-job analytics
-- -----------------------------------------------------------------------------
CREATE TABLE job_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    snapshot_date DATE NOT NULL,
    
    -- Applications
    total_applications INTEGER DEFAULT 0,
    new_applications INTEGER DEFAULT 0,
    qualified_applications INTEGER DEFAULT 0,
    rejected_applications INTEGER DEFAULT 0,
    
    -- Pipeline
    applications_by_stage JSONB DEFAULT '{}',
    
    -- Sources
    applications_by_source JSONB DEFAULT '{}',
    
    -- Engagement
    job_views INTEGER DEFAULT 0,
    apply_clicks INTEGER DEFAULT 0,
    apply_rate DECIMAL(5, 4),
    
    -- Timing
    avg_time_in_stage JSONB DEFAULT '{}',
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(job_id, snapshot_date)
);

CREATE INDEX idx_job_analytics_job ON job_analytics(job_id);
CREATE INDEX idx_job_analytics_date ON job_analytics(job_id, snapshot_date DESC);

COMMENT ON TABLE job_analytics IS 'Per-job analytics snapshots';

-- ============================================================================
-- SECTION 22: BILLING & SUBSCRIPTIONS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: subscription_plans
-- Purpose: Available subscription plans
-- -----------------------------------------------------------------------------
CREATE TABLE subscription_plans (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    tier subscription_tier NOT NULL,
    
    -- Pricing
    price_monthly DECIMAL(10, 2),
    price_yearly DECIMAL(10, 2),
    currency_id INTEGER REFERENCES currencies(id),
    
    -- Limits
    max_users INTEGER,
    max_jobs INTEGER,
    max_candidates_per_month INTEGER,
    max_integrations INTEGER,
    
    -- Features
    features JSONB DEFAULT '{}',
    
    -- Display
    is_featured BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    
    -- Availability
    is_active BOOLEAN DEFAULT true,
    is_public BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE subscription_plans IS 'Available subscription plans';

-- -----------------------------------------------------------------------------
-- Table: subscriptions
-- Purpose: Organization subscriptions
-- -----------------------------------------------------------------------------
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    plan_id INTEGER NOT NULL REFERENCES subscription_plans(id),
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- active, past_due, cancelled, trialing
    
    -- Billing cycle
    billing_cycle VARCHAR(10) NOT NULL,          -- monthly, yearly
    current_period_start TIMESTAMPTZ NOT NULL,
    current_period_end TIMESTAMPTZ NOT NULL,
    
    -- Trial
    trial_start TIMESTAMPTZ,
    trial_end TIMESTAMPTZ,
    
    -- Cancellation
    cancel_at_period_end BOOLEAN DEFAULT false,
    cancelled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    
    -- External
    external_subscription_id VARCHAR(255),       -- Stripe subscription ID
    external_customer_id VARCHAR(255),           -- Stripe customer ID
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_subs_org ON subscriptions(organization_id);
CREATE INDEX idx_subs_plan ON subscriptions(plan_id);
CREATE INDEX idx_subs_status ON subscriptions(status);
CREATE INDEX idx_subs_external ON subscriptions(external_subscription_id);

COMMENT ON TABLE subscriptions IS 'Organization subscriptions';

-- -----------------------------------------------------------------------------
-- Table: invoices
-- Purpose: Billing invoices
-- -----------------------------------------------------------------------------
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES subscriptions(id),
    
    -- Invoice details
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    
    -- Amounts
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    currency_id INTEGER REFERENCES currencies(id),
    
    -- Period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'draft', -- draft, open, paid, void, uncollectible
    
    -- Dates
    issued_at TIMESTAMPTZ,
    due_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    voided_at TIMESTAMPTZ,
    
    -- Payment
    payment_method VARCHAR(30),
    payment_reference VARCHAR(255),
    
    -- External
    external_invoice_id VARCHAR(255),            -- Stripe invoice ID
    invoice_pdf_url VARCHAR(500),
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invoices_org ON invoices(organization_id);
CREATE INDEX idx_invoices_sub ON invoices(subscription_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_external ON invoices(external_invoice_id);

COMMENT ON TABLE invoices IS 'Billing invoices';

-- -----------------------------------------------------------------------------
-- Table: invoice_line_items
-- Purpose: Line items on invoices
-- -----------------------------------------------------------------------------
CREATE TABLE invoice_line_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    
    description VARCHAR(255) NOT NULL,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    
    -- Period
    period_start DATE,
    period_end DATE,
    
    -- Type
    line_type VARCHAR(30) DEFAULT 'subscription', -- subscription, addon, usage, credit
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invoice_items_invoice ON invoice_line_items(invoice_id);

COMMENT ON TABLE invoice_line_items IS 'Invoice line items';

-- -----------------------------------------------------------------------------
-- Table: usage_records
-- Purpose: Track usage for metered billing
-- -----------------------------------------------------------------------------
CREATE TABLE usage_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Usage type
    usage_type VARCHAR(50) NOT NULL,             -- candidates_processed, api_calls, emails_sent
    
    -- Quantity
    quantity INTEGER NOT NULL,
    
    -- Period
    period_start TIMESTAMPTZ NOT NULL,
    period_end TIMESTAMPTZ NOT NULL,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    -- Billing
    is_billed BOOLEAN DEFAULT false,
    invoice_id UUID REFERENCES invoices(id),
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_usage_org ON usage_records(organization_id);
CREATE INDEX idx_usage_type ON usage_records(usage_type);
CREATE INDEX idx_usage_period ON usage_records(organization_id, period_start, period_end);

COMMENT ON TABLE usage_records IS 'Usage tracking for metered billing';
-- ============================================================================
-- TALENTFORGE ATS - DATABASE SCHEMA
-- Part 8: Functions, Triggers, Views, and Seed Data
-- ============================================================================

-- ============================================================================
-- SECTION 23: UTILITY FUNCTIONS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Function: update_updated_at_column
-- Purpose: Auto-update updated_at timestamp
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS 'Auto-update updated_at timestamp on row update';

-- -----------------------------------------------------------------------------
-- Function: generate_slug
-- Purpose: Generate URL-safe slug from text
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_slug(input_text TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN LOWER(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                unaccent(TRIM(input_text)),
                '[^a-zA-Z0-9\s-]', '', 'g'
            ),
            '[\s-]+', '-', 'g'
        )
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION generate_slug(TEXT) IS 'Generate URL-safe slug from text';

-- -----------------------------------------------------------------------------
-- Function: generate_reference_code
-- Purpose: Generate unique reference codes (e.g., JOB-2024-0001)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_reference_code(
    prefix TEXT,
    org_id UUID
)
RETURNS TEXT AS $$
DECLARE
    year_part TEXT;
    sequence_num INTEGER;
    result TEXT;
BEGIN
    year_part := TO_CHAR(NOW(), 'YYYY');
    
    -- Get next sequence number for this org and year
    SELECT COALESCE(MAX(
        CAST(
            SUBSTRING(reference_code FROM LENGTH(prefix) + 6 FOR 4) 
            AS INTEGER
        )
    ), 0) + 1
    INTO sequence_num
    FROM jobs
    WHERE organization_id = org_id
    AND reference_code LIKE prefix || '-' || year_part || '-%';
    
    result := prefix || '-' || year_part || '-' || LPAD(sequence_num::TEXT, 4, '0');
    RETURN result;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_reference_code(TEXT, UUID) IS 'Generate unique reference codes like JOB-2024-0001';

-- -----------------------------------------------------------------------------
-- Function: calculate_experience_months
-- Purpose: Calculate total months between dates
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_experience_months(
    start_date DATE,
    end_date DATE
)
RETURNS INTEGER AS $$
BEGIN
    IF start_date IS NULL THEN
        RETURN 0;
    END IF;
    
    IF end_date IS NULL THEN
        end_date := CURRENT_DATE;
    END IF;
    
    RETURN EXTRACT(YEAR FROM AGE(end_date, start_date)) * 12 +
           EXTRACT(MONTH FROM AGE(end_date, start_date));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_experience_months(DATE, DATE) IS 'Calculate months between two dates';

-- -----------------------------------------------------------------------------
-- Function: update_candidate_search_vector
-- Purpose: Update full-text search vector for candidates
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_candidate_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.first_name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.last_name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.headline, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.current_title, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.current_company, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.profile_summary, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(array_to_string(NEW.tags, ' '), '')), 'D');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_candidate_search_vector() IS 'Update candidate full-text search vector';

-- -----------------------------------------------------------------------------
-- Function: update_job_search_vector
-- Purpose: Update full-text search vector for jobs
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_job_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.summary, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.responsibilities, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.qualifications, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_job_search_vector() IS 'Update job full-text search vector';

-- ============================================================================
-- SECTION 24: TRIGGERS
-- ============================================================================

-- Apply updated_at trigger to all tables with the column
DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS trigger_update_%I_updated_at ON %I;
            CREATE TRIGGER trigger_update_%I_updated_at
            BEFORE UPDATE ON %I
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
        ', t, t, t, t);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Candidate search vector trigger
CREATE TRIGGER trigger_candidate_search_vector
BEFORE INSERT OR UPDATE OF first_name, last_name, headline, current_title, current_company, profile_summary, tags
ON candidates
FOR EACH ROW
EXECUTE FUNCTION update_candidate_search_vector();

-- Job search vector trigger
CREATE TRIGGER trigger_job_search_vector
BEFORE INSERT OR UPDATE OF title, summary, description, responsibilities, qualifications
ON jobs
FOR EACH ROW
EXECUTE FUNCTION update_job_search_vector();

-- ============================================================================
-- SECTION 25: VIEWS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- View: v_active_jobs
-- Purpose: Currently active/open jobs
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_active_jobs AS
SELECT 
    j.*,
    o.name AS organization_name,
    d.name AS department_name,
    l.name AS location_name,
    u.first_name || ' ' || u.last_name AS hiring_manager_name
FROM jobs j
JOIN organizations o ON j.organization_id = o.id
LEFT JOIN organization_departments d ON j.department_id = d.id
LEFT JOIN organization_locations l ON j.location_id = l.id
LEFT JOIN users u ON j.hiring_manager_id = u.id
WHERE j.status = 'open'
AND j.deleted_at IS NULL;

COMMENT ON VIEW v_active_jobs IS 'Currently active/open jobs with related info';

-- -----------------------------------------------------------------------------
-- View: v_application_pipeline
-- Purpose: Application pipeline overview
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_application_pipeline AS
SELECT 
    a.id AS application_id,
    a.organization_id,
    a.job_id,
    j.title AS job_title,
    a.candidate_id,
    c.first_name || ' ' || c.last_name AS candidate_name,
    c.email AS candidate_email,
    c.current_title AS candidate_current_title,
    ps.name AS current_stage_name,
    ps.stage_type,
    a.status,
    a.overall_score,
    a.ai_recommendation,
    a.applied_at,
    a.last_activity_at,
    a.recruiter_rating,
    a.is_starred
FROM applications a
JOIN candidates c ON a.candidate_id = c.id
JOIN jobs j ON a.job_id = j.id
LEFT JOIN job_pipeline_stages ps ON a.current_stage_id = ps.id
WHERE a.deleted_at IS NULL;

COMMENT ON VIEW v_application_pipeline IS 'Application pipeline with candidate and job details';

-- -----------------------------------------------------------------------------
-- View: v_candidate_full_profile
-- Purpose: Complete candidate profile with aggregated data
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_candidate_full_profile AS
SELECT 
    c.*,
    -- Experience count
    (SELECT COUNT(*) FROM candidate_experience ce WHERE ce.candidate_id = c.id) AS experience_count,
    -- Education count
    (SELECT COUNT(*) FROM candidate_education ed WHERE ed.candidate_id = c.id) AS education_count,
    -- Skills count
    (SELECT COUNT(*) FROM candidate_skills cs WHERE cs.candidate_id = c.id) AS skills_count,
    -- Active applications
    (SELECT COUNT(*) FROM applications a WHERE a.candidate_id = c.id AND a.status NOT IN ('hired', 'rejected', 'withdrawn')) AS active_applications,
    -- Total applications
    (SELECT COUNT(*) FROM applications a WHERE a.candidate_id = c.id) AS total_applications,
    -- Country name
    co.name AS country_name,
    -- City name
    ci.name AS city_name
FROM candidates c
LEFT JOIN countries co ON c.country_id = co.id
LEFT JOIN cities ci ON c.city_id = ci.id
WHERE c.deleted_at IS NULL;

COMMENT ON VIEW v_candidate_full_profile IS 'Complete candidate profile with aggregated counts';

-- -----------------------------------------------------------------------------
-- View: v_interview_schedule
-- Purpose: Upcoming interviews
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_interview_schedule AS
SELECT 
    i.*,
    a.candidate_id,
    c.first_name || ' ' || c.last_name AS candidate_name,
    c.email AS candidate_email,
    j.title AS job_title,
    it.name AS interview_type_name,
    array_agg(u.first_name || ' ' || u.last_name) AS interviewer_names
FROM interviews i
JOIN applications a ON i.application_id = a.id
JOIN candidates c ON a.candidate_id = c.id
JOIN jobs j ON a.job_id = j.id
LEFT JOIN interview_types it ON i.interview_type_id = it.id
LEFT JOIN interview_participants ip ON i.id = ip.interview_id
LEFT JOIN users u ON ip.user_id = u.id
WHERE i.status IN ('scheduled', 'confirmed')
AND i.scheduled_at > NOW()
GROUP BY i.id, a.candidate_id, c.first_name, c.last_name, c.email, j.title, it.name;

COMMENT ON VIEW v_interview_schedule IS 'Upcoming interview schedule';

-- -----------------------------------------------------------------------------
-- View: v_organization_stats
-- Purpose: Organization-level statistics
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_organization_stats AS
SELECT 
    o.id AS organization_id,
    o.name AS organization_name,
    o.subscription_tier,
    -- Counts
    (SELECT COUNT(*) FROM users u WHERE u.organization_id = o.id AND u.deleted_at IS NULL) AS user_count,
    (SELECT COUNT(*) FROM jobs j WHERE j.organization_id = o.id AND j.deleted_at IS NULL) AS total_jobs,
    (SELECT COUNT(*) FROM jobs j WHERE j.organization_id = o.id AND j.status = 'open' AND j.deleted_at IS NULL) AS open_jobs,
    (SELECT COUNT(*) FROM candidates c WHERE c.organization_id = o.id AND c.deleted_at IS NULL) AS total_candidates,
    (SELECT COUNT(*) FROM applications a WHERE a.organization_id = o.id AND a.deleted_at IS NULL) AS total_applications,
    -- Recent activity
    (SELECT COUNT(*) FROM applications a WHERE a.organization_id = o.id AND a.applied_at > NOW() - INTERVAL '7 days') AS applications_last_7_days,
    (SELECT COUNT(*) FROM applications a WHERE a.organization_id = o.id AND a.outcome = 'hired' AND a.outcome_at > NOW() - INTERVAL '30 days') AS hires_last_30_days
FROM organizations o
WHERE o.deleted_at IS NULL;

COMMENT ON VIEW v_organization_stats IS 'Organization-level statistics dashboard';

-- ============================================================================
-- SECTION 26: SEED DATA
-- ============================================================================

-- Insert education levels
INSERT INTO education_levels (code, name, rank, description) VALUES
('high_school', 'High School Diploma', 1, 'High school or equivalent'),
('associate', 'Associate Degree', 2, 'Two-year college degree'),
('bachelor', 'Bachelor''s Degree', 3, 'Four-year undergraduate degree'),
('master', 'Master''s Degree', 4, 'Graduate degree'),
('mba', 'MBA', 4, 'Master of Business Administration'),
('phd', 'Doctorate (PhD)', 5, 'Doctor of Philosophy'),
('md', 'Medical Degree (MD)', 5, 'Doctor of Medicine'),
('jd', 'Law Degree (JD)', 5, 'Juris Doctor'),
('professional', 'Professional Certification', 3, 'Industry certification')
ON CONFLICT (code) DO NOTHING;

-- Insert skill categories
INSERT INTO skill_categories (name, description, sort_order) VALUES
('Programming Languages', 'Software programming languages', 1),
('Frameworks & Libraries', 'Software frameworks and libraries', 2),
('Databases', 'Database technologies', 3),
('Cloud & DevOps', 'Cloud platforms and DevOps tools', 4),
('Data Science & AI', 'Data science and AI/ML technologies', 5),
('Design', 'Design tools and skills', 6),
('Project Management', 'Project management methodologies', 7),
('Soft Skills', 'Interpersonal and communication skills', 8),
('Languages', 'Human languages', 9),
('Industry Knowledge', 'Domain-specific knowledge', 10)
ON CONFLICT (name) DO NOTHING;

-- Insert document types
INSERT INTO document_types (code, name, category, allowed_extensions, max_size_mb) VALUES
('resume', 'Resume/CV', 'resume', ARRAY['pdf', 'doc', 'docx'], 10),
('cover_letter', 'Cover Letter', 'cover_letter', ARRAY['pdf', 'doc', 'docx'], 5),
('portfolio', 'Portfolio', 'portfolio', ARRAY['pdf', 'zip'], 50),
('transcript', 'Academic Transcript', 'education', ARRAY['pdf'], 10),
('degree_certificate', 'Degree Certificate', 'education', ARRAY['pdf', 'jpg', 'png'], 10),
('id_proof', 'ID Proof', 'id', ARRAY['pdf', 'jpg', 'png'], 5),
('work_sample', 'Work Sample', 'portfolio', ARRAY['pdf', 'zip', 'doc', 'docx'], 25),
('reference_letter', 'Reference Letter', 'other', ARRAY['pdf'], 5),
('other', 'Other Document', 'other', ARRAY['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'], 25)
ON CONFLICT (code) DO NOTHING;

-- Insert currencies
INSERT INTO currencies (code, name, symbol, decimal_places) VALUES
('USD', 'US Dollar', '$', 2),
('EUR', 'Euro', '€', 2),
('GBP', 'British Pound', '£', 2),
('INR', 'Indian Rupee', '₹', 2),
('CAD', 'Canadian Dollar', 'C$', 2),
('AUD', 'Australian Dollar', 'A$', 2),
('JPY', 'Japanese Yen', '¥', 0),
('CNY', 'Chinese Yuan', '¥', 2),
('SGD', 'Singapore Dollar', 'S$', 2),
('AED', 'UAE Dirham', 'د.إ', 2)
ON CONFLICT (code) DO NOTHING;

-- Insert languages
INSERT INTO languages (iso_code, iso_code_3, name, native_name) VALUES
('en', 'eng', 'English', 'English'),
('es', 'spa', 'Spanish', 'Español'),
('fr', 'fra', 'French', 'Français'),
('de', 'deu', 'German', 'Deutsch'),
('zh', 'zho', 'Chinese', '中文'),
('ja', 'jpn', 'Japanese', '日本語'),
('ko', 'kor', 'Korean', '한국어'),
('hi', 'hin', 'Hindi', 'हिन्दी'),
('ar', 'ara', 'Arabic', 'العربية'),
('pt', 'por', 'Portuguese', 'Português'),
('ru', 'rus', 'Russian', 'Русский'),
('it', 'ita', 'Italian', 'Italiano'),
('nl', 'nld', 'Dutch', 'Nederlands'),
('pl', 'pol', 'Polish', 'Polski'),
('tr', 'tur', 'Turkish', 'Türkçe')
ON CONFLICT (iso_code) DO NOTHING;

-- Insert job boards
INSERT INTO job_boards (name, code, website, api_available, supports_apply) VALUES
('LinkedIn', 'linkedin', 'https://www.linkedin.com', true, true),
('Indeed', 'indeed', 'https://www.indeed.com', true, true),
('Glassdoor', 'glassdoor', 'https://www.glassdoor.com', true, true),
('ZipRecruiter', 'ziprecruiter', 'https://www.ziprecruiter.com', true, true),
('Monster', 'monster', 'https://www.monster.com', true, true),
('Naukri', 'naukri', 'https://www.naukri.com', true, true),
('AngelList', 'angellist', 'https://angel.co', true, true),
('Stack Overflow Jobs', 'stackoverflow', 'https://stackoverflow.com/jobs', true, true)
ON CONFLICT (code) DO NOTHING;

-- Insert integration providers
INSERT INTO integration_providers (code, name, category, is_active) VALUES
('google_calendar', 'Google Calendar', 'calendar', true),
('outlook_calendar', 'Microsoft Outlook', 'calendar', true),
('slack', 'Slack', 'communication', true),
('teams', 'Microsoft Teams', 'communication', true),
('zoom', 'Zoom', 'video', true),
('google_meet', 'Google Meet', 'video', true),
('sendgrid', 'SendGrid', 'email', true),
('twilio', 'Twilio', 'sms', true),
('bamboohr', 'BambooHR', 'hris', true),
('workday', 'Workday', 'hris', true),
('hackerrank', 'HackerRank', 'assessment', true),
('codility', 'Codility', 'assessment', true),
('checkr', 'Checkr', 'background_check', true),
('zapier', 'Zapier', 'automation', true)
ON CONFLICT (code) DO NOTHING;

-- Insert permissions
INSERT INTO permissions (code, name, category) VALUES
-- Jobs
('jobs.view', 'View Jobs', 'jobs'),
('jobs.create', 'Create Jobs', 'jobs'),
('jobs.edit', 'Edit Jobs', 'jobs'),
('jobs.delete', 'Delete Jobs', 'jobs'),
('jobs.publish', 'Publish Jobs', 'jobs'),
-- Candidates
('candidates.view', 'View Candidates', 'candidates'),
('candidates.create', 'Create Candidates', 'candidates'),
('candidates.edit', 'Edit Candidates', 'candidates'),
('candidates.delete', 'Delete Candidates', 'candidates'),
('candidates.export', 'Export Candidates', 'candidates'),
-- Applications
('applications.view', 'View Applications', 'applications'),
('applications.manage', 'Manage Applications', 'applications'),
('applications.move_stage', 'Move Application Stage', 'applications'),
-- Interviews
('interviews.view', 'View Interviews', 'interviews'),
('interviews.schedule', 'Schedule Interviews', 'interviews'),
('interviews.feedback', 'Submit Interview Feedback', 'interviews'),
-- Offers
('offers.view', 'View Offers', 'offers'),
('offers.create', 'Create Offers', 'offers'),
('offers.approve', 'Approve Offers', 'offers'),
-- Reports
('reports.view', 'View Reports', 'reports'),
('reports.create', 'Create Reports', 'reports'),
('reports.export', 'Export Reports', 'reports'),
-- Settings
('settings.view', 'View Settings', 'settings'),
('settings.edit', 'Edit Settings', 'settings'),
('users.manage', 'Manage Users', 'settings'),
('integrations.manage', 'Manage Integrations', 'settings'),
('billing.view', 'View Billing', 'settings'),
('billing.manage', 'Manage Billing', 'settings')
ON CONFLICT (code) DO NOTHING;

-- Insert subscription plans
INSERT INTO subscription_plans (code, name, tier, price_monthly, price_yearly, max_users, max_jobs, max_candidates_per_month, is_active, sort_order) VALUES
('free', 'Free', 'free', 0, 0, 1, 1, 25, true, 1),
('starter', 'Starter', 'starter', 49, 490, 3, 5, 200, true, 2),
('pro', 'Professional', 'pro', 149, 1490, 10, 25, 1000, true, 3),
('business', 'Business', 'business', 299, 2990, 25, -1, 5000, true, 4),
('enterprise', 'Enterprise', 'enterprise', NULL, NULL, -1, -1, -1, true, 5)
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SECTION 27: SAMPLE SKILLS (Common tech skills)
-- ============================================================================

INSERT INTO skills (canonical_name, display_name, category_id, skill_type, is_verified) 
SELECT name, name, c.id, 'hard', true
FROM (VALUES
    ('JavaScript', 'Programming Languages'),
    ('TypeScript', 'Programming Languages'),
    ('Python', 'Programming Languages'),
    ('Java', 'Programming Languages'),
    ('C#', 'Programming Languages'),
    ('Go', 'Programming Languages'),
    ('Rust', 'Programming Languages'),
    ('Ruby', 'Programming Languages'),
    ('PHP', 'Programming Languages'),
    ('Swift', 'Programming Languages'),
    ('Kotlin', 'Programming Languages'),
    ('React', 'Frameworks & Libraries'),
    ('Angular', 'Frameworks & Libraries'),
    ('Vue.js', 'Frameworks & Libraries'),
    ('Node.js', 'Frameworks & Libraries'),
    ('Django', 'Frameworks & Libraries'),
    ('Flask', 'Frameworks & Libraries'),
    ('Spring Boot', 'Frameworks & Libraries'),
    ('Express.js', 'Frameworks & Libraries'),
    ('Next.js', 'Frameworks & Libraries'),
    ('PostgreSQL', 'Databases'),
    ('MySQL', 'Databases'),
    ('MongoDB', 'Databases'),
    ('Redis', 'Databases'),
    ('Elasticsearch', 'Databases'),
    ('AWS', 'Cloud & DevOps'),
    ('Azure', 'Cloud & DevOps'),
    ('Google Cloud', 'Cloud & DevOps'),
    ('Docker', 'Cloud & DevOps'),
    ('Kubernetes', 'Cloud & DevOps'),
    ('Terraform', 'Cloud & DevOps'),
    ('Jenkins', 'Cloud & DevOps'),
    ('Git', 'Cloud & DevOps'),
    ('Machine Learning', 'Data Science & AI'),
    ('Deep Learning', 'Data Science & AI'),
    ('TensorFlow', 'Data Science & AI'),
    ('PyTorch', 'Data Science & AI'),
    ('Data Analysis', 'Data Science & AI'),
    ('SQL', 'Data Science & AI'),
    ('Figma', 'Design'),
    ('Adobe XD', 'Design'),
    ('Sketch', 'Design'),
    ('UI Design', 'Design'),
    ('UX Design', 'Design'),
    ('Agile', 'Project Management'),
    ('Scrum', 'Project Management'),
    ('Jira', 'Project Management'),
    ('Leadership', 'Soft Skills'),
    ('Communication', 'Soft Skills'),
    ('Problem Solving', 'Soft Skills'),
    ('Team Collaboration', 'Soft Skills')
) AS s(name, category_name)
JOIN skill_categories c ON c.name = s.category_name
ON CONFLICT (canonical_name) DO NOTHING;

-- ============================================================================
-- COMPLETE
-- ============================================================================

-- Final message
DO $$
BEGIN
    RAISE NOTICE 'TalentForge ATS Database Schema Created Successfully!';
    RAISE NOTICE 'Tables: 60+';
    RAISE NOTICE 'Views: 5';
    RAISE NOTICE 'Functions: 5';
    RAISE NOTICE 'Triggers: Auto-generated for updated_at';
END;
$$ LANGUAGE plpgsql;
