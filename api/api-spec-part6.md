## 9. Communications

### 9.1 Email Communications

#### List Communications
```
GET /communications
```

**Query Parameters:**
- `page`, `per_page`
- `candidate_id`: UUID
- `application_id`: UUID
- `type`: `email` | `sms` | `phone_call` | `in_app`
- `direction`: `inbound` | `outbound`
- `status`: `pending` | `sent` | `delivered` | `read` | `failed` | `bounced`
- `from_date`, `to_date`
- `search`: search in subject/body

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "type": "email",
      "direction": "outbound",
      "candidate": {
        "id": "uuid",
        "name": "John Doe",
        "email": "john@email.com"
      },
      "application": {
        "id": "uuid",
        "job_title": "Senior Software Engineer"
      },
      "from": {
        "user": { "id": "uuid", "name": "Jane Smith" },
        "address": "jane@acme.com"
      },
      "to": ["john@email.com"],
      "subject": "Next Steps in Your Application",
      "preview": "Thank you for your interest in the Senior Software Engineer position...",
      "status": "delivered",
      "tracking": {
        "opened": true,
        "open_count": 3,
        "clicked": true,
        "click_count": 1
      },
      "sent_at": "2025-01-15T10:00:00Z",
      "delivered_at": "2025-01-15T10:01:00Z",
      "opened_at": "2025-01-15T14:30:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

#### Get Communication Details
```
GET /communications/{communication_id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "type": "email",
    "direction": "outbound",
    
    "candidate": {
      "id": "uuid",
      "name": "John Doe",
      "email": "john@email.com"
    },
    "application": {
      "id": "uuid",
      "job": { "id": "uuid", "title": "Senior Software Engineer" }
    },
    
    "from": {
      "user": { "id": "uuid", "name": "Jane Smith" },
      "address": "jane@acme.com"
    },
    "to": ["john@email.com"],
    "cc": [],
    "bcc": ["hr@acme.com"],
    
    "subject": "Next Steps in Your Application",
    "body_html": "<p>Dear John,</p><p>Thank you for your interest...</p>",
    "body_text": "Dear John,\n\nThank you for your interest...",
    
    "template": {
      "id": "uuid",
      "name": "Application Status Update"
    },
    
    "attachments": [
      {
        "id": "uuid",
        "file_name": "interview_prep.pdf",
        "file_url": "https://cdn.talentforge.io/attachments/uuid.pdf",
        "file_size": 245678,
        "mime_type": "application/pdf"
      }
    ],
    
    "status": "delivered",
    
    "tracking": {
      "sent_at": "2025-01-15T10:00:00Z",
      "delivered_at": "2025-01-15T10:01:00Z",
      "opened_at": "2025-01-15T14:30:00Z",
      "open_count": 3,
      "clicked_at": "2025-01-15T14:32:00Z",
      "click_count": 1,
      "clicked_links": [
        { "url": "https://calendly.com/...", "clicks": 1 }
      ]
    },
    
    "thread": {
      "id": "uuid",
      "message_count": 3,
      "messages": [
        { "id": "uuid", "direction": "outbound", "subject": "Initial Contact", "sent_at": "2025-01-10T10:00:00Z" },
        { "id": "uuid", "direction": "inbound", "subject": "Re: Initial Contact", "sent_at": "2025-01-11T09:00:00Z" },
        { "id": "uuid", "direction": "outbound", "subject": "Re: Initial Contact", "sent_at": "2025-01-15T10:00:00Z" }
      ]
    },
    
    "external_message_id": "sendgrid_msg_123456",
    
    "created_at": "2025-01-15T09:55:00Z",
    "created_by": { "id": "uuid", "name": "Jane Smith" }
  }
}
```

---

#### Send Email
```
POST /communications/email
```

**Permission Required:** Ability to communicate with candidate

**Request:**
```json
{
  "candidate_id": "uuid",
  "application_id": "uuid",
  "to": ["john@email.com"],
  "cc": [],
  "bcc": ["hr@acme.com"],
  "subject": "Next Steps in Your Application",
  "body_html": "<p>Dear {{candidate.first_name}},</p><p>Thank you for...</p>",
  "body_text": "Dear {{candidate.first_name}},\n\nThank you for...",
  "template_id": "uuid",
  "attachment_ids": ["uuid"],
  "schedule_at": null,
  "track_opens": true,
  "track_clicks": true
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "sent",
    "sent_at": "2025-01-15T10:30:00Z"
  }
}
```

