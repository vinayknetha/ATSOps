## 4. Candidates

### 4.1 Candidate CRUD

#### List Candidates
```
GET /candidates
```

**Headers:** `Authorization: Bearer <access_token>`  
**Permission Required:** `candidates.view`

**Query Parameters:**
- `page`: integer (default: 1)
- `per_page`: integer (default: 20, max: 100)
- `search`: string (full-text search on name, email, headline, skills)
- `status`: `active` | `passive` | `not_looking` | `archived`
- `source`: candidate_source enum
- `skills`: comma-separated skill IDs
- `min_experience`: decimal (years)
- `max_experience`: decimal (years)
- `location_country_id`: integer
- `location_city_id`: integer
- `willing_to_relocate`: boolean
- `workplace_type`: `onsite` | `remote` | `hybrid`
- `has_portfolio`: boolean
- `tags`: comma-separated tag slugs
- `created_from`: ISO date
- `created_to`: ISO date
- `sort_by`: `name` | `created_at` | `experience` | `match_score`
- `sort_dir`: `asc` | `desc`
- `job_id`: UUID (for matching - returns match scores)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "email": "candidate@email.com",
      "first_name": "John",
      "last_name": "Doe",
      "headline": "Senior Software Engineer with 8+ years experience",
      "current_title": "Senior Software Engineer",
      "current_company": "Tech Corp",
      "location": {
        "city": "San Francisco",
        "state": "California",
        "country": "United States"
      },
      "total_experience_years": 8.5,
      "source": "linkedin",
      "status": "active",
      "skills_preview": ["JavaScript", "React", "Node.js", "AWS"],
      "tags": ["senior", "frontend"],
      "portfolio_url": "https://talentforge.io/p/john-doe",
      "match_score": 87.5,
      "has_active_applications": true,
      "active_applications_count": 2,
      "created_at": "2025-01-10T10:00:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

#### Get Candidate Details
```
GET /candidates/{candidate_id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "john.doe@email.com",
    "secondary_email": "johnd@gmail.com",
    "phone": "+1-555-123-4567",
    "secondary_phone": null,
    
    "first_name": "John",
    "last_name": "Doe",
    "middle_name": null,
    "preferred_name": "Johnny",
    
    "headline": "Senior Software Engineer with 8+ years experience",
    "current_title": "Senior Software Engineer",
    "current_company": "Tech Corp",
    
    "location": {
      "address_line1": "123 Main St",
      "city": { "id": 1234, "name": "San Francisco" },
      "state": { "id": 5, "name": "California" },
      "country": { "id": 1, "name": "United States" },
      "postal_code": "94105",
      "timezone": "America/Los_Angeles"
    },
    
    "work_preferences": {
      "willing_to_relocate": true,
      "preferred_locations": ["New York", "Los Angeles", "Remote"],
      "preferred_workplace_type": "hybrid",
      "preferred_job_types": ["full_time", "contract"]
    },
    
    "compensation": {
      "current_salary": {
        "amount": 150000,
        "currency": "USD"
      },
      "expected_salary": {
        "min": 160000,
        "max": 200000,
        "currency": "USD",
        "negotiable": true
      }
    },
    
    "experience_summary": {
      "total_years": 8.5,
      "total_months": 102
    },
    
    "source": {
      "type": "linkedin",
      "details": "Applied via LinkedIn Jobs",
      "referrer": null
    },
    
    "social_links": {
      "linkedin_url": "https://linkedin.com/in/johndoe",
      "github_url": "https://github.com/johndoe",
      "portfolio_url": "https://johndoe.dev",
      "twitter_url": "https://twitter.com/johndoe"
    },
    
    "resume": {
      "url": "https://cdn.talentforge.io/resumes/uuid.pdf",
      "text": "Extracted resume text...",
      "parsed_at": "2025-01-10T10:05:00Z",
      "parsing_confidence": 0.94
    },
    
    "profile_summary": "Passionate software engineer with expertise in...",
    
    "portfolio": {
      "generated": true,
      "slug": "john-doe",
      "url": "https://talentforge.io/p/john-doe",
      "theme": "professional-dark",
      "views": 145
    },
    
    "status": "active",
    "availability": {
      "date": "2025-02-01",
      "notice_period_days": 30
    },
    
    "tags": ["senior", "frontend", "leadership"],
    "internal_notes": "Strong candidate, interviewed last year",
    
    "privacy": {
      "do_not_contact": false,
      "gdpr_consent_at": "2025-01-10T10:00:00Z",
      "marketing_consent": true
    },
    
    "statistics": {
      "applications_count": 3,
      "active_applications": 2,
      "interviews_count": 5,
      "offers_received": 1
    },
    
    "created_at": "2025-01-10T10:00:00Z",
    "updated_at": "2025-01-15T08:00:00Z"
  }
}
```

