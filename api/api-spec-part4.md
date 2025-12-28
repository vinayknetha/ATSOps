## 6. Applications

### 6.1 Application CRUD

#### List Applications
```
GET /applications
```

**Headers:** `Authorization: Bearer <access_token>`  
**Permission Required:** `applications.view`

**Query Parameters:**
- `page`, `per_page`
- `job_id`: UUID (filter by job)
- `candidate_id`: UUID (filter by candidate)
- `stage_id`: UUID (filter by pipeline stage)
- `status`: `new` | `reviewed` | `shortlisted` | `interviewing` | `offer` | `hired` | `rejected` | `withdrawn`
- `source`: candidate_source enum
- `min_score`: decimal (0-100)
- `max_score`: decimal (0-100)
- `is_starred`: boolean
- `has_interview`: boolean
- `applied_from`: ISO date
- `applied_to`: ISO date
- `sort_by`: `applied_at` | `score` | `last_activity` | `candidate_name`
- `sort_dir`: `asc` | `desc`

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
        "reference_code": "JOB-2024-0042"
      },
      "candidate": {
        "id": "uuid",
        "name": "John Doe",
        "email": "john@email.com",
        "avatar_url": "https://...",
        "current_title": "Software Engineer",
        "current_company": "Tech Corp"
      },
      "current_stage": {
        "id": "uuid",
        "name": "Technical Interview",
        "stage_type": "interview",
        "color": "#3B82F6"
      },
      "status": "interviewing",
      "scores": {
        "overall": 87.5,
        "required_skills": 92.0,
        "preferred_skills": 75.0,
        "experience": 90.0,
        "education": 85.0,
        "screening": 88.0
      },
      "ai_recommendation": "strong_yes",
      "source": "linkedin",
      "recruiter_rating": 4,
      "is_starred": true,
      "upcoming_interview": {
        "id": "uuid",
        "type": "Technical Interview",
        "scheduled_at": "2025-01-20T14:00:00Z"
      },
      "days_in_stage": 3,
      "applied_at": "2025-01-10T10:00:00Z",
      "last_activity_at": "2025-01-15T14:30:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

