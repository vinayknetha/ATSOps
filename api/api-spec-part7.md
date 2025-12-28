## 11. Analytics & Reports

### 11.1 Dashboard Analytics

#### Get Dashboard Overview
```
GET /analytics/dashboard
```

**Query Parameters:**
- `from_date`: ISO date (default: 30 days ago)
- `to_date`: ISO date (default: today)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_candidates": 1250,
      "candidates_change": 15.2,
      "active_jobs": 12,
      "jobs_change": 2,
      "total_applications": 456,
      "applications_change": 23.5,
      "interviews_scheduled": 45,
      "offers_pending": 3,
      "hires_this_month": 5
    },
    "pipeline_overview": {
      "new": 125,
      "reviewed": 89,
      "interviewing": 45,
      "offer": 8,
      "hired": 5,
      "rejected": 184
    },
    "applications_trend": [
      { "date": "2025-01-01", "count": 12 },
      { "date": "2025-01-02", "count": 18 },
      { "date": "2025-01-03", "count": 15 }
    ],
    "source_breakdown": [
      { "source": "linkedin", "count": 156, "percentage": 34.2, "hires": 2 },
      { "source": "indeed", "count": 98, "percentage": 21.5, "hires": 1 },
      { "source": "referral", "count": 67, "percentage": 14.7, "hires": 2 },
      { "source": "career_site", "count": 89, "percentage": 19.5, "hires": 0 },
      { "source": "other", "count": 46, "percentage": 10.1, "hires": 0 }
    ],
    "top_jobs": [
      { "id": "uuid", "title": "Senior Software Engineer", "applications": 45, "hires": 1 },
      { "id": "uuid", "title": "Product Manager", "applications": 38, "hires": 0 },
      { "id": "uuid", "title": "Data Scientist", "applications": 32, "hires": 1 }
    ],
    "team_activity": [
      { "user": { "id": "uuid", "name": "Jane Smith" }, "reviews": 45, "interviews": 12, "hires": 2 },
      { "user": { "id": "uuid", "name": "Bob Johnson" }, "reviews": 38, "interviews": 8, "hires": 1 }
    ]
  }
}
```

---

#### Get Pipeline Analytics
```
GET /analytics/pipeline
```

**Query Parameters:**
- `from_date`, `to_date`
- `job_id`: UUID (optional, filter by job)
- `department_id`: UUID (optional)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "funnel": {
      "stages": [
        { "name": "Applied", "count": 500, "percentage": 100.0 },
        { "name": "Reviewed", "count": 350, "percentage": 70.0 },
        { "name": "Phone Screen", "count": 150, "percentage": 30.0 },
        { "name": "Technical Interview", "count": 80, "percentage": 16.0 },
        { "name": "Onsite", "count": 40, "percentage": 8.0 },
        { "name": "Offer", "count": 15, "percentage": 3.0 },
        { "name": "Hired", "count": 10, "percentage": 2.0 }
      ]
    },
    "conversion_rates": {
      "applied_to_reviewed": 0.70,
      "reviewed_to_phone_screen": 0.43,
      "phone_screen_to_technical": 0.53,
      "technical_to_onsite": 0.50,
      "onsite_to_offer": 0.375,
      "offer_to_hire": 0.67
    },
    "stage_durations": {
      "new": { "avg_days": 1.5, "median_days": 1.0 },
      "reviewed": { "avg_days": 3.2, "median_days": 2.0 },
      "phone_screen": { "avg_days": 5.5, "median_days": 4.0 },
      "technical": { "avg_days": 7.2, "median_days": 5.0 },
      "onsite": { "avg_days": 10.5, "median_days": 8.0 },
      "offer": { "avg_days": 5.0, "median_days": 3.0 }
    },
    "bottlenecks": [
      { "stage": "Technical Interview", "avg_wait_days": 7.2, "severity": "high" },
      { "stage": "Onsite", "avg_wait_days": 10.5, "severity": "medium" }
    ]
  }
}
```

---

#### Get Time-to-Hire Analytics
```
GET /analytics/time-to-hire
```