---

#### Create Candidate
```
POST /candidates
```

**Permission Required:** `candidates.create`

**Request:**
```json
{
  "email": "new.candidate@email.com",
  "first_name": "New",
  "last_name": "Candidate",
  "phone": "+1-555-987-6543",
  "headline": "Product Manager with 5 years experience",
  "current_title": "Product Manager",
  "current_company": "Startup Inc",
  "source": "referral",
  "source_details": "Referred by John Smith",
  "referrer_user_id": "uuid",
  "location": {
    "city_id": 1234,
    "country_id": 1
  },
  "linkedin_url": "https://linkedin.com/in/newcandidate",
  "tags": ["product", "startup-experience"]
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    ...
  }
}
```

---

#### Update Candidate
```
PATCH /candidates/{candidate_id}
```

**Permission Required:** `candidates.edit`

**Request:**
```json
{
  "headline": "Updated headline",
  "phone": "+1-555-111-2222",
  "status": "passive",
  "tags": ["senior", "updated-tag"],
  "internal_notes": "Updated notes"
}
```

---

#### Delete Candidate
```
DELETE /candidates/{candidate_id}
```

**Permission Required:** `candidates.delete`

**Query Parameters:**
- `permanent`: boolean (default: false - soft delete)

**Business Logic:**
- Soft delete by default (GDPR data retention)
- Check for active applications
- Archive related documents
- Log audit event

---

#### Bulk Import Candidates
```
POST /candidates/import
```

**Permission Required:** `candidates.create`

**Request (multipart/form-data):**
```
file: [CSV or Excel file]
source: direct_apply
source_details: "Bulk import from job fair"
skip_duplicates: true
send_confirmation_email: false
```

**Response (202):**
```json
{
  "success": true,
  "data": {
    "import_id": "uuid",
    "status": "processing",
    "total_rows": 150,
    "estimated_completion": "2025-01-15T10:35:00Z"
  }
}
```

---

#### Get Import Status
```
GET /candidates/import/{import_id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "import_id": "uuid",
    "status": "completed",
    "total_rows": 150,
    "processed": 150,
    "created": 142,
    "updated": 0,
    "skipped": 5,
    "failed": 3,
    "errors": [
      { "row": 45, "error": "Invalid email format" },
      { "row": 78, "error": "Missing required field: first_name" }
    ],
    "completed_at": "2025-01-15T10:33:00Z"
  }
}
```

---

### 4.2 Candidate Experience

#### List Candidate Experience
```
GET /candidates/{candidate_id}/experience
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "company": {
        "name": "Tech Corp",
        "linkedin_url": "https://linkedin.com/company/techcorp",
        "industry": { "id": 1, "name": "Technology" },
        "size": "1001-5000"
      },
      "title": "Senior Software Engineer",
      "department": "Engineering",
      "employment_type": "full_time",
      "location": {
        "city": "San Francisco",
        "country": "United States",
        "is_remote": false
      },
      "dates": {
        "start_date": "2021-03-01",
        "end_date": null,
        "is_current": true,
        "duration_months": 46
      },
      "description": "Led development of microservices architecture...",
      "responsibilities": "- Designed scalable systems\n- Mentored junior developers",
      "achievements": "- Reduced load time by 40%\n- Led team of 5 engineers",
      "skills": [
        { "id": 1, "name": "JavaScript" },
        { "id": 2, "name": "React" },
        { "id": 3, "name": "Node.js" }
      ],
      "is_verified": false,
      "sort_order": 0
    },
    {
      "id": "uuid",
      "company": {
        "name": "StartupXYZ",
        ...
      },
      "title": "Software Engineer",
      "dates": {
        "start_date": "2018-06-01",
        "end_date": "2021-02-28",
        "is_current": false,
        "duration_months": 33
      },
      ...
    }
  ]
}
```

---

#### Add Experience
```
POST /candidates/{candidate_id}/experience
```

**Request:**
```json
{
  "company_name": "New Company",
  "company_linkedin_url": "https://linkedin.com/company/newcompany",
  "title": "Product Manager",
  "department": "Product",
  "employment_type": "full_time",
  "location_city_id": 1234,
  "is_remote": false,
  "start_date": "2020-01-15",
  "end_date": "2023-06-30",
  "is_current": false,
  "description": "Managed product development...",
  "skill_ids": [10, 15, 22]
}
```

---

#### Update Experience
```
PATCH /candidates/{candidate_id}/experience/{experience_id}
```

---

