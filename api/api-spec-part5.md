## 7. Interviews

### 7.1 Interview CRUD

#### List Interviews
```
GET /interviews
```

**Headers:** `Authorization: Bearer <access_token>`  
**Permission Required:** `interviews.view`

**Query Parameters:**
- `page`, `per_page`
- `application_id`: UUID
- `job_id`: UUID
- `candidate_id`: UUID
- `interviewer_id`: UUID
- `interview_type_id`: UUID
- `status`: `scheduled` | `confirmed` | `completed` | `cancelled` | `no_show`
- `location_type`: `in_person` | `phone` | `video`
- `from_date`: ISO datetime
- `to_date`: ISO datetime
- `my_interviews`: boolean (interviews where current user is participant)
- `needs_feedback`: boolean
- `sort_by`: `scheduled_at` | `created_at`
- `sort_dir`: `asc` | `desc`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "application": {
        "id": "uuid",
        "job": {
          "id": "uuid",
          "title": "Senior Software Engineer"
        },
        "candidate": {
          "id": "uuid",
          "name": "John Doe",
          "email": "john@email.com",
          "avatar_url": "https://..."
        }
      },
      "interview_type": {
        "id": "uuid",
        "name": "Technical Interview"
      },
      "schedule": {
        "scheduled_at": "2025-01-20T14:00:00Z",
        "duration_minutes": 60,
        "timezone": "America/Los_Angeles"
      },
      "location": {
        "type": "video",
        "platform": "zoom",
        "link": "https://zoom.us/j/12345",
        "meeting_id": "123 456 789"
      },
      "participants": [
        {
          "user": { "id": "uuid", "name": "Jane Smith" },
          "role": "interviewer",
          "status": "accepted",
          "feedback_submitted": false
        },
        {
          "user": { "id": "uuid", "name": "Bob Johnson" },
          "role": "interviewer",
          "status": "accepted",
          "feedback_submitted": false
        }
      ],
      "status": "confirmed",
      "candidate_confirmed": true,
      "created_at": "2025-01-15T10:30:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

#### Get Interview Details
```
GET /interviews/{interview_id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    
    "application": {
      "id": "uuid",
      "job": {
        "id": "uuid",
        "title": "Senior Software Engineer",
        "reference_code": "JOB-2024-0042",
        "department": "Engineering"
      },
      "candidate": {
        "id": "uuid",
        "name": "John Doe",
        "email": "john@email.com",
        "phone": "+1-555-123-4567",
        "avatar_url": "https://...",
        "current_title": "Software Engineer",
        "linkedin_url": "https://linkedin.com/in/johndoe",
        "resume_url": "https://cdn.talentforge.io/resumes/uuid.pdf"
      },
      "overall_score": 87.5,
      "current_stage": "Technical Interview"
    },
    
    "interview_type": {
      "id": "uuid",
      "name": "Technical Interview",
      "description": "Technical deep-dive focusing on system design and coding",
      "default_duration_minutes": 60,
      "interviewer_instructions": "Focus on problem-solving approach...",
      "candidate_instructions": "Be prepared to share your screen..."
    },
    
    "schedule": {
      "scheduled_at": "2025-01-20T14:00:00Z",
      "duration_minutes": 60,
      "timezone": "America/Los_Angeles",
      "local_time": "2:00 PM PST"
    },
    
    "location": {
      "type": "video",
      "platform": "zoom",
      "link": "https://zoom.us/j/12345",
      "meeting_id": "123 456 789",
      "password": "abc123",
      "dial_in_numbers": [
        { "country": "US", "number": "+1-555-123-4567" }
      ]
    },
    
    "participants": [
      {
        "id": "uuid",
        "user": {
          "id": "uuid",
          "name": "Jane Smith",
          "email": "jane@acme.com",
          "avatar_url": "https://...",
          "job_title": "Engineering Manager"
        },
        "role": "lead",
        "status": "accepted",
        "response_at": "2025-01-15T11:00:00Z",
        "feedback_submitted": false
      },
      {
        "id": "uuid",
        "user": {
          "id": "uuid",
          "name": "Bob Johnson",
          "email": "bob@acme.com",
          "avatar_url": "https://...",
          "job_title": "Senior Engineer"
        },
        "role": "interviewer",
        "status": "accepted",
        "response_at": "2025-01-15T12:00:00Z",
        "feedback_submitted": false
      }
    ],
    
    "status": "confirmed",
    
    "candidate_status": {
      "confirmed_at": "2025-01-16T10:00:00Z",
      "reminder_sent_at": "2025-01-19T14:00:00Z"
    },
    
    "calendar": {
      "event_id": "google_calendar_event_id",
      "provider": "google_calendar"
    },
    
    "notes": {
      "internal": "Candidate prefers afternoon slots",
      "candidate": "Please join 5 minutes early"
    },
    
    "scorecard_template": {
      "id": "uuid",
      "name": "Technical Interview Scorecard",
      "criteria_count": 8
    },
    
    "feedback_summary": null,
    
    "previous_interviews": [
      {
        "id": "uuid",
        "type": "Phone Screen",
        "date": "2025-01-12T14:00:00Z",
        "overall_score": 4,
        "recommendation": "yes"
      }
    ],
    
    "created_at": "2025-01-15T10:30:00Z",
    "created_by": { "id": "uuid", "name": "Jane Smith" }
  }
}
```

