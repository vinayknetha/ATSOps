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