#### Get Application Details
```
GET /applications/{application_id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    
    "job": {
      "id": "uuid",
      "title": "Senior Software Engineer",
      "reference_code": "JOB-2024-0042",
      "department": "Engineering",
      "location": "San Francisco",
      "status": "open"
    },
    
    "candidate": {
      "id": "uuid",
      "name": "John Doe",
      "email": "john@email.com",
      "phone": "+1-555-123-4567",
      "avatar_url": "https://...",
      "headline": "Senior Software Engineer",
      "current_title": "Software Engineer",
      "current_company": "Tech Corp",
      "location": "San Francisco, CA",
      "experience_years": 8.5,
      "linkedin_url": "https://linkedin.com/in/johndoe",
      "portfolio_url": "https://talentforge.io/p/john-doe"
    },
    
    "current_stage": {
      "id": "uuid",
      "name": "Technical Interview",
      "stage_type": "interview",
      "color": "#3B82F6",
      "entered_at": "2025-01-12T10:00:00Z",
      "days_in_stage": 3,
      "target_days": 5
    },
    
    "status": "interviewing",
    
    "scores": {
      "overall": 87.5,
      "breakdown": {
        "required_skills": {
          "score": 92.0,
          "weight": 0.40,
          "contribution": 36.8,
          "matched": 8,
          "total": 10
        },
        "preferred_skills": {
          "score": 75.0,
          "weight": 0.25,
          "contribution": 18.75,
          "matched": 3,
          "total": 5
        },
        "experience": {
          "score": 90.0,
          "weight": 0.20,
          "contribution": 18.0,
          "required_years": 5,
          "candidate_years": 8.5
        },
        "education": {
          "score": 85.0,
          "weight": 0.10,
          "contribution": 8.5,
          "required_level": "Bachelor's",
          "candidate_level": "Master's"
        },
        "location": {
          "score": 100.0,
          "weight": 0.05,
          "contribution": 5.0,
          "match": "exact"
        }
      },
      "screening_score": 88.0,
      "interview_score": null
    },
    
    "ai_analysis": {
      "recommendation": "strong_yes",
      "confidence": 0.92,
      "summary": "Strong candidate with excellent technical skills and relevant experience. Exceeds requirements in most areas.",
      "strengths": [
        "8+ years of relevant experience",
        "Strong expertise in required technologies",
        "Leadership experience at current company",
        "MS degree from top university"
      ],
      "concerns": [
        "No direct Kubernetes experience",
        "Current salary may be above budget"
      ],
      "suggested_interview_focus": [
        "System design capabilities",
        "Team leadership experience",
        "Kubernetes learning curve"
      ]
    },
    
    "skill_matches": [
      {
        "requirement": { "skill": "JavaScript", "required": true, "min_years": 4 },
        "candidate": { "skill": "JavaScript", "years": 8, "proficiency": "expert" },
        "match_type": "exact",
        "match_score": 100
      },
      {
        "requirement": { "skill": "Kubernetes", "required": false, "min_years": 1 },
        "candidate": null,
        "match_type": "none",
        "match_score": 0
      }
    ],
    
    "screening_answers": [
      {
        "question": "How many years of React experience do you have?",
        "answer": "6",
        "score": 10,
        "max_score": 10
      },
      {
        "question": "Are you authorized to work in the United States?",
        "answer": "Yes",
        "score": 10,
        "max_score": 10,
        "is_knockout": false
      },
      {
        "question": "Describe a challenging technical problem you solved.",
        "answer": "At my current company, I led the migration of our monolithic...",
        "score": null,
        "max_score": null
      }
    ],
    
    "resume": {
      "url": "https://cdn.talentforge.io/resumes/uuid.pdf",
      "uploaded_at": "2025-01-10T10:00:00Z"
    },
    
    "cover_letter": "Dear Hiring Manager,\n\nI am excited to apply for the Senior Software Engineer position...",
    
    "source": {
      "type": "linkedin",
      "details": "Applied via LinkedIn Jobs",
      "job_posting_id": "uuid",
      "referrer": null
    },
    
    "recruiter_evaluation": {
      "rating": 4,
      "notes": "Strong candidate, technical skills are excellent. Salary expectations might be high."
    },
    
    "interviews": [
      {
        "id": "uuid",
        "type": "Phone Screen",
        "status": "completed",
        "scheduled_at": "2025-01-12T14:00:00Z",
        "overall_score": 4,
        "recommendation": "yes"
      },
      {
        "id": "uuid",
        "type": "Technical Interview",
        "status": "scheduled",
        "scheduled_at": "2025-01-20T14:00:00Z",
        "interviewers": ["Jane Smith", "Bob Johnson"]
      }
    ],
    
    "offers": [],
    
    "stage_history": [
      {
        "stage": "New",
        "entered_at": "2025-01-10T10:00:00Z",
        "exited_at": "2025-01-10T15:00:00Z",
        "duration_hours": 5,
        "moved_by": { "id": "uuid", "name": "System" }
      },
      {
        "stage": "Reviewed",
        "entered_at": "2025-01-10T15:00:00Z",
        "exited_at": "2025-01-11T10:00:00Z",
        "duration_hours": 19,
        "moved_by": { "id": "uuid", "name": "Jane Smith" }
      },
      {
        "stage": "Phone Screen",
        "entered_at": "2025-01-11T10:00:00Z",
        "exited_at": "2025-01-12T16:00:00Z",
        "duration_hours": 30,
        "moved_by": { "id": "uuid", "name": "Jane Smith" }
      },
      {
        "stage": "Technical Interview",
        "entered_at": "2025-01-12T16:00:00Z",
        "exited_at": null,
        "duration_hours": null,
        "moved_by": { "id": "uuid", "name": "Jane Smith" }
      }
    ],
    
    "tags": ["high-priority", "senior"],
    "is_starred": true,
    "is_archived": false,
    
    "applied_at": "2025-01-10T10:00:00Z",
    "last_activity_at": "2025-01-15T14:30:00Z",
    "created_at": "2025-01-10T10:00:00Z"
  }
}
```

