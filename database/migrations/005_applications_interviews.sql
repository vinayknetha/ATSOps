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