---

#### Schedule Interview
```
POST /interviews
```

**Permission Required:** `interviews.schedule`

**Request:**
```json
{
  "application_id": "uuid",
  "interview_type_id": "uuid",
  "scheduled_at": "2025-01-20T14:00:00Z",
  "duration_minutes": 60,
  "timezone": "America/Los_Angeles",
  "location_type": "video",
  "video_platform": "zoom",
  "participants": [
    { "user_id": "uuid", "role": "lead" },
    { "user_id": "uuid", "role": "interviewer" }
  ],
  "scorecard_template_id": "uuid",
  "send_invites": true,
  "internal_notes": "Focus on system design",
  "candidate_notes": "Please have a quiet space for the call"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "video_link": "https://zoom.us/j/12345",
    "calendar_event_created": true,
    "invites_sent": {
      "interviewers": 2,
      "candidate": true
    }
  }
}
```

**Business Logic:**
- Check interviewer availability
- Create video meeting (Zoom/Meet/Teams)
- Create calendar events for all participants
- Send email invitations
- Move application to Interview stage (if not already)
- Log audit event

---

#### Update Interview
```
PATCH /interviews/{interview_id}
```

**Request:**
```json
{
  "scheduled_at": "2025-01-21T15:00:00Z",
  "duration_minutes": 90,
  "internal_notes": "Updated notes"
}
```

**Business Logic:**
- Update calendar events
- Send reschedule notifications
- Log audit event

---

#### Cancel Interview
```
POST /interviews/{interview_id}/cancel
```

**Request:**
```json
{
  "reason": "Candidate requested reschedule",
  "notify_participants": true,
  "notify_candidate": true
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "cancelled",
    "cancelled_at": "2025-01-18T10:00:00Z",
    "cancelled_by": { "id": "uuid", "name": "Jane Smith" }
  }
}
```

---

#### Reschedule Interview
```
POST /interviews/{interview_id}/reschedule
```

**Request:**
```json
{
  "new_scheduled_at": "2025-01-22T14:00:00Z",
  "reason": "Interviewer conflict",
  "notify_participants": true,
  "notify_candidate": true
}
```

---

### 7.2 Interview Participants

#### Add Participant
```
POST /interviews/{interview_id}/participants
```

**Request:**
```json
{
  "user_id": "uuid",
  "role": "observer",
  "send_invite": true
}
```

---

#### Remove Participant
```
DELETE /interviews/{interview_id}/participants/{participant_id}
```

---

#### Update Participant Response
```
PATCH /interviews/{interview_id}/participants/{participant_id}
```

**Request:**
```json
{
  "status": "accepted"
}
```

---

### 7.3 Interview Status

#### Mark as Started
```
POST /interviews/{interview_id}/start
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "started_at": "2025-01-20T14:02:00Z"
  }
}
```

---

#### Mark as Completed
```
POST /interviews/{interview_id}/complete
```

**Request:**
```json
{
  "actual_duration_minutes": 55,
  "notes": "Interview completed successfully"
}
```

---

#### Mark as No Show
```
POST /interviews/{interview_id}/no-show
```

**Request:**
```json
{
  "who": "candidate",
  "notes": "Candidate did not join after 15 minutes"
}
```

---

### 7.4 Interview Feedback