---

#### Create Application (Apply for Job)
```
POST /applications
```

**Permission Required:** `applications.manage` OR public application endpoint

**Request:**
```json
{
  "job_id": "uuid",
  "candidate_id": "uuid",
  "source": "referral",
  "source_details": "Referred by employee",
  "referrer_user_id": "uuid",
  "resume_document_id": "uuid",
  "cover_letter": "Dear Hiring Manager...",
  "screening_answers": [
    { "question_id": "uuid", "answer_text": "6" },
    { "question_id": "uuid", "answer_value": "yes" },
    { "question_id": "uuid", "answer_text": "At my current company..." }
  ]
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "job_id": "uuid",
    "candidate_id": "uuid",
    "current_stage_id": "uuid",
    "status": "new",
    "overall_score": 87.5,
    "applied_at": "2025-01-15T10:30:00Z"
  }
}
```

**Business Logic:**
- Check for duplicate application
- Validate screening answers
- Calculate match score using AI
- Generate AI analysis
- Place in first pipeline stage
- Send confirmation email to candidate
- Notify hiring team
- Log audit event

---

#### Public Application Endpoint (No Auth)
```
POST /apply/{job_slug}
```

**Request (multipart/form-data):**
```
email: john@email.com
first_name: John
last_name: Doe
phone: +1-555-123-4567
resume: [file]
cover_letter: Dear Hiring Manager...
linkedin_url: https://linkedin.com/in/johndoe
answers[question_id_1]: 6
answers[question_id_2]: yes
gdpr_consent: true
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "application_id": "uuid",
    "message": "Application submitted successfully",
    "confirmation_email_sent": true
  }
}
```

**Business Logic:**
- Create or update candidate record
- Parse resume
- Create application
- Send confirmation email
- Return public-safe response

---

#### Update Application
```
PATCH /applications/{application_id}
```

**Request:**
```json
{
  "recruiter_rating": 5,
  "recruiter_notes": "Updated notes...",
  "tags": ["high-priority", "senior", "urgent"]
}
```

---

#### Delete Application
```
DELETE /applications/{application_id}
```

**Permission Required:** `applications.manage`

---

### 6.2 Application Stage Management

#### Move to Stage
```
POST /applications/{application_id}/move-stage
```

**Permission Required:** `applications.move_stage`

**Request:**
```json
{
  "stage_id": "uuid",
  "reason": "Passed phone screen with flying colors",
  "send_email": true,
  "email_template_id": "uuid"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "previous_stage": {
      "id": "uuid",
      "name": "Phone Screen"
    },
    "current_stage": {
      "id": "uuid",
      "name": "Technical Interview"
    },
    "moved_at": "2025-01-15T10:30:00Z",
    "moved_by": { "id": "uuid", "name": "Jane Smith" }
  }
}
```

**Business Logic:**
- Validate stage transition is allowed
- Record stage history
- Execute stage entry actions (if configured)
- Send automated email (if configured)
- Update statistics
- Notify relevant team members
- Log audit event

---

#### Bulk Move to Stage
```
POST /applications/bulk-move-stage
```

**Request:**
```json
{
  "application_ids": ["uuid1", "uuid2", "uuid3"],
  "stage_id": "uuid",
  "reason": "Batch advancement after review",
  "send_email": true,
  "email_template_id": "uuid"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "moved": 3,
    "failed": 0,
    "results": [
      { "application_id": "uuid1", "success": true },
      { "application_id": "uuid2", "success": true },
      { "application_id": "uuid3", "success": true }
    ]
  }
}
```

---

#### Reject Application
```
POST /applications/{application_id}/reject
```

**Request:**
```json
{
  "rejection_reason_id": "uuid",
  "notes": "Candidate doesn't meet minimum experience requirements",
  "send_email": true,
  "email_template_id": "uuid"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "rejected",
    "outcome": "rejected",
    "outcome_at": "2025-01-15T10:30:00Z"
  }
}
```

---

#### Bulk Reject Applications
```
POST /applications/bulk-reject
```

