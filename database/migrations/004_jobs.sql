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