#### Get Feedback Form
```
GET /interviews/{interview_id}/feedback
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "interview_id": "uuid",
    "scorecard_template": {
      "id": "uuid",
      "name": "Technical Interview Scorecard"
    },
    "criteria": [
      {
        "id": "uuid",
        "name": "Technical Knowledge",
        "description": "Depth of technical understanding",
        "category": "technical",
        "score_type": "rating",
        "min_score": 1,
        "max_score": 5,
        "score_labels": {
          "1": "Poor",
          "2": "Below Average",
          "3": "Average",
          "4": "Good",
          "5": "Excellent"
        },
        "weight": 1.5,
        "is_required": true
      },
      {
        "id": "uuid",
        "name": "Problem Solving",
        "description": "Ability to break down and solve complex problems",
        "category": "technical",
        "score_type": "rating",
        "min_score": 1,
        "max_score": 5,
        "weight": 1.5,
        "is_required": true
      },
      {
        "id": "uuid",
        "name": "Communication",
        "description": "Clarity in explaining technical concepts",
        "category": "communication",
        "score_type": "rating",
        "min_score": 1,
        "max_score": 5,
        "weight": 1.0,
        "is_required": true
      },
      {
        "id": "uuid",
        "name": "Culture Fit",
        "description": "Alignment with company values",
        "category": "culture_fit",
        "score_type": "rating",
        "min_score": 1,
        "max_score": 5,
        "weight": 1.0,
        "is_required": true
      }
    ],
    "existing_feedback": null
  }
}
```

---

#### Submit Feedback
```
POST /interviews/{interview_id}/feedback
```

**Permission Required:** `interviews.feedback`

**Request:**
```json
{
  "overall_score": 4,
  "recommendation": "yes",
  "strengths": "Strong technical skills, excellent problem-solving approach, clear communication",
  "concerns": "Could improve on system design thinking at scale",
  "summary": "Solid candidate with strong fundamentals. Would be a good addition to the team.",
  "criteria_scores": [
    { "criterion_id": "uuid", "score": 4, "notes": "Deep knowledge of JavaScript ecosystem" },
    { "criterion_id": "uuid", "score": 5, "notes": "Excellent approach to breaking down problems" },
    { "criterion_id": "uuid", "score": 4, "notes": "Clear and concise explanations" },
    { "criterion_id": "uuid", "score": 4, "notes": "Good cultural alignment" }
  ],
  "private_notes": "Salary expectations might be high",
  "status": "submitted"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "overall_score": 4,
    "recommendation": "yes",
    "submitted_at": "2025-01-20T15:30:00Z"
  }
}
```

---

#### Save Feedback Draft
```
POST /interviews/{interview_id}/feedback/draft
```

**Request:** Same as submit but `"status": "draft"`

---

#### Get My Feedback
```
GET /interviews/{interview_id}/feedback/mine
```

---

#### Get All Feedback (Hiring Manager/Recruiter)
```
GET /interviews/{interview_id}/feedback/all
```

**Permission Required:** Lead interviewer or hiring manager

**Response (200):**
```json
{
  "success": true,
  "data": {
    "summary": {
      "average_score": 4.2,
      "recommendations": {
        "strong_yes": 0,
        "yes": 2,
        "maybe": 0,
        "no": 0,
        "strong_no": 0
      },
      "feedback_submitted": 2,
      "feedback_pending": 0
    },
    "feedback": [
      {
        "id": "uuid",
        "interviewer": { "id": "uuid", "name": "Jane Smith", "role": "lead" },
        "overall_score": 4,
        "recommendation": "yes",
        "strengths": "Strong technical skills...",
        "concerns": "Could improve...",
        "summary": "Solid candidate...",
        "criteria_scores": [
          { "criterion": "Technical Knowledge", "score": 4 },
          { "criterion": "Problem Solving", "score": 5 },
          { "criterion": "Communication", "score": 4 },
          { "criterion": "Culture Fit", "score": 4 }
        ],
        "submitted_at": "2025-01-20T15:30:00Z"
      },
      {
        "id": "uuid",
        "interviewer": { "id": "uuid", "name": "Bob Johnson", "role": "interviewer" },
        "overall_score": 4,
        "recommendation": "yes",
        "strengths": "Great coding skills...",
        "concerns": "Limited leadership experience",
        "summary": "Would recommend...",
        "criteria_scores": [ ... ],
        "submitted_at": "2025-01-20T16:00:00Z"
      }
    ]
  }
}
```

---

### 7.5 Interview Types