**Business Logic:**
- Replace merge fields
- Send via email provider (SendGrid)
- Track delivery status
- Log activity
- Update candidate timeline

---

#### Send Bulk Email
```
POST /communications/email/bulk
```

**Request:**
```json
{
  "candidate_ids": ["uuid1", "uuid2", "uuid3"],
  "subject": "Exciting Opportunity at Acme Corp",
  "body_html": "<p>Dear {{candidate.first_name}},</p>...",
  "template_id": "uuid",
  "schedule_at": "2025-01-16T09:00:00Z"
}
```

**Response (202):**
```json
{
  "success": true,
  "data": {
    "bulk_send_id": "uuid",
    "total_recipients": 3,
    "status": "scheduled",
    "scheduled_at": "2025-01-16T09:00:00Z"
  }
}
```

---

#### Schedule Email
```
POST /communications/email/schedule
```

**Request:** Same as send email with `schedule_at` field

---

#### Cancel Scheduled Email
```
DELETE /communications/{communication_id}/schedule
```

---

### 9.2 Email Templates

#### List Email Templates
```
GET /email-templates
```

**Query Parameters:**
- `category`: `application` | `interview` | `offer` | `rejection` | `general`
- `search`: search in name/subject
- `is_active`: boolean

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Application Received",
      "description": "Confirmation email when candidate applies",
      "category": "application",
      "subject": "We've Received Your Application - {{job.title}}",
      "preview": "Thank you for applying to {{job.title}}...",
      "merge_fields": ["candidate.first_name", "candidate.last_name", "job.title", "company.name"],
      "is_system": true,
      "is_active": true,
      "usage_count": 156,
      "last_used_at": "2025-01-15T10:00:00Z"
    }
  ]
}
```

---

#### Get Email Template
```
GET /email-templates/{template_id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Interview Invitation",
    "description": "Invite candidate to interview",
    "category": "interview",
    "subject": "Interview Invitation - {{job.title}} at {{company.name}}",
    "body_html": "<!DOCTYPE html><html>...",
    "body_text": "Dear {{candidate.first_name}},...",
    "merge_fields": [
      "candidate.first_name",
      "candidate.last_name",
      "job.title",
      "interview.type",
      "interview.date",
      "interview.time",
      "interview.location",
      "interview.video_link",
      "company.name"
    ],
    "default_attachments": [],
    "is_system": false,
    "is_active": true,
    "created_at": "2024-06-15T10:00:00Z"
  }
}
```

---

#### Create Email Template
```
POST /email-templates
```

**Request:**
```json
{
  "name": "Technical Assessment Invitation",
  "description": "Send technical assessment to candidate",
  "category": "interview",
  "subject": "Technical Assessment - {{job.title}}",
  "body_html": "<p>Dear {{candidate.first_name}},</p><p>We'd like to invite you to complete...</p>",
  "body_text": "Dear {{candidate.first_name}},\n\nWe'd like to invite you to complete..."
}
```

---

#### Update Email Template
```
PATCH /email-templates/{template_id}
```

---

#### Delete Email Template
```
DELETE /email-templates/{template_id}
```

---

#### Preview Email Template
```
POST /email-templates/{template_id}/preview
```

**Request:**
```json
{
  "candidate_id": "uuid",
  "application_id": "uuid",
  "interview_id": "uuid"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "subject": "Interview Invitation - Senior Software Engineer at Acme Corp",
    "body_html": "<p>Dear John,</p><p>We're pleased to invite you to...</p>",
    "body_text": "Dear John,\n\nWe're pleased to invite you to..."
  }
}
```

---

#### Get Available Merge Fields
```
GET /email-templates/merge-fields
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "candidate": [
      { "field": "candidate.first_name", "description": "Candidate's first name" },
      { "field": "candidate.last_name", "description": "Candidate's last name" },
      { "field": "candidate.full_name", "description": "Candidate's full name" },
      { "field": "candidate.email", "description": "Candidate's email" },
      { "field": "candidate.phone", "description": "Candidate's phone" }
    ],
    "job": [
      { "field": "job.title", "description": "Job title" },
      { "field": "job.department", "description": "Department name" },
      { "field": "job.location", "description": "Job location" }
    ],
    "interview": [
      { "field": "interview.type", "description": "Interview type" },
      { "field": "interview.date", "description": "Interview date" },
      { "field": "interview.time", "description": "Interview time" },
      { "field": "interview.video_link", "description": "Video call link" }
    ],
    "offer": [
      { "field": "offer.title", "description": "Position title" },
      { "field": "offer.salary", "description": "Base salary" },
      { "field": "offer.start_date", "description": "Start date" }
    ],
    "company": [
      { "field": "company.name", "description": "Company name" },
      { "field": "company.website", "description": "Company website" }
    ],
    "sender": [
      { "field": "sender.name", "description": "Sender's name" },
      { "field": "sender.title", "description": "Sender's job title" },
      { "field": "sender.email", "description": "Sender's email" }
    ]
  }
}
```

---

## 10. Documents

### 10.1 Document Management

#### List Documents
```
GET /documents
```

**Query Parameters:**
- `page`, `per_page`
- `candidate_id`: UUID
- `application_id`: UUID
- `document_type_id`: integer
- `search`: search in filename/title
- `from_date`, `to_date`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "candidate": { "id": "uuid", "name": "John Doe" },
      "application": { "id": "uuid", "job_title": "Senior Software Engineer" },
      "document_type": { "id": 1, "name": "Resume", "code": "resume" },
      "file_name": "john_doe_resume_2025.pdf",
      "original_name": "John Doe - Resume.pdf",
      "file_url": "https://cdn.talentforge.io/docs/uuid.pdf",
      "file_size": 245678,
      "mime_type": "application/pdf",
      "title": "John Doe Resume",
      "is_parsed": true,
      "version": 2,
      "is_current": true,
      "created_at": "2025-01-10T10:00:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

#### Upload Document
```
POST /documents
```

**Request (multipart/form-data):**
```
file: [file]
candidate_id: uuid
application_id: uuid (optional)
document_type_id: 1
title: "John Doe Resume"
description: "Latest version"
parse: true (for resumes)
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "file_url": "https://cdn.talentforge.io/docs/uuid.pdf",
    "parsing_status": "processing"
  }
}
```

---

#### Get Document
```
GET /documents/{document_id}
```

---

#### Download Document
```
GET /documents/{document_id}/download
```

**Response:** File download with proper headers

---

#### Delete Document
```
DELETE /documents/{document_id}
```

---

#### Get Document Versions
```
GET /documents/{document_id}/versions
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "version": 2,
      "is_current": true,
      "file_url": "https://...",
      "created_at": "2025-01-10T10:00:00Z"
    },
    {
      "id": "uuid",
      "version": 1,
      "is_current": false,
      "file_url": "https://...",
      "created_at": "2024-12-01T10:00:00Z"
    }
  ]
}
```

---

### 10.2 Document Types

#### List Document Types
```
GET /document-types
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "code": "resume",
      "name": "Resume/CV",
      "description": "Candidate resume or curriculum vitae",
      "category": "resume",
      "allowed_extensions": ["pdf", "doc", "docx"],
      "max_size_mb": 10,
      "is_active": true
    }
  ]
}
```

---

## 11. Notes & Comments

### 11.1 Notes

#### List Notes
```
GET /notes
```

**Query Parameters:**
- `entity_type`: `candidate` | `application` | `job` | `interview`
- `entity_id`: UUID
- `note_type`: `general` | `feedback` | `action_item` | `follow_up`
- `is_pinned`: boolean
- `created_by`: UUID

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "entity_type": "application",
      "entity_id": "uuid",
      "content": "Strong candidate, excellent technical skills. Follow up on salary expectations.",
      "content_html": "<p>Strong candidate, excellent technical skills. Follow up on salary expectations.</p>",
      "note_type": "general",
      "is_pinned": true,
      "visibility": "team",
      "mentioned_users": [
        { "id": "uuid", "name": "Bob Johnson" }
      ],
      "action_item": null,
      "reactions": [
        { "reaction": "thumbs_up", "count": 2 }
      ],
      "replies_count": 1,
      "author": {
        "id": "uuid",
        "name": "Jane Smith",
        "avatar_url": "https://..."
      },
      "created_at": "2025-01-15T10:00:00Z",
      "updated_at": "2025-01-15T10:00:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

#### Create Note
```
POST /notes
```

**Request:**
```json
{
  "entity_type": "application",
  "entity_id": "uuid",
  "content": "Strong candidate, follow up with @[Bob Johnson](uuid) about technical assessment",
  "note_type": "action_item",
  "is_pinned": false,
  "visibility": "team",
  "action_item": {
    "due_date": "2025-01-20T17:00:00Z",
    "assigned_to_id": "uuid"
  }
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "mentioned_users_notified": true
  }
}
```

---

#### Update Note
```
PATCH /notes/{note_id}
```

---

#### Delete Note
```
DELETE /notes/{note_id}
```

---

#### Pin/Unpin Note
```
POST /notes/{note_id}/pin
DELETE /notes/{note_id}/pin
```

---

#### Add Reaction
```
POST /notes/{note_id}/reactions
```

**Request:**
```json
{
  "reaction": "thumbs_up"
}
```

---

#### Remove Reaction
```
DELETE /notes/{note_id}/reactions/{reaction}
```

---

#### Reply to Note
```
POST /notes/{note_id}/replies
```

**Request:**
```json
{
  "content": "I'll schedule the assessment for next week"
}
```

---

#### Complete Action Item
```
POST /notes/{note_id}/complete
```

---

## 12. Tags

### 12.1 Tag Management

#### List Tags
```
GET /tags
```

**Query Parameters:**
- `search`: search in name
- `entity_types`: filter by applicable entity types

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "High Priority",
      "slug": "high-priority",
      "description": "High priority candidates",
      "color": "#EF4444",
      "entity_types": ["candidate", "application"],
      "usage_count": 45
    },
    {
      "id": "uuid",
      "name": "Senior",
      "slug": "senior",
      "color": "#8B5CF6",
      "entity_types": ["candidate"],
      "usage_count": 120
    }
  ]
}
```