#### Delete Experience
```
DELETE /candidates/{candidate_id}/experience/{experience_id}
```

---

### 4.3 Candidate Education

#### List Education
```
GET /candidates/{candidate_id}/education
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "institution": {
        "name": "Stanford University",
        "type": "university",
        "country": "United States",
        "city": "Stanford"
      },
      "degree": {
        "level": { "id": 3, "name": "Bachelor's Degree" },
        "name": "Bachelor of Science",
        "field": { "id": 5, "name": "Computer Science" },
        "major": "Computer Science",
        "minor": "Mathematics"
      },
      "dates": {
        "start_date": "2012-09-01",
        "end_date": "2016-05-15",
        "is_current": false
      },
      "performance": {
        "gpa": 3.8,
        "gpa_scale": 4.0,
        "honors": "Cum Laude"
      },
      "activities": "Computer Science Club, Hackathon organizer",
      "is_verified": false,
      "sort_order": 0
    }
  ]
}
```

---

#### Add Education
```
POST /candidates/{candidate_id}/education
```

**Request:**
```json
{
  "institution_name": "MIT",
  "institution_type": "university",
  "institution_country_id": 1,
  "education_level_id": 4,
  "degree_name": "Master of Science",
  "field_of_study_id": 5,
  "major": "Artificial Intelligence",
  "start_date": "2016-09-01",
  "end_date": "2018-05-15",
  "gpa": 3.9,
  "gpa_scale": 4.0
}
```

---

### 4.4 Candidate Skills

#### List Candidate Skills
```
GET /candidates/{candidate_id}/skills
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "skill": {
        "id": 1,
        "name": "JavaScript",
        "category": "Programming Languages"
      },
      "proficiency_level": "expert",
      "proficiency_score": 9,
      "years_of_experience": 8,
      "source": "parsed",
      "is_primary": true,
      "last_used_date": "2025-01-15",
      "is_verified": false
    },
    {
      "id": "uuid",
      "skill": {
        "id": 2,
        "name": "React",
        "category": "Frameworks & Libraries"
      },
      "proficiency_level": "advanced",
      "proficiency_score": 8,
      "years_of_experience": 5,
      ...
    }
  ]
}
```

---

#### Add Skill
```
POST /candidates/{candidate_id}/skills
```

**Request:**
```json
{
  "skill_id": 15,
  "proficiency_level": "advanced",
  "proficiency_score": 7,
  "years_of_experience": 3,
  "is_primary": false
}
```

---

#### Bulk Update Skills
```
PUT /candidates/{candidate_id}/skills
```

**Request:**
```json
{
  "skills": [
    { "skill_id": 1, "proficiency_level": "expert", "is_primary": true },
    { "skill_id": 2, "proficiency_level": "advanced", "is_primary": true },
    { "skill_id": 15, "proficiency_level": "intermediate", "is_primary": false }
  ]
}
```

---

### 4.5 Other Candidate Data

#### Certifications
```
GET /candidates/{candidate_id}/certifications
POST /candidates/{candidate_id}/certifications
PATCH /candidates/{candidate_id}/certifications/{certification_id}
DELETE /candidates/{candidate_id}/certifications/{certification_id}
```

#### Languages
```
GET /candidates/{candidate_id}/languages
POST /candidates/{candidate_id}/languages
PATCH /candidates/{candidate_id}/languages/{language_id}
DELETE /candidates/{candidate_id}/languages/{language_id}
```

#### Projects
```
GET /candidates/{candidate_id}/projects
POST /candidates/{candidate_id}/projects
PATCH /candidates/{candidate_id}/projects/{project_id}
DELETE /candidates/{candidate_id}/projects/{project_id}
```

#### Publications
```
GET /candidates/{candidate_id}/publications
POST /candidates/{candidate_id}/publications
PATCH /candidates/{candidate_id}/publications/{publication_id}
DELETE /candidates/{candidate_id}/publications/{publication_id}
```

#### Awards
```
GET /candidates/{candidate_id}/awards
POST /candidates/{candidate_id}/awards
PATCH /candidates/{candidate_id}/awards/{award_id}
DELETE /candidates/{candidate_id}/awards/{award_id}
```

#### References
```
GET /candidates/{candidate_id}/references
POST /candidates/{candidate_id}/references
PATCH /candidates/{candidate_id}/references/{reference_id}
DELETE /candidates/{candidate_id}/references/{reference_id}
```

---

### 4.6 Candidate Resume

#### Upload Resume
```
POST /candidates/{candidate_id}/resume
```

**Request (multipart/form-data):**
```
file: [PDF, DOC, DOCX file]
parse: true
```

