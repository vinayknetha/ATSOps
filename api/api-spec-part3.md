## 5. Jobs & Requisitions

### 5.1 Job CRUD Operations

#### List Jobs
```
GET /jobs
```

**Headers:** `Authorization: Bearer <access_token>`  
**Permission Required:** `jobs.view`

**Query Parameters:**
- `page`: integer (default: 1)
- `per_page`: integer (default: 20, max: 100)
- `search`: string (full-text search on title, description)
- `status`: `draft` | `open` | `paused` | `closed` | `archived`
- `department_id`: UUID
- `location_id`: UUID
- `hiring_manager_id`: UUID
- `job_type`: `full_time` | `part_time` | `contract` | `internship` | `temporary` | `freelance`
- `workplace_type`: `onsite` | `remote` | `hybrid`
- `experience_level`: `entry` | `associate` | `mid` | `senior` | `lead` | `manager` | `director` | `executive`
- `salary_min`: decimal
- `salary_max`: decimal
- `salary_currency`: string (ISO code)
- `has_applications`: boolean
- `created_from`: ISO date
- `created_to`: ISO date
- `sort_by`: `title` | `created_at` | `published_at` | `applications_count` | `status`
- `sort_dir`: `asc` | `desc`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Senior Software Engineer",
      "slug": "senior-software-engineer-sf-2024",
      "reference_code": "JOB-2024-0042",
      "department": {
        "id": "uuid",
        "name": "Engineering"
      },
      "location": {
        "id": "uuid",
        "name": "San Francisco HQ",
        "city": "San Francisco",
        "country": "United States"
      },
      "hiring_manager": {
        "id": "uuid",
        "name": "Jane Smith",
        "avatar_url": "https://..."
      },
      "job_type": "full_time",
      "workplace_type": "hybrid",
      "experience_level": "senior",
      "salary_range": {
        "min": 150000,
        "max": 200000,
        "currency": "USD",
        "period": "yearly",
        "visible": true
      },
      "status": "open",
      "positions": {
        "total": 2,
        "filled": 0
      },
      "statistics": {
        "total_applications": 45,
        "new_applications": 12,
        "views_count": 1250
      },
      "published_at": "2025-01-10T10:00:00Z",
      "expires_at": "2025-02-10T23:59:59Z",
      "created_at": "2025-01-08T14:00:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