**Query Parameters:**
- `from_date`, `to_date`
- `job_id`, `department_id` (optional filters)
- `granularity`: `day` | `week` | `month`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "summary": {
      "avg_time_to_hire_days": 28.5,
      "median_time_to_hire_days": 24,
      "min_time_to_hire_days": 12,
      "max_time_to_hire_days": 65,
      "total_hires": 25,
      "change_vs_previous_period": -2.5
    },
    "by_department": [
      { "department": "Engineering", "avg_days": 32, "hires": 12 },
      { "department": "Sales", "avg_days": 21, "hires": 8 },
      { "department": "Marketing", "avg_days": 25, "hires": 5 }
    ],
    "by_source": [
      { "source": "referral", "avg_days": 18, "hires": 8 },
      { "source": "linkedin", "avg_days": 28, "hires": 10 },
      { "source": "career_site", "avg_days": 35, "hires": 7 }
    ],
    "trend": [
      { "period": "2024-10", "avg_days": 32, "hires": 6 },
      { "period": "2024-11", "avg_days": 30, "hires": 8 },
      { "period": "2024-12", "avg_days": 28, "hires": 5 },
      { "period": "2025-01", "avg_days": 26, "hires": 6 }
    ],
    "stage_breakdown": {
      "sourcing_to_application": { "avg_days": 0, "percentage": 0 },
      "application_to_screen": { "avg_days": 3, "percentage": 10.5 },
      "screen_to_interview": { "avg_days": 5, "percentage": 17.5 },
      "interview_to_offer": { "avg_days": 12, "percentage": 42.1 },
      "offer_to_hire": { "avg_days": 8.5, "percentage": 29.8 }
    }
  }
}
```

---

#### Get Source Analytics
```
GET /analytics/sources
```

**Query Parameters:**
- `from_date`, `to_date`
- `job_id` (optional)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "sources": [
      {
        "source": "linkedin",
        "applications": 156,
        "qualified": 89,
        "interviewed": 45,
        "offered": 8,
        "hired": 3,
        "conversion_rate": 0.019,
        "quality_score": 72.5,
        "avg_match_score": 75.2,
        "cost": 2500,
        "cost_per_application": 16.03,
        "cost_per_hire": 833.33
      },
      {
        "source": "indeed",
        "applications": 98,
        "qualified": 52,
        "interviewed": 28,
        "offered": 4,
        "hired": 2,
        "conversion_rate": 0.020,
        "quality_score": 65.8,
        "cost": 1200,
        "cost_per_hire": 600.00
      },
      {
        "source": "referral",
        "applications": 45,
        "qualified": 38,
        "interviewed": 25,
        "offered": 6,
        "hired": 4,
        "conversion_rate": 0.089,
        "quality_score": 85.2,
        "cost": 4000,
        "cost_per_hire": 1000.00
      }
    ],
    "comparison": {
      "best_volume": "linkedin",
      "best_quality": "referral",
      "best_cost_efficiency": "indeed",
      "best_conversion": "referral"
    }
  }
}
```

---

#### Get Recruiter Performance
```
GET /analytics/recruiter-performance
```