**Request:**
```json
{
  "application_ids": ["uuid1", "uuid2", "uuid3"],
  "rejection_reason_id": "uuid",
  "send_email": true,
  "email_template_id": "uuid"
}
```

---

#### Withdraw Application
```
POST /applications/{application_id}/withdraw
```

**Request:**
```json
{
  "reason": "Candidate accepted another offer"
}
```

---

#### Restore Application
```
POST /applications/{application_id}/restore
```

**Request:**
```json
{
  "stage_id": "uuid",
  "reason": "Candidate reconsidering, restore to pipeline"
}
```

---

### 6.3 Application Actions

#### Star/Unstar Application
```
POST /applications/{application_id}/star
DELETE /applications/{application_id}/star
```

---

#### Archive/Unarchive Application
```
POST /applications/{application_id}/archive
POST /applications/{application_id}/unarchive
```

---

#### Add Tags
```
POST /applications/{application_id}/tags
```

**Request:**
```json
{
  "tags": ["high-priority", "urgent"]
}
```

---

#### Remove Tag
```
DELETE /applications/{application_id}/tags/{tag_slug}
```

---

#### Mark as Duplicate
```
POST /applications/{application_id}/mark-duplicate
```

**Request:**
```json
{
  "duplicate_of_id": "uuid"
}
```

---

### 6.4 Application Scoring

#### Recalculate Score
```
POST /applications/{application_id}/recalculate-score
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "previous_score": 85.0,
    "new_score": 87.5,
    "breakdown": { ... },
    "recalculated_at": "2025-01-15T10:30:00Z"
  }
}
```

---

#### Get Score Breakdown
```
GET /applications/{application_id}/score-breakdown
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "overall_score": 87.5,
    "calculated_at": "2025-01-15T10:30:00Z",
    "weights": {
      "required_skills": 0.40,
      "preferred_skills": 0.25,
      "experience": 0.20,
      "education": 0.10,
      "location": 0.05
    },
    "components": {
      "required_skills": {
        "score": 92.0,
        "contribution": 36.8,
        "details": [
          { "skill": "JavaScript", "required_years": 4, "candidate_years": 8, "match": true, "score": 100 },
          { "skill": "React", "required_years": 3, "candidate_years": 5, "match": true, "score": 100 },
          { "skill": "Node.js", "required_years": 3, "candidate_years": 6, "match": true, "score": 100 },
          { "skill": "PostgreSQL", "required_years": 2, "candidate_years": 3, "match": true, "score": 100 },
          { "skill": "System Design", "required_years": null, "candidate_years": null, "match": false, "score": 0 }
        ]
      },
      "preferred_skills": {
        "score": 75.0,
        "contribution": 18.75,
        "details": [
          { "skill": "AWS", "match": true, "score": 100 },
          { "skill": "Docker", "match": true, "score": 100 },
          { "skill": "Kubernetes", "match": false, "score": 0 }
        ]
      },
      "experience": {
        "score": 90.0,
        "contribution": 18.0,
        "details": {
          "required_min": 5,
          "required_max": 10,
          "candidate_years": 8.5,
          "within_range": true
        }
      },
      "education": {
        "score": 85.0,
        "contribution": 8.5,
        "details": {
          "required_level": "Bachelor's Degree",
          "candidate_level": "Master's Degree",
          "meets_requirement": true,
          "exceeds_requirement": true
        }
      },
      "location": {
        "score": 100.0,
        "contribution": 5.0,
        "details": {
          "job_location": "San Francisco, CA",
          "candidate_location": "San Francisco, CA",
          "match_type": "exact",
          "willing_to_relocate": true
        }
      }
    },
    "screening_score": {
      "score": 88.0,
      "max_score": 100,
      "questions_answered": 3,
      "knockout_triggered": false
    }
  }
}
```

---