#### Get Job Details
```
GET /jobs/{job_id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Senior Software Engineer",
    "slug": "senior-software-engineer-sf-2024",
    "reference_code": "JOB-2024-0042",
    
    "department": {
      "id": "uuid",
      "name": "Engineering",
      "code": "ENG"
    },
    "location": {
      "id": "uuid",
      "name": "San Francisco HQ",
      "address": "123 Main St, San Francisco, CA 94105",
      "city": "San Francisco",
      "state": "California",
      "country": "United States",
      "timezone": "America/Los_Angeles"
    },
    "hiring_manager": {
      "id": "uuid",
      "name": "Jane Smith",
      "email": "jane@acme.com",
      "avatar_url": "https://..."
    },
    
    "job_type": "full_time",
    "workplace_type": "hybrid",
    "experience_level": "senior",
    
    "content": {
      "summary": "We're looking for a Senior Software Engineer to join our growing team...",
      "description": "## About the Role\n\nAs a Senior Software Engineer, you will...",
      "responsibilities": "- Design and implement scalable backend services\n- Mentor junior developers\n- Participate in code reviews",
      "qualifications": "- 5+ years of software development experience\n- Strong knowledge of JavaScript/TypeScript\n- Experience with cloud platforms (AWS/GCP)",
      "benefits": "- Competitive salary and equity\n- Health, dental, and vision insurance\n- Unlimited PTO"
    },
    
    "requirements": {
      "experience_min_years": 5,
      "experience_max_years": 10,
      "education_level": {
        "id": 3,
        "name": "Bachelor's Degree"
      },
      "skills": {
        "required": [
          { "id": 1, "name": "JavaScript", "min_years": 4 },
          { "id": 2, "name": "React", "min_years": 3 },
          { "id": 3, "name": "Node.js", "min_years": 3 },
          { "id": 10, "name": "PostgreSQL", "min_years": 2 }
        ],
        "preferred": [
          { "id": 20, "name": "AWS", "min_years": 2 },
          { "id": 25, "name": "Docker", "min_years": 1 },
          { "id": 30, "name": "Kubernetes", "min_years": null }
        ]
      },
      "certifications": [
        { "name": "AWS Solutions Architect", "required": false }
      ],
      "languages": [
        { "id": 1, "name": "English", "level": "C1", "required": true }
      ]
    },
    
    "compensation": {
      "salary_min": 150000,
      "salary_max": 200000,
      "currency": { "code": "USD", "symbol": "$" },
      "period": "yearly",
      "visible": true,
      "notes": "Equity package available"
    },
    
    "positions": {
      "total": 2,
      "filled": 0
    },
    
    "flexibility": {
      "remote_allowed": true,
      "relocation_assistance": true,
      "visa_sponsorship": true
    },
    
    "status": "open",
    "dates": {
      "published_at": "2025-01-10T10:00:00Z",
      "expires_at": "2025-02-10T23:59:59Z",
      "target_start_date": "2025-03-01",
      "target_fill_date": "2025-02-15"
    },
    
    "seo": {
      "meta_title": "Senior Software Engineer - San Francisco | Acme Corp",
      "meta_description": "Join Acme Corp as a Senior Software Engineer..."
    },
    
    "settings": {
      "is_featured": false,
      "is_confidential": false,
      "application_email": "jobs@acme.com",
      "external_apply_url": null,
      "application_instructions": "Please include a cover letter..."
    },
    
    "scoring_weights": {
      "required_skills": 0.40,
      "preferred_skills": 0.25,
      "experience": 0.20,
      "education": 0.10,
      "location": 0.05
    },
    
    "pipeline": {
      "template_id": "uuid",
      "stages": [
        { "id": "uuid", "name": "New", "stage_type": "application", "sort_order": 0, "candidate_count": 12 },
        { "id": "uuid", "name": "Reviewed", "stage_type": "screening", "sort_order": 1, "candidate_count": 8 },
        { "id": "uuid", "name": "Phone Screen", "stage_type": "interview", "sort_order": 2, "candidate_count": 5 },
        { "id": "uuid", "name": "Technical Interview", "stage_type": "interview", "sort_order": 3, "candidate_count": 3 },
        { "id": "uuid", "name": "Onsite", "stage_type": "interview", "sort_order": 4, "candidate_count": 2 },
        { "id": "uuid", "name": "Offer", "stage_type": "offer", "sort_order": 5, "candidate_count": 1 },
        { "id": "uuid", "name": "Hired", "stage_type": "hired", "sort_order": 6, "candidate_count": 0, "is_terminal": true },
        { "id": "uuid", "name": "Rejected", "stage_type": "rejected", "sort_order": 7, "candidate_count": 14, "is_terminal": true, "is_rejection": true }
      ]
    },
    
    "team": [
      {
        "id": "uuid",
        "user": { "id": "uuid", "name": "Jane Smith", "avatar_url": "..." },
        "role": "hiring_manager",
        "permissions": { "can_view": true, "can_edit": true, "can_make_offers": true }
      },
      {
        "id": "uuid",
        "user": { "id": "uuid", "name": "Bob Johnson", "avatar_url": "..." },
        "role": "recruiter",
        "permissions": { "can_view": true, "can_edit": true, "can_make_offers": false }
      }
    ],
    
    "statistics": {
      "total_applications": 45,
      "new_applications": 12,
      "qualified_applications": 28,
      "views_count": 1250,
      "apply_rate": 0.036,
      "avg_time_in_stage": {
        "New": 2.5,
        "Reviewed": 3.2,
        "Phone Screen": 5.1
      }
    },
    
    "postings": [
      {
        "id": "uuid",
        "job_board": { "id": 1, "name": "LinkedIn", "logo_url": "..." },
        "status": "active",
        "external_url": "https://linkedin.com/jobs/...",
        "posted_at": "2025-01-10T12:00:00Z",
        "statistics": { "views": 850, "clicks": 120, "applications": 25 }
      }
    ],
    
    "created_at": "2025-01-08T14:00:00Z",
    "created_by": { "id": "uuid", "name": "Jane Smith" },
    "updated_at": "2025-01-15T09:00:00Z"
  }
}
```

---

#### Create Job
```
POST /jobs
```

**Permission Required:** `jobs.create`

