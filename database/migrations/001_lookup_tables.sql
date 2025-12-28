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
