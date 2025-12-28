# TalentForge ATS - Database Schema Documentation

## Overview

**Database:** PostgreSQL 15+  
**Approach:** DB-First, Normalized (3NF+), Full Audit Trail  
**Total Tables:** 65+  
**Total Lines:** 4,200+  

---

## Schema Organization

| File | Section | Tables | Purpose |
|------|---------|--------|---------|
| `001_lookup_tables.sql` | 1-2 | 12 | Reference data (countries, skills, languages) |
| `002_organizations_users.sql` | 3-6 | 14 | Multi-tenant, auth, RBAC, audit |
| `003_candidates.sql` | 7 | 12 | Candidates, experience, education, skills |
| `004_jobs.sql` | 8-10 | 10 | Jobs, requirements, pipelines |
| `005_applications_interviews.sql` | 11-13 | 14 | Applications, interviews, offers |
| `006_communications_documents.sql` | 14-18 | 12 | Email, docs, notes, tags, searches |
| `007_integrations_billing.sql` | 19-22 | 12 | Integrations, webhooks, analytics, billing |
| `008_functions_triggers_seed.sql` | 23-27 | - | Functions, triggers, views, seed data |

---

## Audit Columns (On Every Table)

```sql
created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
created_by    UUID
updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_by    UUID
deleted_at    TIMESTAMPTZ  -- Soft delete
deleted_by    UUID
```

Auto-updated via trigger: `update_updated_at_column()`

---

## Key Entity Relationships

### Core Entities

```
Organizations (Tenants)
├── Users (team members)
│   ├── User Sessions
│   ├── OAuth Accounts
│   └── MFA Settings
├── Departments
├── Locations
├── Jobs
│   ├── Requirements
│   ├── Questions
│   ├── Pipeline Stages
│   ├── Team Members
│   └── Job Postings
├── Candidates
│   ├── Experience
│   ├── Education
│   ├── Skills
│   ├── Certifications
│   ├── Languages
│   ├── Projects
│   ├── Publications
│   └── References
└── Applications
    ├── Stage History
    ├── Answers
    ├── Skill Matches
    ├── Interviews
    │   ├── Participants
    │   └── Feedback
    └── Offers
        └── Approvers
```

---

## Table Catalog

### Section 1: Lookup/Reference Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `countries` | ISO 3166 countries | iso_code, name, phone_code |
| `states_provinces` | States within countries | country_id, code, name |
| `cities` | Cities with geo coords | country_id, latitude, longitude |
| `industries` | Hierarchical industry codes | name, parent_id |
| `departments` | Standard department names | name |
| `currencies` | ISO 4217 currencies | code, symbol |
| `languages` | ISO 639 languages | iso_code, name |
| `education_levels` | Education hierarchy | code, rank |
| `fields_of_study` | Academic majors | name, category |

### Section 2: Skills Taxonomy

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `skill_categories` | Skill categorization | name, parent_id |
| `skills` | Master skills list | canonical_name, category_id, skill_type |
| `skill_aliases` | Skill synonyms | skill_id, alias |
| `skill_relationships` | Related skills | skill_id, related_skill_id, relationship_type |

### Section 3: Organizations

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `organizations` | Tenant accounts | name, slug, subscription_tier |
| `organization_departments` | Org-specific departments | organization_id, name |
| `organization_locations` | Office locations | organization_id, address, geo |

### Section 4: Users & Auth

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `users` | User accounts | organization_id, email, role |
| `user_sessions` | Active sessions | user_id, refresh_token_hash |
| `user_oauth_accounts` | OAuth connections | user_id, provider |
| `user_mfa` | MFA settings | user_id, mfa_type |
| `password_reset_tokens` | Password resets | user_id, token_hash |
| `user_invitations` | Pending invites | organization_id, email, role |

### Section 5: Permissions

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `permissions` | Permission definitions | code, name, category |
| `role_permissions` | Default role permissions | role, permission_id |
| `user_permission_overrides` | User-specific overrides | user_id, permission_id, is_granted |