**Request:**
```json
{
  "title": "Senior Software Engineer",
  "department_id": "uuid",
  "location_id": "uuid",
  "hiring_manager_id": "uuid",
  
  "job_type": "full_time",
  "workplace_type": "hybrid",
  "experience_level": "senior",
  
  "summary": "We're looking for a Senior Software Engineer...",
  "description": "## About the Role\n\nAs a Senior Software Engineer...",
  "responsibilities": "- Design and implement scalable backend services...",
  "qualifications": "- 5+ years of software development experience...",
  "benefits": "- Competitive salary and equity...",
  
  "experience_min_years": 5,
  "experience_max_years": 10,
  "education_level_id": 3,
  
  "salary_min": 150000,
  "salary_max": 200000,
  "salary_currency_id": 1,
  "salary_period": "yearly",
  "salary_visible": true,
  
  "positions_total": 2,
  
  "remote_allowed": true,
  "relocation_assistance": true,
  "visa_sponsorship": true,
  
  "target_start_date": "2025-03-01",
  "target_fill_date": "2025-02-15",
  
  "pipeline_template_id": "uuid",
  
  "team_members": [
    { "user_id": "uuid", "role": "recruiter" },
    { "user_id": "uuid", "role": "interviewer" }
  ],
  
  "status": "draft"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "reference_code": "JOB-2025-0001",
    "slug": "senior-software-engineer-sf-2025",
    ...
  }
}
```

**Business Logic:**
- Generate unique reference code
- Generate URL slug from title
- Copy pipeline stages from template
- Add creator as hiring manager if not specified
- Send notifications to team members
- Log audit event

---

#### Update Job
```
PATCH /jobs/{job_id}
```

**Permission Required:** `jobs.edit`

**Request:**
```json
{
  "title": "Updated Title",
  "description": "Updated description...",
  "salary_max": 220000,
  "positions_total": 3
}
```

**Business Logic:**
- Track all changes for audit
- If salary changed, update job postings
- If status changed, trigger notifications
- Update search index

---

#### Delete Job
```
DELETE /jobs/{job_id}
```

**Permission Required:** `jobs.delete`

**Query Parameters:**
- `permanent`: boolean (default: false)

**Business Logic:**
- Cannot delete with active applications (must archive)
- Soft delete by default
- Remove from job boards
- Log audit event

---

#### Duplicate Job
```
POST /jobs/{job_id}/duplicate
```

**Permission Required:** `jobs.create`

**Request:**
```json
{
  "title": "Senior Software Engineer - NYC",
  "location_id": "nyc_uuid",
  "copy_requirements": true,
  "copy_questions": true,
  "copy_pipeline": true,
  "copy_team": false
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "new_uuid",
    "reference_code": "JOB-2025-0002",
    ...
  }
}
```

---

### 5.2 Job Status Management

#### Publish Job
```
POST /jobs/{job_id}/publish
```

**Permission Required:** `jobs.publish`

**Request:**
```json
{
  "expires_at": "2025-02-28T23:59:59Z",
  "post_to_career_page": true
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "open",
    "published_at": "2025-01-15T10:30:00Z",
    "expires_at": "2025-02-28T23:59:59Z",
    "career_page_url": "https://careers.acme.com/jobs/senior-software-engineer-sf-2025"
  }
}
```

**Business Logic:**
- Validate all required fields are filled
- Set status to "open"
- Record published_at timestamp
- Add to career page if enabled
- Trigger notifications to team
- Log audit event

---

#### Pause Job
```
POST /jobs/{job_id}/pause
```

**Request:**
```json
{
  "reason": "Budget review in progress"
}
```

---

#### Resume Job
```
POST /jobs/{job_id}/resume
```

---

#### Close Job
```
POST /jobs/{job_id}/close
```

**Request:**
```json
{
  "reason": "position_filled",
  "send_rejection_emails": true,
  "rejection_template_id": "uuid"
}
```

**Business Logic:**
- Set status to "closed"
- Optionally send rejection emails to pending candidates
- Remove from job boards
- Record close reason
- Update statistics

---

#### Archive Job
```
POST /jobs/{job_id}/archive
```

---

### 5.3 Job Requirements

