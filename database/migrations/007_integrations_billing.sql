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