**Query Parameters:**
- `from_date`, `to_date`
- `user_id` (optional, filter to specific user)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "recruiters": [
      {
        "user": { "id": "uuid", "name": "Jane Smith", "avatar_url": "..." },
        "metrics": {
          "applications_reviewed": 156,
          "candidates_sourced": 45,
          "interviews_scheduled": 38,
          "interviews_conducted": 25,
          "offers_extended": 8,
          "hires": 5,
          "avg_time_to_fill_days": 24,
          "avg_candidate_rating": 4.2,
          "response_time_hours": 4.5
        },
        "trend": {
          "hires_change": 25,
          "efficiency_change": 15
        }
      }
    ],
    "team_totals": {
      "applications_reviewed": 456,
      "interviews_scheduled": 125,
      "hires": 15
    }
  }
}
```

---

### 11.2 Custom Reports

#### List Report Definitions
```
GET /reports
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Weekly Hiring Summary",
      "description": "Weekly overview of hiring activity",
      "report_type": "pipeline",
      "is_scheduled": true,
      "schedule_frequency": "weekly",
      "last_sent_at": "2025-01-13T09:00:00Z",
      "created_at": "2024-12-01T10:00:00Z"
    }
  ]
}
```

---

#### Create Report
```
POST /reports
```

**Request:**
```json
{
  "name": "Engineering Hiring Report",
  "description": "Monthly report on engineering hiring",
  "report_type": "pipeline",
  "filters": {
    "department_id": "uuid"
  },
  "metrics": ["applications", "interviews", "offers", "hires", "time_to_hire"],
  "groupings": ["job", "source"],
  "date_range_type": "last_30_days",
  "chart_type": "bar",
  "is_scheduled": true,
  "schedule_frequency": "monthly",
  "schedule_day": 1,
  "schedule_time": "09:00",
  "schedule_recipients": ["jane@acme.com", "hr@acme.com"]
}
```

---

#### Generate Report
```
POST /reports/{report_id}/generate
```

**Query Parameters:**
- `format`: `json` | `csv` | `pdf` | `xlsx`
- `from_date`, `to_date` (override saved dates)

**Response (200):** Report data or file download

---

#### Export Data
```
POST /analytics/export
```

**Request:**
```json
{
  "entity_type": "applications",
  "filters": {
    "job_id": "uuid",
    "from_date": "2025-01-01",
    "to_date": "2025-01-31"
  },
  "fields": ["candidate_name", "job_title", "status", "score", "applied_at"],
  "format": "csv"
}
```

**Response (202):**
```json
{
  "success": true,
  "data": {
    "export_id": "uuid",
    "status": "processing",
    "estimated_completion": "2025-01-15T10:35:00Z"
  }
}
```

---

#### Get Export Status/Download
```
GET /analytics/export/{export_id}
```

---

## 12. Integrations & Webhooks

### 12.1 Integration Providers

#### List Available Integrations
```
GET /integrations/providers
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "code": "google_calendar",
      "name": "Google Calendar",
      "description": "Sync interviews with Google Calendar",
      "category": "calendar",
      "logo_url": "https://...",
      "features": ["calendar_sync", "availability_check"],
      "is_available": true,
      "required_tier": "starter"
    },
    {
      "id": 2,
      "code": "slack",
      "name": "Slack",
      "description": "Get notifications in Slack",
      "category": "communication",
      "logo_url": "https://...",
      "features": ["notifications", "commands"],
      "is_available": true,
      "required_tier": "pro"
    },
    {
      "id": 3,
      "code": "linkedin_rsc",
      "name": "LinkedIn Recruiter",
      "description": "Import candidates from LinkedIn",
      "category": "sourcing",
      "logo_url": "https://...",
      "is_available": false,
      "coming_soon": true
    }
  ]
}
```

---

### 12.2 Organization Integrations

#### List Connected Integrations
```
GET /integrations
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "provider": {
        "id": 1,
        "code": "google_calendar",
        "name": "Google Calendar"
      },
      "status": "active",
      "external_account": {
        "id": "google_account_123",
        "name": "hr@acme.com"
      },
      "settings": {
        "sync_interviews": true,
        "default_calendar_id": "primary"
      },
      "last_sync_at": "2025-01-15T10:00:00Z",
      "last_sync_status": "success",
      "connected_at": "2024-12-01T10:00:00Z"
    },
    {
      "id": "uuid",
      "provider": {
        "id": 5,
        "code": "sendgrid",
        "name": "SendGrid"
      },
      "status": "active",
      "settings": {
        "sender_email": "jobs@acme.com",
        "sender_name": "Acme Careers"
      },
      "api_calls_today": 45,
      "connected_at": "2024-11-15T10:00:00Z"
    }
  ]
}
```

---

#### Connect Integration (OAuth)
```
GET /integrations/{provider_code}/connect
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "authorization_url": "https://accounts.google.com/o/oauth2/v2/auth?...",
    "state": "random_state_token"
  }
}
```

---

#### OAuth Callback
```
POST /integrations/{provider_code}/callback
```

**Request:**
```json
{
  "code": "oauth_authorization_code",
  "state": "random_state_token"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "active",
    "external_account": {
      "id": "account_123",
      "name": "user@gmail.com"
    }
  }
}
```

---

#### Connect Integration (API Key)
```
POST /integrations/{provider_code}/connect
```

**Request:**
```json
{
  "api_key": "sendgrid_api_key_here",
  "settings": {
    "sender_email": "jobs@acme.com",
    "sender_name": "Acme Careers"
  }
}
```

---

#### Update Integration Settings
```
PATCH /integrations/{integration_id}
```

**Request:**
```json
{
  "settings": {
    "sync_interviews": true,
    "default_calendar_id": "work_calendar"
  }
}
```

---

#### Disconnect Integration
```
DELETE /integrations/{integration_id}
```

---

#### Sync Integration
```
POST /integrations/{integration_id}/sync
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "sync_id": "uuid",
    "status": "started",
    "started_at": "2025-01-15T10:30:00Z"
  }
}
```

---

#### Get Sync Logs
```
GET /integrations/{integration_id}/sync-logs
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "sync_type": "incremental",
      "direction": "outbound",
      "status": "completed",
      "records_processed": 15,
      "records_created": 3,
      "records_updated": 12,
      "records_failed": 0,
      "started_at": "2025-01-15T10:00:00Z",
      "completed_at": "2025-01-15T10:02:30Z",
      "duration_seconds": 150
    }
  ],
  "pagination": { ... }
}
```

---

### 12.3 Webhooks

#### List Webhook Endpoints
```
GET /webhooks
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "ATS Sync Webhook",
      "url": "https://myapp.com/webhooks/talentforge",
      "subscribed_events": [
        "candidate.created",
        "application.created",
        "application.stage_changed",
        "interview.scheduled",
        "offer.accepted"
      ],
      "is_active": true,
      "statistics": {
        "total_deliveries": 1250,
        "successful_deliveries": 1245,
        "failed_deliveries": 5
      },
      "last_delivery_at": "2025-01-15T10:00:00Z",
      "last_delivery_status": "success",
      "created_at": "2024-10-01T10:00:00Z"
    }
  ]
}
```

---

#### Create Webhook Endpoint
```
POST /webhooks
```

**Request:**
```json
{
  "name": "HR System Integration",
  "url": "https://hr.acme.com/webhooks/talentforge",
  "subscribed_events": [
    "candidate.created",
    "candidate.updated",
    "application.created",
    "application.stage_changed",
    "interview.scheduled",
    "interview.completed",
    "offer.sent",
    "offer.accepted",
    "offer.declined"
  ],
  "auth_type": "hmac",
  "retry_count": 3,
  "timeout_seconds": 30
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "secret_key": "whsec_abc123...",
    "url": "https://hr.acme.com/webhooks/talentforge"
  }
}
```

---

#### Update Webhook Endpoint
```
PATCH /webhooks/{webhook_id}
```

---

#### Delete Webhook Endpoint
```
DELETE /webhooks/{webhook_id}
```

---

#### Get Webhook Deliveries
```
GET /webhooks/{webhook_id}/deliveries
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "event_type": "application.stage_changed",
      "event_id": "uuid",
      "status": "success",
      "response_code": 200,
      "attempted_at": "2025-01-15T10:00:00Z",
      "duration_ms": 145,
      "attempt_number": 1
    },
    {
      "id": "uuid",
      "event_type": "candidate.created",
      "event_id": "uuid",
      "status": "failed",
      "response_code": 500,
      "error_message": "Internal Server Error",
      "attempted_at": "2025-01-15T09:30:00Z",
      "next_retry_at": "2025-01-15T09:35:00Z",
      "attempt_number": 2
    }
  ],
  "pagination": { ... }
}
```

---

#### Retry Webhook Delivery
```
POST /webhooks/deliveries/{delivery_id}/retry
```

---

#### Test Webhook
```
POST /webhooks/{webhook_id}/test
```

**Request:**
```json
{
  "event_type": "application.created"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "delivery_id": "uuid",
    "status": "success",
    "response_code": 200,
    "response_body": "{\"received\": true}",
    "duration_ms": 125
  }
}
```

---

#### Available Webhook Events
```
GET /webhooks/events
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "event": "candidate.created",
      "description": "Triggered when a new candidate is created",
      "payload_example": {
        "event": "candidate.created",
        "timestamp": "2025-01-15T10:00:00Z",
        "data": {
          "candidate_id": "uuid",
          "email": "john@email.com",
          "name": "John Doe"
        }
      }
    },
    {
      "event": "application.created",
      "description": "Triggered when a new application is submitted"
    },
    {
      "event": "application.stage_changed",
      "description": "Triggered when an application moves to a new stage"
    }
  ]
}
```

---

## 13. Billing & Subscriptions

### 13.1 Subscription Management

#### Get Current Subscription
```
GET /billing/subscription
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "plan": {
      "id": 3,
      "code": "pro",
      "name": "Professional",
      "tier": "pro",
      "price_monthly": 149,
      "price_yearly": 1490
    },
    "status": "active",
    "billing_cycle": "monthly",
    "current_period": {
      "start": "2025-01-01T00:00:00Z",
      "end": "2025-01-31T23:59:59Z"
    },
    "usage": {
      "users": { "used": 5, "limit": 10, "percentage": 50 },
      "jobs": { "used": 8, "limit": 25, "percentage": 32 },
      "candidates_this_month": { "used": 234, "limit": 1000, "percentage": 23.4 }
    },
    "payment_method": {
      "type": "card",
      "brand": "visa",
      "last4": "4242",
      "exp_month": 12,
      "exp_year": 2026
    },
    "cancel_at_period_end": false,
    "next_invoice_date": "2025-02-01T00:00:00Z",
    "next_invoice_amount": 149
  }
}
```

---

#### List Available Plans
```
GET /billing/plans
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "code": "free",
      "name": "Free",
      "tier": "free",
      "price_monthly": 0,
      "price_yearly": 0,
      "limits": {
        "max_users": 1,
        "max_jobs": 1,
        "max_candidates_per_month": 25
      },
      "features": {
        "ai_matching": true,
        "portfolio_generation": false,
        "api_access": false,
        "custom_pipelines": false,
        "integrations": 0
      },
      "is_current": false
    },
    {
      "id": 2,
      "code": "starter",
      "name": "Starter",
      "price_monthly": 49,
      "price_yearly": 490,
      "limits": {
        "max_users": 3,
        "max_jobs": 5,
        "max_candidates_per_month": 200
      },
      "features": {
        "ai_matching": true,
        "portfolio_generation": true,
        "api_access": false,
        "custom_pipelines": true,
        "integrations": 3
      },
      "is_current": false
    },
    {
      "id": 3,
      "code": "pro",
      "name": "Professional",
      "price_monthly": 149,
      "price_yearly": 1490,
      "is_current": true,
      "is_popular": true
    }
  ]
}
```

---

#### Upgrade/Downgrade Subscription
```
POST /billing/subscription/change
```

**Request:**
```json
{
  "plan_code": "business",
  "billing_cycle": "yearly",
  "promo_code": "SAVE20"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "subscription_id": "uuid",
    "new_plan": "business",
    "billing_cycle": "yearly",
    "effective_date": "2025-02-01T00:00:00Z",
    "proration": {
      "credit": 75.50,
      "charge": 2990,
      "net_amount": 2914.50
    }
  }
}
```

---

#### Cancel Subscription
```
POST /billing/subscription/cancel
```

**Request:**
```json
{
  "reason": "Too expensive",
  "feedback": "Love the product but budget constraints",
  "cancel_immediately": false
}
```

---

#### Resume Subscription
```
POST /billing/subscription/resume
```

---

### 13.2 Payment Methods

#### List Payment Methods
```
GET /billing/payment-methods
```

---

#### Add Payment Method
```
POST /billing/payment-methods
```

**Request:**
```json
{
  "payment_method_id": "pm_stripe_payment_method_id",
  "set_as_default": true
}
```

---

#### Remove Payment Method
```
DELETE /billing/payment-methods/{payment_method_id}
```

---

#### Set Default Payment Method
```
POST /billing/payment-methods/{payment_method_id}/default
```

---

### 13.3 Invoices

#### List Invoices
```
GET /billing/invoices
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "invoice_number": "INV-2025-0001",
      "status": "paid",
      "total": 149.00,
      "currency": "USD",
      "period": {
        "start": "2025-01-01",
        "end": "2025-01-31"
      },
      "issued_at": "2025-01-01T00:00:00Z",
      "paid_at": "2025-01-01T00:05:00Z",
      "pdf_url": "https://..."
    }
  ],
  "pagination": { ... }
}
```

---

#### Get Invoice Details
```
GET /billing/invoices/{invoice_id}
```

---

#### Download Invoice PDF
```
GET /billing/invoices/{invoice_id}/pdf
```

---

### 13.4 Usage

#### Get Current Usage
```
GET /billing/usage
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "period": {
      "start": "2025-01-01T00:00:00Z",
      "end": "2025-01-31T23:59:59Z"
    },
    "users": {
      "current": 5,
      "limit": 10,
      "active_this_month": 5
    },
    "jobs": {
      "total": 12,
      "active": 8,
      "limit": 25
    },
    "candidates": {
      "total": 1250,
      "added_this_month": 234,
      "limit_per_month": 1000
    },
    "api_calls": {
      "this_month": 4567,
      "limit": null
    },
    "storage": {
      "used_gb": 2.5,
      "limit_gb": 10
    }
  }
}
```

---

#### Get Usage History
```
GET /billing/usage/history
```

**Query Parameters:**
- `months`: number of months (default: 6)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "period": "2025-01",
      "candidates_added": 234,
      "applications_received": 456,
      "emails_sent": 890,
      "api_calls": 4567
    },
    {
      "period": "2024-12",
      "candidates_added": 198,
      "applications_received": 378,
      "emails_sent": 756,
      "api_calls": 3890
    }
  ]
}
```