#### Get Skill Matches
```
GET /applications/{application_id}/skill-matches
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "summary": {
      "required_matched": 8,
      "required_total": 10,
      "preferred_matched": 3,
      "preferred_total": 5,
      "overall_match_percentage": 73.3
    },
    "required_skills": [
      {
        "job_requirement": {
          "skill": { "id": 1, "name": "JavaScript" },
          "min_years": 4,
          "priority": 1
        },
        "candidate_skill": {
          "skill": { "id": 1, "name": "JavaScript" },
          "years": 8,
          "proficiency": "expert",
          "last_used": "2025-01-15"
        },
        "match": {
          "is_matched": true,
          "match_type": "exact",
          "confidence": 1.0,
          "years_match": true,
          "score_contribution": 4.0
        }
      },
      {
        "job_requirement": {
          "skill": { "id": 50, "name": "System Design" },
          "min_years": null,
          "priority": 2
        },
        "candidate_skill": null,
        "match": {
          "is_matched": false,
          "match_type": "none",
          "confidence": 0,
          "suggested_alternatives": ["Architecture", "Software Design"]
        }
      }
    ],
    "preferred_skills": [ ... ],
    "unmatched_candidate_skills": [
      { "skill": "Python", "years": 3, "relevance": "medium" },
      { "skill": "GraphQL", "years": 2, "relevance": "high" }
    ]
  }
}
```

---

### 6.5 Application Timeline & Activity

#### Get Application Timeline
```
GET /applications/{application_id}/timeline
```