### Section 6: Audit

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `audit_logs` | Compliance audit trail | organization_id, action, entity_type |
| `activity_feed` | User-facing activity | organization_id, activity_type, entity_id |

### Section 7: Candidates

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `candidates` | Core candidate records | organization_id, email, parsed_data |
| `candidate_experience` | Work history | candidate_id, company_name, title |
| `candidate_experience_skills` | Skills per experience | experience_id, skill_id |
| `candidate_education` | Education history | candidate_id, institution_name, degree |
| `candidate_skills` | Skills with proficiency | candidate_id, skill_id, proficiency_level |
| `candidate_certifications` | Certifications | candidate_id, name, issuing_organization |
| `candidate_languages` | Language proficiency | candidate_id, language_id, level |
| `candidate_projects` | Portfolio projects | candidate_id, name, url |
| `candidate_publications` | Publications/papers | candidate_id, title, publication_type |
| `candidate_awards` | Awards/honors | candidate_id, title |
| `candidate_references` | Professional references | candidate_id, name, relationship |

### Section 8-9: Jobs & Pipelines

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `jobs` | Job postings | organization_id, title, status |
| `job_requirements` | Detailed requirements | job_id, requirement_type, is_required |
| `job_questions` | Screening questions | job_id, question_text, question_type |
| `job_team_members` | Hiring team | job_id, user_id, role |
| `pipeline_templates` | Reusable pipelines | organization_id, name |
| `pipeline_template_stages` | Template stages | template_id, name, stage_type |
| `job_pipeline_stages` | Job-specific stages | job_id, name, stage_type |
| `job_boards` | Available job boards | name, code, api_available |
| `job_postings` | External postings | job_id, job_board_id, external_id |

### Section 10-12: Applications & Interviews

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `applications` | Job applications | job_id, candidate_id, current_stage_id |
| `application_stage_history` | Stage transitions | application_id, from_stage_id, to_stage_id |
| `application_answers` | Screening answers | application_id, question_id |
| `application_skill_matches` | Skill match details | application_id, job_requirement_id |
| `interview_types` | Interview types | organization_id, name |
| `interviews` | Scheduled interviews | application_id, scheduled_at, status |
| `interview_participants` | Interviewers | interview_id, user_id, role |
| `scorecard_templates` | Scorecard templates | organization_id, name |
| `scorecard_criteria` | Scorecard criteria | template_id, name, score_type |
| `interview_feedback` | Interviewer feedback | interview_id, user_id, recommendation |
| `interview_feedback_scores` | Criterion scores | feedback_id, criterion_id, score |
| `rejection_reasons` | Standard rejections | organization_id, name |
| `offers` | Job offers | application_id, base_salary, status |
| `offer_approvers` | Offer approvals | offer_id, user_id, status |

### Section 13-17: Communications & Content

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `email_templates` | Email templates | organization_id, subject, body_html |
| `communications` | All communications | candidate_id, communication_type, status |
| `communication_attachments` | Email attachments | communication_id, file_url |
| `document_types` | Document types | code, name, allowed_extensions |
| `documents` | All documents | candidate_id, file_url, document_type_id |
| `notes` | Notes/comments | entity_type, entity_id, content |
| `note_reactions` | Note reactions | note_id, user_id, reaction |
| `tags` | Organization tags | organization_id, name, color |
| `entity_tags` | Tag assignments | tag_id, entity_type, entity_id |
| `saved_searches` | Saved searches | user_id, filters, entity_type |
| `candidate_lists` | Candidate pools | organization_id, name, list_type |
| `candidate_list_members` | List members | list_id, candidate_id |