**Response (202):**
```json
{
  "success": true,
  "data": {
    "document_id": "uuid",
    "file_url": "https://cdn.talentforge.io/resumes/uuid.pdf",
    "status": "parsing",
    "parsing_job_id": "uuid"
  }
}
```

---

#### Get Resume Parsing Status
```
GET /candidates/{candidate_id}/resume/parsing-status
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "status": "completed",
    "parsing_confidence": 0.94,
    "parsed_at": "2025-01-15T10:05:00Z",
    "extracted_data": {
      "contact": { ... },
      "experience": [ ... ],
      "education": [ ... ],
      "skills": [ ... ]
    },
    "suggestions": {
      "missing_fields": ["phone"],
      "unmatched_skills": ["CustomFramework"],
      "date_inconsistencies": []
    }
  }
}
```

---

#### Download Resume
```
GET /candidates/{candidate_id}/resume/download
```

**Response:** File download (PDF/DOCX)

---

### 4.7 Candidate Portfolio

#### Generate Portfolio
```
POST /candidates/{candidate_id}/portfolio/generate
```

**Request:**
```json
{
  "theme": "professional-dark",
  "sections": ["hero", "about", "experience", "skills", "education", "projects", "contact"],
  "custom_slug": "john-doe-dev"
}
```

**Response (202):**
```json
{
  "success": true,
  "data": {
    "portfolio_id": "uuid",
    "status": "generating",
    "estimated_completion": "2025-01-15T10:32:00Z"
  }
}
```

---

#### Get Portfolio
```
GET /candidates/{candidate_id}/portfolio
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "slug": "john-doe-dev",
    "url": "https://talentforge.io/p/john-doe-dev",
    "theme": "professional-dark",
    "sections": ["hero", "about", "experience", "skills", "education", "projects", "contact"],
    "settings": {
      "primary_color": "#4F46E5",
      "show_contact_form": true,
      "show_resume_download": true
    },
    "analytics": {
      "total_views": 145,
      "unique_visitors": 89,
      "contact_form_submissions": 3,
      "resume_downloads": 12
    },
    "is_published": true,
    "generated_at": "2025-01-10T10:30:00Z"
  }
}
```

---

#### Update Portfolio Settings
```
PATCH /candidates/{candidate_id}/portfolio
```

**Request:**
```json
{
  "theme": "minimal-light",
  "settings": {
    "primary_color": "#10B981",
    "show_contact_form": false
  }
}
```

---

#### Publish/Unpublish Portfolio
```
POST /candidates/{candidate_id}/portfolio/publish
POST /candidates/{candidate_id}/portfolio/unpublish
```

---

### 4.8 Candidate Tags

#### Add Tags
```
POST /candidates/{candidate_id}/tags
```

**Request:**
```json
{
  "tags": ["senior", "high-priority", "frontend"]
}
```

---

#### Remove Tag
```
DELETE /candidates/{candidate_id}/tags/{tag_slug}
```

---

### 4.9 Candidate Applications

#### List Candidate Applications
```
GET /candidates/{candidate_id}/applications
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "job": {
        "id": "uuid",
        "title": "Senior Software Engineer",
        "department": "Engineering",
        "location": "San Francisco"
      },
      "current_stage": {
        "id": "uuid",
        "name": "Interview",
        "stage_type": "interview"
      },
      "status": "interviewing",
      "overall_score": 87.5,
      "applied_at": "2025-01-10T10:00:00Z",
      "last_activity_at": "2025-01-15T08:00:00Z"
    }
  ]
}
```

---

### 4.10 Candidate Activity Timeline

#### Get Candidate Timeline
```
GET /candidates/{candidate_id}/timeline
```

**Query Parameters:**
- `page`, `per_page`
- `activity_types`: comma-separated types
- `from_date`, `to_date`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "activity_type": "stage_changed",
      "title": "Moved to Interview stage",
      "description": "Application for Senior Software Engineer",
      "user": {
        "id": "uuid",
        "name": "Jane Smith"
      },
      "metadata": {
        "from_stage": "Reviewed",
        "to_stage": "Interview",
        "job_id": "uuid"
      },
      "created_at": "2025-01-15T10:00:00Z"
    },
    {
      "id": "uuid",
      "activity_type": "note_added",
      "title": "Note added",
      "description": "Strong technical background, schedule interview",
      "user": { ... },
      "created_at": "2025-01-14T16:00:00Z"
    },
    {
      "id": "uuid",
      "activity_type": "created",
      "title": "Candidate created",
      "description": "Added via LinkedIn import",
      "created_at": "2025-01-10T10:00:00Z"
    }
  ],
  "pagination": { ... }
}
```