#### List Interview Types
```
GET /interview-types
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Phone Screen",
      "description": "Initial screening call with recruiter",
      "default_duration_minutes": 30,
      "interviewer_instructions": "Focus on cultural fit and basic qualifications",
      "candidate_instructions": "Be prepared to discuss your background",
      "requires_scorecard": true,
      "scorecard_template": { "id": "uuid", "name": "Phone Screen Scorecard" },
      "is_active": true,
      "usage_count": 45
    },
    {
      "id": "uuid",
      "name": "Technical Interview",
      "description": "Deep-dive technical assessment",
      "default_duration_minutes": 60,
      "requires_scorecard": true,
      "scorecard_template": { "id": "uuid", "name": "Technical Scorecard" },
      "is_active": true
    }
  ]
}
```

---

#### Create Interview Type
```
POST /interview-types
```

**Request:**
```json
{
  "name": "System Design Interview",
  "description": "Architecture and system design discussion",
  "default_duration_minutes": 90,
  "interviewer_instructions": "Present a system design problem...",
  "candidate_instructions": "Be prepared to whiteboard...",
  "requires_scorecard": true,
  "scorecard_template_id": "uuid"
}
```

---

### 7.6 Scorecard Templates

#### List Scorecard Templates
```
GET /scorecard-templates
```

---

#### Create Scorecard Template
```
POST /scorecard-templates
```

**Request:**
```json
{
  "name": "Engineering Interview Scorecard",
  "description": "Standard scorecard for engineering positions",
  "criteria": [
    {
      "name": "Technical Knowledge",
      "description": "Depth of technical understanding",
      "category": "technical",
      "score_type": "rating",
      "min_score": 1,
      "max_score": 5,
      "weight": 1.5,
      "is_required": true,
      "sort_order": 0
    },
    {
      "name": "Problem Solving",
      "description": "Analytical and problem-solving abilities",
      "category": "technical",
      "score_type": "rating",
      "min_score": 1,
      "max_score": 5,
      "weight": 1.5,
      "is_required": true,
      "sort_order": 1
    }
  ]
}
```

---

### 7.7 Calendar Integration

#### Get Available Slots
```
GET /interviews/availability
```

**Query Parameters:**
- `interviewer_ids`: comma-separated UUIDs (required)
- `duration_minutes`: integer (required)
- `from_date`: ISO date
- `to_date`: ISO date
- `timezone`: string

**Response (200):**
```json
{
  "success": true,
  "data": {
    "available_slots": [
      {
        "start": "2025-01-20T09:00:00Z",
        "end": "2025-01-20T10:00:00Z",
        "all_available": true
      },
      {
        "start": "2025-01-20T14:00:00Z",
        "end": "2025-01-20T15:00:00Z",
        "all_available": true
      },
      {
        "start": "2025-01-21T10:00:00Z",
        "end": "2025-01-21T11:00:00Z",
        "all_available": false,
        "unavailable": ["uuid_of_bob"]
      }
    ],
    "interviewer_calendars": [
      {
        "user_id": "uuid",
        "name": "Jane Smith",
        "busy_times": [
          { "start": "2025-01-20T10:00:00Z", "end": "2025-01-20T12:00:00Z" }
        ]
      }
    ]
  }
}
```

---

#### Send Scheduling Link to Candidate
```
POST /applications/{application_id}/schedule-interview-request
```

**Request:**
```json
{
  "interview_type_id": "uuid",
  "interviewer_ids": ["uuid1", "uuid2"],
  "duration_minutes": 60,
  "date_range": {
    "from": "2025-01-20",
    "to": "2025-01-27"
  },
  "message": "Please select a time that works for you"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "scheduling_link": "https://schedule.talentforge.io/s/abc123",
    "expires_at": "2025-01-27T23:59:59Z",
    "email_sent": true
  }
}
```

---

## 8. Offers

### 8.1 Offer CRUD

#### List Offers
```
GET /offers
```