### Section 18-21: Integrations & Analytics

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `integration_providers` | Available integrations | code, name, category |
| `organization_integrations` | Active integrations | organization_id, provider_id, status |
| `integration_sync_logs` | Sync history | integration_id, status, records_processed |
| `webhook_endpoints` | Customer webhooks | organization_id, url, subscribed_events |
| `webhook_deliveries` | Delivery attempts | endpoint_id, status, response_code |
| `report_definitions` | Custom reports | organization_id, report_type, filters |
| `analytics_snapshots` | Daily snapshots | organization_id, snapshot_date |
| `job_analytics` | Per-job analytics | job_id, snapshot_date |

### Section 22: Billing

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `subscription_plans` | Available plans | code, tier, price_monthly |
| `subscriptions` | Org subscriptions | organization_id, plan_id, status |
| `invoices` | Billing invoices | organization_id, total, status |
| `invoice_line_items` | Invoice items | invoice_id, amount |
| `usage_records` | Usage tracking | organization_id, usage_type, quantity |

---

## Indexes Strategy

Each table includes indexes for:
- Foreign keys (all `_id` columns)
- Common filters (status, dates, organization_id)
- Full-text search (`USING gin(search_vector)`)
- Trigram search (`USING gin(column gin_trgm_ops)`)
- Soft delete filters (`WHERE deleted_at IS NULL`)

---

## Views

| View | Purpose |
|------|---------|
| `v_active_jobs` | Open jobs with org/dept/location info |
| `v_application_pipeline` | Applications with candidate/job details |
| `v_candidate_full_profile` | Candidates with aggregated counts |
| `v_interview_schedule` | Upcoming interviews |
| `v_organization_stats` | Org-level dashboard stats |

---

## Functions

| Function | Purpose |
|----------|---------|
| `update_updated_at_column()` | Auto-update timestamp trigger |
| `generate_slug(text)` | Create URL-safe slugs |
| `generate_reference_code(prefix, org_id)` | Generate JOB-2024-0001 codes |
| `calculate_experience_months(start, end)` | Calculate duration |
| `update_candidate_search_vector()` | Update FTS index |
| `update_job_search_vector()` | Update FTS index |

---

## Seed Data Included

- 9 Education levels
- 10 Skill categories
- 50+ Common tech skills
- 9 Document types
- 10 Currencies
- 15 Languages
- 8 Job boards
- 14 Integration providers
- 30 Permissions
- 5 Subscription plans

---

## Custom Types (ENUMs)

```sql
subscription_tier: free, starter, pro, business, enterprise
org_status: active, suspended, cancelled, trial
user_status: active, inactive, pending, locked
user_role: super_admin, admin, recruiter, hiring_manager, interviewer, viewer
job_status: draft, open, paused, closed, archived
job_type: full_time, part_time, contract, internship, temporary, freelance
workplace_type: onsite, remote, hybrid
experience_level: entry, associate, mid, senior, lead, manager, director, executive
candidate_status: active, passive, not_looking, archived
candidate_source: direct_apply, referral, linkedin, indeed, glassdoor, naukri, agency, career_site, job_fair, university, other
application_status: new, reviewed, shortlisted, interviewing, offer, hired, rejected, withdrawn
communication_type: email, sms, whatsapp, phone_call, in_app, system
communication_direction: inbound, outbound
communication_status: pending, sent, delivered, read, failed, bounced
activity_type: created, updated, deleted, viewed, status_changed, stage_changed, note_added, email_sent, interview_scheduled, score_updated, document_uploaded, comment_added
```

---

## Usage

```bash
# Create database
createdb talentforge

# Run complete schema
psql -d talentforge -f TalentForge_Complete_Schema.sql

# Or run individual files in order
psql -d talentforge -f 001_lookup_tables.sql
psql -d talentforge -f 002_organizations_users.sql
# ... etc
```

---

## Next Steps

1. Add migrations framework (Prisma, Flyway, or custom)
2. Create database connection pooling (PgBouncer)
3. Set up read replicas for reporting
4. Implement row-level security for multi-tenant isolation
5. Add table partitioning for audit_logs (by month)
6. Create backup and restore procedures

---

**Total Schema:** 4,210 lines of production-ready SQL