#### List Job Requirements
```
GET /jobs/{job_id}/requirements
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "skills": {
      "required": [
        {
          "id": "uuid",
          "skill": { "id": 1, "name": "JavaScript" },
          "min_years": 4,
          "priority": 1,
          "sort_order": 0
        }
      ],
      "preferred": [
        {
          "id": "uuid",
          "skill": { "id": 20, "name": "AWS" },
          "min_years": 2,
          "priority": 1,
          "sort_order": 0
        }
      ]
    },
    "education": [
      {
        "id": "uuid",
        "level": { "id": 3, "name": "Bachelor's Degree" },
        "field": { "id": 5, "name": "Computer Science" },
        "is_required": true
      }
    ],
    "certifications": [
      {
        "id": "uuid",
        "name": "AWS Solutions Architect",
        "is_required": false
      }
    ],
    "languages": [
      {
        "id": "uuid",
        "language": { "id": 1, "name": "English" },
        "level": "C1",
        "is_required": true
      }
    ],
    "other": [
      {
        "id": "uuid",
        "description": "Must be able to travel 25% of the time",
        "is_required": true
      }
    ]
  }
}
```

---

#### Add Requirement
```
POST /jobs/{job_id}/requirements
```

**Request:**
```json
{
  "requirement_type": "skill",
  "skill_id": 15,
  "is_required": true,
  "min_years": 3,
  "priority": 1
}
```

---

#### Update Requirement
```
PATCH /jobs/{job_id}/requirements/{requirement_id}
```

---

#### Delete Requirement
```
DELETE /jobs/{job_id}/requirements/{requirement_id}
```

---

#### Bulk Update Requirements
```
PUT /jobs/{job_id}/requirements
```

**Request:**
```json
{
  "requirements": [
    { "requirement_type": "skill", "skill_id": 1, "is_required": true, "min_years": 4 },
    { "requirement_type": "skill", "skill_id": 2, "is_required": true, "min_years": 3 },
    { "requirement_type": "skill", "skill_id": 20, "is_required": false, "min_years": 2 },
    { "requirement_type": "education", "education_level_id": 3, "is_required": true },
    { "requirement_type": "language", "language_id": 1, "language_level": "C1", "is_required": true }
  ]
}
```

---

### 5.4 Screening Questions

#### List Questions
```
GET /jobs/{job_id}/questions
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "question_text": "How many years of React experience do you have?",
      "question_type": "number",
      "is_required": true,
      "validation": {
        "min_value": 0,
        "max_value": 30
      },
      "scoring": {
        "has_scoring": true,
        "knockout_answer": null,
        "ideal_answer": "5",
        "max_score": 10
      },
      "placeholder": "Enter years",
      "help_text": "Include professional and personal projects",
      "sort_order": 0
    },
    {
      "id": "uuid",
      "question_text": "Are you authorized to work in the United States?",
      "question_type": "single_choice",
      "is_required": true,
      "options": [
        { "value": "yes", "label": "Yes", "score": 10 },
        { "value": "no", "label": "No", "score": 0 },
        { "value": "visa_required", "label": "Yes, with visa sponsorship", "score": 5 }
      ],
      "scoring": {
        "has_scoring": true,
        "knockout_answer": "no",
        "ideal_answer": "yes",
        "max_score": 10
      },
      "sort_order": 1
    },
    {
      "id": "uuid",
      "question_text": "Describe a challenging technical problem you solved.",
      "question_type": "textarea",
      "is_required": true,
      "validation": {
        "min_length": 100,
        "max_length": 2000
      },
      "scoring": {
        "has_scoring": false
      },
      "sort_order": 2
    }
  ]
}
```

---

#### Add Question
```
POST /jobs/{job_id}/questions
```

**Request:**
```json
{
  "question_text": "What is your expected salary?",
  "question_type": "number",
  "is_required": true,
  "min_value": 0,
  "max_value": 1000000,
  "placeholder": "Enter amount in USD",
  "help_text": "Annual salary expectation"
}
```

---

#### Update Question
```
PATCH /jobs/{job_id}/questions/{question_id}
```

---

#### Delete Question
```
DELETE /jobs/{job_id}/questions/{question_id}
```

---

#### Reorder Questions
```
POST /jobs/{job_id}/questions/reorder
```

**Request:**
```json
{
  "question_ids": ["uuid1", "uuid2", "uuid3"]
}
```

---

### 5.5 Job Pipeline