**Query Parameters:**
- `page`, `per_page`
- `application_id`: UUID
- `job_id`: UUID
- `status`: `draft` | `pending_approval` | `approved` | `sent` | `viewed` | `accepted` | `declined` | `expired` | `withdrawn`
- `from_date`, `to_date`
- `sort_by`: `created_at` | `start_date` | `salary`
- `sort_dir`: `asc` | `desc`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "application": {
        "id": "uuid",
        "job": { "id": "uuid", "title": "Senior Software Engineer" },
        "candidate": { "id": "uuid", "name": "John Doe", "email": "john@email.com" }
      },
      "title": "Senior Software Engineer",
      "compensation": {
        "base_salary": 180000,
        "currency": "USD",
        "period": "yearly",
        "bonus": 20000
      },
      "start_date": "2025-03-01",
      "status": "sent",
      "sent_at": "2025-01-20T10:00:00Z",
      "expires_at": "2025-01-27T23:59:59Z",
      "created_at": "2025-01-18T14:00:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

#### Get Offer Details
```
GET /offers/{offer_id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    
    "application": {
      "id": "uuid",
      "job": {
        "id": "uuid",
        "title": "Senior Software Engineer",
        "reference_code": "JOB-2024-0042",
        "department": "Engineering"
      },
      "candidate": {
        "id": "uuid",
        "name": "John Doe",
        "email": "john@email.com",
        "phone": "+1-555-123-4567"
      }
    },
    
    "position": {
      "title": "Senior Software Engineer",
      "department": { "id": "uuid", "name": "Engineering" },
      "location": { "id": "uuid", "name": "San Francisco HQ" },
      "reports_to": { "id": "uuid", "name": "Jane Smith", "title": "Engineering Manager" }
    },
    
    "compensation": {
      "base_salary": 180000,
      "currency": { "code": "USD", "symbol": "$" },
      "period": "yearly",
      "bonus": {
        "amount": 20000,
        "type": "signing"
      },
      "commission": null,
      "equity": {
        "shares": 10000,
        "type": "options",
        "vesting_schedule": "4 years with 1 year cliff"
      },
      "total_compensation": 200000
    },
    
    "benefits": {
      "summary": "Comprehensive benefits package including health, dental, vision...",
      "details": {
        "health_insurance": "Full medical, dental, vision coverage",
        "retirement": "401k with 4% match",
        "pto": "Unlimited PTO",
        "other": ["Gym membership", "Learning budget", "Home office stipend"]
      }
    },
    
    "dates": {
      "start_date": "2025-03-01",
      "offer_expiry_date": "2025-01-27"
    },
    
    "documents": {
      "offer_letter_url": "https://cdn.talentforge.io/offers/uuid/offer-letter.pdf",
      "offer_letter_generated_at": "2025-01-18T14:30:00Z",
      "signed_offer_url": null
    },
    
    "status": "sent",
    
    "approval": {
      "requires_approval": true,
      "approved_at": "2025-01-19T10:00:00Z",
      "approved_by": { "id": "uuid", "name": "VP Engineering" },
      "approvers": [
        {
          "user": { "id": "uuid", "name": "Jane Smith" },
          "order": 1,
          "status": "approved",
          "responded_at": "2025-01-18T16:00:00Z"
        },
        {
          "user": { "id": "uuid", "name": "VP Engineering" },
          "order": 2,
          "status": "approved",
          "responded_at": "2025-01-19T10:00:00Z"
        }
      ]
    },
    
    "sending": {
      "sent_at": "2025-01-20T10:00:00Z",
      "sent_by": { "id": "uuid", "name": "Jane Smith" },
      "viewed_at": "2025-01-20T14:30:00Z"
    },
    
    "response": {
      "responded_at": null,
      "response": null,
      "decline_reason": null
    },
    
    "negotiation": {
      "notes": null,
      "revision_number": 1,
      "previous_offers": []
    },
    
    "created_at": "2025-01-18T14:00:00Z",
    "created_by": { "id": "uuid", "name": "Jane Smith" }
  }
}
```

---

#### Create Offer
```
POST /offers
```

**Permission Required:** `offers.create`

**Request:**
```json
{
  "application_id": "uuid",
  "title": "Senior Software Engineer",
  "department_id": "uuid",
  "location_id": "uuid",
  "reports_to_user_id": "uuid",
  
  "base_salary": 180000,
  "salary_currency_id": 1,
  "salary_period": "yearly",
  
  "bonus_amount": 20000,
  "bonus_type": "signing",
  
  "equity_shares": 10000,
  "equity_type": "options",
  "equity_vesting_schedule": "4 years with 1 year cliff",
  
  "benefits_summary": "Comprehensive benefits package...",
  
  "start_date": "2025-03-01",
  "offer_expiry_date": "2025-01-27",
  
  "requires_approval": true,
  "approver_user_ids": ["uuid1", "uuid2"]
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "pending_approval",
    "approval_requests_sent": 2
  }
}
```