---

#### Create Tag
```
POST /tags
```

**Request:**
```json
{
  "name": "Urgent Hire",
  "description": "Must fill immediately",
  "color": "#DC2626",
  "entity_types": ["job", "application"]
}
```

---

#### Update Tag
```
PATCH /tags/{tag_id}
```

---

#### Delete Tag
```
DELETE /tags/{tag_id}
```

---

### 12.2 Saved Searches

#### List Saved Searches
```
GET /saved-searches
```

**Query Parameters:**
- `entity_type`: `candidate` | `job` | `application`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Senior React Developers",
      "description": "Senior candidates with React experience",
      "entity_type": "candidate",
      "filters": {
        "skills": [1, 2],
        "min_experience": 5,
        "status": "active"
      },
      "is_shared": true,
      "has_alerts": true,
      "alert_frequency": "daily",
      "last_used_at": "2025-01-15T10:00:00Z",
      "usage_count": 25,
      "result_count": 45
    }
  ]
}
```

---

#### Create Saved Search
```
POST /saved-searches
```

**Request:**
```json
{
  "name": "Python Backend Developers",
  "entity_type": "candidate",
  "filters": {
    "skills": [5, 10, 15],
    "min_experience": 3,
    "location_country_id": 1
  },
  "is_shared": false,
  "has_alerts": true,
  "alert_frequency": "weekly"
}
```

---

#### Execute Saved Search
```
GET /saved-searches/{search_id}/execute
```

**Query Parameters:** Standard pagination

---

### 12.3 Candidate Lists

#### List Candidate Lists
```
GET /candidate-lists
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Q1 Hiring Pool",
      "description": "Candidates for Q1 hiring",
      "list_type": "manual",
      "owner": { "id": "uuid", "name": "Jane Smith" },
      "is_shared": true,
      "candidate_count": 25,
      "created_at": "2025-01-01T10:00:00Z"
    }
  ]
}
```

---

#### Create Candidate List
```
POST /candidate-lists
```

**Request:**
```json
{
  "name": "Engineering Talent Pool",
  "description": "Candidates for future engineering roles",
  "list_type": "manual",
  "is_shared": true
}
```

---

#### Add Candidates to List
```
POST /candidate-lists/{list_id}/candidates
```

**Request:**
```json
{
  "candidate_ids": ["uuid1", "uuid2", "uuid3"]
}
```

---

#### Remove Candidate from List
```
DELETE /candidate-lists/{list_id}/candidates/{candidate_id}
```

---

#### Get List Candidates
```
GET /candidate-lists/{list_id}/candidates
```