#### Get Pipeline Stages
```
GET /jobs/{job_id}/pipeline
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "stages": [
      {
        "id": "uuid",
        "name": "New",
        "stage_type": "application",
        "color": "#6B7280",
        "is_terminal": false,
        "is_rejection": false,
        "target_days": 3,
        "auto_email_template_id": null,
        "candidate_count": 12,
        "sort_order": 0
      },
      {
        "id": "uuid",
        "name": "Phone Screen",
        "stage_type": "interview",
        "color": "#3B82F6",
        "target_days": 5,
        "candidate_count": 5,
        "sort_order": 2
      }
    ],
    "statistics": {
      "conversion_rates": {
        "New -> Reviewed": 0.67,
        "Reviewed -> Phone Screen": 0.63,
        "Phone Screen -> Technical": 0.60,
        "Technical -> Onsite": 0.67,
        "Onsite -> Offer": 0.50,
        "Offer -> Hired": 0.80
      },
      "avg_time_in_stage": {
        "New": 2.5,
        "Reviewed": 3.2,
        "Phone Screen": 5.1
      }
    }
  }
}
```

---

#### Add Pipeline Stage
```
POST /jobs/{job_id}/pipeline/stages
```

**Request:**
```json
{
  "name": "Technical Assessment",
  "stage_type": "interview",
  "color": "#8B5CF6",
  "target_days": 7,
  "insert_after_stage_id": "uuid"
}
```

---

#### Update Pipeline Stage
```
PATCH /jobs/{job_id}/pipeline/stages/{stage_id}
```

---

#### Delete Pipeline Stage
```
DELETE /jobs/{job_id}/pipeline/stages/{stage_id}
```

**Query Parameters:**
- `move_candidates_to_stage_id`: UUID (required if stage has candidates)

---

#### Reorder Stages
```
POST /jobs/{job_id}/pipeline/stages/reorder
```

**Request:**
```json
{
  "stage_ids": ["uuid1", "uuid2", "uuid3", "uuid4"]
}
```

---

### 5.6 Job Team

#### List Team Members
```
GET /jobs/{job_id}/team
```

---

#### Add Team Member
```
POST /jobs/{job_id}/team
```

**Request:**
```json
{
  "user_id": "uuid",
  "role": "interviewer",
  "permissions": {
    "can_view_applications": true,
    "can_review_candidates": true,
    "can_schedule_interviews": false,
    "can_make_offers": false,
    "can_edit_job": false
  },
  "notifications": {
    "notify_new_applications": false,
    "notify_stage_changes": true,
    "notify_comments": true
  }
}
```

---

#### Update Team Member
```
PATCH /jobs/{job_id}/team/{team_member_id}
```

---

#### Remove Team Member
```
DELETE /jobs/{job_id}/team/{team_member_id}
```

---

### 5.7 Job Postings (Job Board Distribution)

#### List Job Postings
```
GET /jobs/{job_id}/postings
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "job_board": {
        "id": 1,
        "name": "LinkedIn",
        "code": "linkedin",
        "logo_url": "https://..."
      },
      "status": "active",
      "external_id": "linkedin_job_12345",
      "external_url": "https://linkedin.com/jobs/view/12345",
      "posted_at": "2025-01-10T12:00:00Z",
      "expires_at": "2025-02-10T23:59:59Z",
      "cost": {
        "amount": 299.99,
        "currency": "USD"
      },
      "is_sponsored": true,
      "statistics": {
        "views": 850,
        "clicks": 120,
        "applications": 25
      },
      "last_synced_at": "2025-01-15T10:00:00Z"
    }
  ]
}
```

---

#### Post to Job Board
```
POST /jobs/{job_id}/postings
```

**Request:**
```json
{
  "job_board_id": 1,
  "expires_at": "2025-02-28T23:59:59Z",
  "is_sponsored": true,
  "budget": 500
}
```