---

#### Update Offer
```
PATCH /offers/{offer_id}
```

**Note:** Can only update draft or rejected offers

---

#### Delete Offer
```
DELETE /offers/{offer_id}
```

**Note:** Can only delete draft offers

---

### 8.2 Offer Workflow

#### Submit for Approval
```
POST /offers/{offer_id}/submit-approval
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "status": "pending_approval",
    "next_approver": { "id": "uuid", "name": "Jane Smith" },
    "notification_sent": true
  }
}
```

---

#### Approve Offer
```
POST /offers/{offer_id}/approve
```

**Permission Required:** User must be an approver

**Request:**
```json
{
  "notes": "Approved - good candidate, fair compensation"
}
```

---

#### Reject Offer (in Approval)
```
POST /offers/{offer_id}/reject-approval
```

**Request:**
```json
{
  "notes": "Salary too high for this level"
}
```

---

#### Generate Offer Letter
```
POST /offers/{offer_id}/generate-letter
```

**Request:**
```json
{
  "template_id": "uuid"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "offer_letter_url": "https://cdn.talentforge.io/offers/uuid/offer-letter.pdf",
    "generated_at": "2025-01-20T09:00:00Z"
  }
}
```

---

#### Send Offer to Candidate
```
POST /offers/{offer_id}/send
```

**Permission Required:** `offers.create`

**Request:**
```json
{
  "email_template_id": "uuid",
  "personal_message": "We're excited to have you join our team!",
  "cc_emails": ["hr@acme.com"]
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "status": "sent",
    "sent_at": "2025-01-20T10:00:00Z",
    "email_sent": true
  }
}
```

---

#### Record Candidate Response
```
POST /offers/{offer_id}/response
```

**Request:**
```json
{
  "response": "accepted",
  "notes": "Candidate accepted verbally, signed offer attached"
}
```

OR

```json
{
  "response": "declined",
  "decline_reason": "Accepted another offer with higher compensation"
}
```

OR

```json
{
  "response": "negotiating",
  "notes": "Candidate requesting higher base salary"
}
```

---

#### Upload Signed Offer
```
POST /offers/{offer_id}/signed-offer
```

**Request (multipart/form-data):**
```
file: [signed offer PDF]
```

---

#### Withdraw Offer
```
POST /offers/{offer_id}/withdraw
```

**Request:**
```json
{
  "reason": "Position filled by another candidate",
  "notify_candidate": true
}
```

---

#### Extend Offer Expiry
```
POST /offers/{offer_id}/extend
```

**Request:**
```json
{
  "new_expiry_date": "2025-02-03",
  "notify_candidate": true
}
```

---

### 8.3 Offer Revision

#### Create Revised Offer
```
POST /offers/{offer_id}/revise
```

**Request:**
```json
{
  "base_salary": 190000,
  "bonus_amount": 25000,
  "notes": "Increased compensation based on candidate negotiation"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "new_uuid",
    "revision_number": 2,
    "previous_offer_id": "original_uuid",
    "status": "draft",
    "changes": [
      { "field": "base_salary", "old": 180000, "new": 190000 },
      { "field": "bonus_amount", "old": 20000, "new": 25000 }
    ]
  }
}
```

---

### 8.4 Rejection Reasons

#### List Rejection Reasons
```
GET /rejection-reasons
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Insufficient Experience",
      "description": "Candidate doesn't meet minimum experience requirements",
      "category": "qualifications",
      "email_template_id": "uuid",
      "is_active": true,
      "usage_count": 45
    },
    {
      "id": "uuid",
      "name": "Skills Mismatch",
      "description": "Candidate's skills don't align with job requirements",
      "category": "qualifications",
      "is_active": true
    },
    {
      "id": "uuid",
      "name": "Compensation Mismatch",
      "description": "Salary expectations exceed budget",
      "category": "compensation",
      "is_active": true
    },
    {
      "id": "uuid",
      "name": "Position Filled",
      "description": "Position has been filled by another candidate",
      "category": "other",
      "is_active": true
    }
  ]
}
```

---

#### Create Rejection Reason
```
POST /rejection-reasons
```

**Request:**
```json
{
  "name": "Culture Fit",
  "description": "Candidate's values don't align with company culture",
  "category": "culture_fit",
  "email_template_id": "uuid"
}
```