**Query Parameters:**
- `page`, `per_page`
- `activity_types`: comma-separated

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "activity_type": "interview_scheduled",
      "title": "Technical Interview scheduled",
      "description": "Scheduled for Jan 20, 2025 at 2:00 PM",
      "user": { "id": "uuid", "name": "Jane Smith", "avatar_url": "..." },
      "metadata": {
        "interview_id": "uuid",
        "interview_type": "Technical Interview",
        "scheduled_at": "2025-01-20T14:00:00Z"
      },
      "created_at": "2025-01-15T10:30:00Z"
    },
    {
      "id": "uuid",
      "activity_type": "stage_changed",
      "title": "Moved to Technical Interview",
      "description": "From Phone Screen stage",
      "user": { "id": "uuid", "name": "Jane Smith", "avatar_url": "..." },
      "metadata": {
        "from_stage": "Phone Screen",
        "to_stage": "Technical Interview",
        "reason": "Passed phone screen"
      },
      "created_at": "2025-01-14T16:00:00Z"
    },
    {
      "id": "uuid",
      "activity_type": "note_added",
      "title": "Note added",
      "description": "Great communication skills, strong technical background",
      "user": { "id": "uuid", "name": "Bob Johnson", "avatar_url": "..." },
      "created_at": "2025-01-14T15:30:00Z"
    },
    {
      "id": "uuid",
      "activity_type": "email_sent",
      "title": "Email sent to candidate",
      "description": "Subject: Next Steps in Your Application",
      "user": { "id": "uuid", "name": "Jane Smith", "avatar_url": "..." },
      "metadata": {
        "communication_id": "uuid",
        "subject": "Next Steps in Your Application"
      },
      "created_at": "2025-01-13T10:00:00Z"
    },
    {
      "id": "uuid",
      "activity_type": "score_updated",
      "title": "Match score recalculated",
      "description": "Score changed from 85.0 to 87.5",
      "user": null,
      "metadata": {
        "previous_score": 85.0,
        "new_score": 87.5
      },
      "created_at": "2025-01-12T10:00:00Z"
    },
    {
      "id": "uuid",
      "activity_type": "created",
      "title": "Application submitted",
      "description": "Applied via LinkedIn",
      "user": null,
      "metadata": {
        "source": "linkedin",
        "initial_score": 85.0
      },
      "created_at": "2025-01-10T10:00:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

### 6.6 Application Kanban View

#### Get Kanban Board
```
GET /jobs/{job_id}/kanban
```

**Query Parameters:**
- `search`: string
- `min_score`: decimal
- `source`: filter by source
- `is_starred`: boolean

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
        "applications": [
          {
            "id": "uuid",
            "candidate": {
              "id": "uuid",
              "name": "John Doe",
              "avatar_url": "...",
              "current_title": "Software Engineer"
            },
            "overall_score": 87.5,
            "is_starred": true,
            "days_in_stage": 2,
            "applied_at": "2025-01-13T10:00:00Z"
          },
          {
            "id": "uuid",
            "candidate": {
              "id": "uuid",
              "name": "Jane Smith",
              "avatar_url": "...",
              "current_title": "Senior Developer"
            },
            "overall_score": 82.0,
            "is_starred": false,
            "days_in_stage": 1,
            "applied_at": "2025-01-14T14:00:00Z"
          }
        ],
        "count": 12,
        "loaded": 2
      },
      {
        "id": "uuid",
        "name": "Reviewed",
        "applications": [ ... ],
        "count": 8,
        "loaded": 8
      }
    ],
    "total_applications": 45
  }
}
```

---

#### Load More Applications for Stage
```
GET /jobs/{job_id}/kanban/stages/{stage_id}/applications
```

**Query Parameters:**
- `page`, `per_page`
- Same filters as kanban

---

### 6.7 Screening Answers

#### Get Screening Answers
```
GET /applications/{application_id}/screening-answers
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "total_score": 88,
    "max_score": 100,
    "knockout_triggered": false,
    "answers": [
      {
        "id": "uuid",
        "question": {
          "id": "uuid",
          "text": "How many years of React experience do you have?",
          "type": "number",
          "is_required": true
        },
        "answer": {
          "value": "6",
          "submitted_at": "2025-01-10T10:00:00Z"
        },
        "scoring": {
          "score": 10,
          "max_score": 10,
          "is_knockout": false,
          "ideal_answer": "5+"
        }
      }
    ]
  }
}
```

---

#### Update Screening Answer Score (Manual Override)
```
PATCH /applications/{application_id}/screening-answers/{answer_id}
```

**Request:**
```json
{
  "score": 8,
  "notes": "Good answer but could be more detailed"
}
```

---

### 6.8 Application Comparison

#### Compare Applications
```
POST /applications/compare
```

**Request:**
```json
{
  "application_ids": ["uuid1", "uuid2", "uuid3"]
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "applications": [
      {
        "id": "uuid1",
        "candidate_name": "John Doe",
        "overall_score": 87.5,
        "experience_years": 8.5,
        "required_skills_matched": 8,
        "education_level": "Master's",
        "salary_expectation": 180000,
        "notice_period_days": 30,
        "strengths": ["JavaScript", "React", "Leadership"],
        "concerns": ["No Kubernetes experience"]
      },
      {
        "id": "uuid2",
        "candidate_name": "Jane Smith",
        "overall_score": 82.0,
        "experience_years": 6,
        "required_skills_matched": 7,
        "education_level": "Bachelor's",
        "salary_expectation": 160000,
        "notice_period_days": 14,
        "strengths": ["AWS", "Docker", "Kubernetes"],
        "concerns": ["Less experience"]
      },
      {
        "id": "uuid3",
        "candidate_name": "Bob Johnson",
        "overall_score": 79.0,
        "experience_years": 5,
        "required_skills_matched": 6,
        "education_level": "Bachelor's",
        "salary_expectation": 150000,
        "notice_period_days": 0,
        "strengths": ["Immediate availability"],
        "concerns": ["Minimum experience", "Fewer skills"]
      }
    ],
    "comparison_matrix": {
      "overall_score": { "best": "uuid1", "values": { "uuid1": 87.5, "uuid2": 82.0, "uuid3": 79.0 } },
      "experience": { "best": "uuid1", "values": { "uuid1": 8.5, "uuid2": 6, "uuid3": 5 } },
      "skills_match": { "best": "uuid1", "values": { "uuid1": 8, "uuid2": 7, "uuid3": 6 } },
      "salary": { "best": "uuid3", "values": { "uuid1": 180000, "uuid2": 160000, "uuid3": 150000 } },
      "availability": { "best": "uuid3", "values": { "uuid1": 30, "uuid2": 14, "uuid3": 0 } }
    },
    "ai_recommendation": {
      "top_choice": "uuid1",
      "reasoning": "John Doe has the highest overall score, most experience, and best skills match. Despite higher salary expectations, the quality justifies the investment."
    }
  }
}
```