**Response (202):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "pending",
    "message": "Job posting is being processed"
  }
}
```

---

#### Update Job Posting
```
PATCH /jobs/{job_id}/postings/{posting_id}
```

---

#### Remove from Job Board
```
DELETE /jobs/{job_id}/postings/{posting_id}
```

---

#### Sync Job Posting
```
POST /jobs/{job_id}/postings/{posting_id}/sync
```

---

### 5.8 Pipeline Templates

#### List Pipeline Templates
```
GET /pipeline-templates
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Standard Hiring Pipeline",
      "description": "Default pipeline for most positions",
      "is_default": true,
      "stages": [
        { "name": "New", "stage_type": "application", "sort_order": 0 },
        { "name": "Reviewed", "stage_type": "screening", "sort_order": 1 },
        { "name": "Phone Screen", "stage_type": "interview", "sort_order": 2 },
        { "name": "Technical Interview", "stage_type": "interview", "sort_order": 3 },
        { "name": "Onsite", "stage_type": "interview", "sort_order": 4 },
        { "name": "Offer", "stage_type": "offer", "sort_order": 5 },
        { "name": "Hired", "stage_type": "hired", "sort_order": 6, "is_terminal": true },
        { "name": "Rejected", "stage_type": "rejected", "sort_order": 7, "is_terminal": true, "is_rejection": true }
      ],
      "usage_count": 15,
      "created_at": "2024-06-15T10:00:00Z"
    },
    {
      "id": "uuid",
      "name": "Executive Hiring",
      "description": "Extended pipeline for executive positions",
      "is_default": false,
      "stages": [ ... ]
    }
  ]
}
```

---

#### Create Pipeline Template
```
POST /pipeline-templates
```

**Request:**
```json
{
  "name": "Engineering Pipeline",
  "description": "Pipeline with technical assessment stage",
  "stages": [
    { "name": "New", "stage_type": "application", "target_days": 2 },
    { "name": "Resume Review", "stage_type": "screening", "target_days": 3 },
    { "name": "Technical Assessment", "stage_type": "interview", "target_days": 5 },
    { "name": "Technical Interview", "stage_type": "interview", "target_days": 5 },
    { "name": "Culture Fit", "stage_type": "interview", "target_days": 3 },
    { "name": "Offer", "stage_type": "offer", "target_days": 3 },
    { "name": "Hired", "stage_type": "hired", "is_terminal": true },
    { "name": "Rejected", "stage_type": "rejected", "is_terminal": true, "is_rejection": true }
  ]
}
```

---

#### Update Pipeline Template
```
PATCH /pipeline-templates/{template_id}
```

---

#### Delete Pipeline Template
```
DELETE /pipeline-templates/{template_id}
```

---

#### Set Default Template
```
POST /pipeline-templates/{template_id}/set-default
```

---

### 5.9 Job Analytics

#### Get Job Analytics
```
GET /jobs/{job_id}/analytics
```

**Query Parameters:**
- `from_date`: ISO date
- `to_date`: ISO date
- `granularity`: `day` | `week` | `month`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_applications": 145,
      "qualified_applications": 89,
      "interviews_scheduled": 34,
      "offers_made": 5,
      "hires": 2,
      "avg_time_to_hire_days": 28,
      "conversion_rate": 0.014
    },
    "funnel": {
      "stages": [
        { "name": "Applied", "count": 145, "percentage": 100 },
        { "name": "Reviewed", "count": 120, "percentage": 82.8 },
        { "name": "Phone Screen", "count": 45, "percentage": 31.0 },
        { "name": "Technical", "count": 25, "percentage": 17.2 },
        { "name": "Onsite", "count": 12, "percentage": 8.3 },
        { "name": "Offer", "count": 5, "percentage": 3.4 },
        { "name": "Hired", "count": 2, "percentage": 1.4 }
      ]
    },
    "sources": [
      { "source": "linkedin", "applications": 65, "hires": 1, "cost_per_hire": 299.99 },
      { "source": "indeed", "applications": 45, "hires": 1, "cost_per_hire": 0 },
      { "source": "referral", "applications": 20, "hires": 0, "cost_per_hire": null },
      { "source": "career_site", "applications": 15, "hires": 0, "cost_per_hire": null }
    ],
    "timeline": [
      { "date": "2025-01-08", "applications": 12, "views": 150 },
      { "date": "2025-01-09", "applications": 18, "views": 180 },
      { "date": "2025-01-10", "applications": 25, "views": 220 }
    ],
    "quality_metrics": {
      "avg_match_score": 72.5,
      "avg_screening_score": 68.3,
      "top_skills_matched": ["JavaScript", "React", "Node.js"],
      "missing_skills": ["Kubernetes", "AWS"]
    }
  }
}
```
