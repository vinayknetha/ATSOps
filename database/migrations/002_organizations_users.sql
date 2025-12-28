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
