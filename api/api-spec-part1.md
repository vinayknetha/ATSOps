# TalentForge ATS - Complete API Specification

## Overview

**Base URL:** `https://api.talentforge.io/v1`  
**Authentication:** Bearer JWT Token  
**Content-Type:** `application/json`  
**API Version:** v1  

---

## Table of Contents

1. [Authentication & Authorization](#1-authentication--authorization)
2. [Organizations](#2-organizations)
3. [Users & Teams](#3-users--teams)
4. [Candidates](#4-candidates)
5. [Jobs & Requisitions](#5-jobs--requisitions)
6. [Applications](#6-applications)
7. [Interviews](#7-interviews)
8. [Offers](#8-offers)
9. [Communications](#9-communications)
10. [Documents](#10-documents)
11. [Analytics & Reports](#11-analytics--reports)
12. [Integrations & Webhooks](#12-integrations--webhooks)
13. [Billing & Subscriptions](#13-billing--subscriptions)
14. [Search & Matching](#14-search--matching)
15. [Skills & Taxonomy](#15-skills--taxonomy)
16. [Settings & Configuration](#16-settings--configuration)

---

## Common Response Formats

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "request_id": "uuid",
    "timestamp": "2025-01-15T10:30:00Z"
  }
}
```

### Paginated Response
```json
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_items": 150,
    "total_pages": 8,
    "has_next": true,
    "has_prev": false
  },
  "meta": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  },
  "meta": { ... }
}
```

### Common HTTP Status Codes
| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (successful delete) |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (invalid/missing token) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 409 | Conflict (duplicate resource) |
| 422 | Unprocessable Entity |
| 429 | Rate Limited |
| 500 | Internal Server Error |

---

## 1. Authentication & Authorization

### 1.1 Email/Password Authentication

#### Register Organization (Sign Up)
```
POST /auth/register
```

**Request:**
```json
{
  "organization": {
    "name": "Acme Corp",
    "slug": "acme-corp"
  },
  "user": {
    "email": "admin@acme.com",
    "password": "SecurePass123!",
    "first_name": "John",
    "last_name": "Doe"
  },
  "terms_accepted": true
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "organization": {
      "id": "uuid",
      "name": "Acme Corp",
      "slug": "acme-corp",
      "subscription_tier": "free",
      "subscription_status": "trial",
      "trial_ends_at": "2025-02-15T00:00:00Z"
    },
    "user": {
      "id": "uuid",
      "email": "admin@acme.com",
      "first_name": "John",
      "last_name": "Doe",
      "role": "admin",
      "status": "pending"
    },
    "verification_email_sent": true
  }
}
```

**Business Logic:**
- Create organization with trial subscription
- Create admin user with pending status
- Send email verification link
- Generate initial pipeline templates
- Log audit event

---

#### Login
```
POST /auth/login
```

**Request:**
```json
{
  "email": "admin@acme.com",
  "password": "SecurePass123!",
  "remember_me": true
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "token_type": "Bearer",
    "expires_in": 900,
    "user": {
      "id": "uuid",
      "email": "admin@acme.com",
      "first_name": "John",
      "last_name": "Doe",
      "role": "admin",
      "organization": {
        "id": "uuid",
        "name": "Acme Corp",
        "slug": "acme-corp"
      },
      "permissions": ["jobs.create", "candidates.view", ...]
    }
  }
}
```

**Business Logic:**
- Validate credentials against bcrypt hash
- Check if user is active and email verified
- Check failed login attempts (lock after 5)
- Generate JWT access token (15 min) and refresh token (7 days)
- Create session record
- Update last_login_at
- Log audit event

---

#### Refresh Token
```
POST /auth/refresh
```

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 900
  }
}
```

---

#### Logout
```
POST /auth/logout
```

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "message": "Successfully logged out"
}
```

**Business Logic:**
- Revoke current session
- Invalidate refresh token
- Log audit event

---

#### Logout All Devices
```
POST /auth/logout-all
```

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "message": "Logged out from all devices",
  "sessions_revoked": 3
}
```

---

### 1.2 Email Verification

#### Verify Email
```
POST /auth/verify-email
```

**Request:**
```json
{
  "token": "verification_token_from_email"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Email verified successfully",
  "data": {
    "user": {
      "id": "uuid",
      "email": "admin@acme.com",
      "email_verified_at": "2025-01-15T10:30:00Z",
      "status": "active"
    }
  }
}
```

---

#### Resend Verification Email
```
POST /auth/verify-email/resend
```

**Request:**
```json
{
  "email": "admin@acme.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Verification email sent"
}
```

---

### 1.3 Password Management

#### Forgot Password
```
POST /auth/forgot-password
```

**Request:**
```json
{
  "email": "admin@acme.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "If an account exists, a password reset email has been sent"
}
```

**Business Logic:**
- Always return success (security - don't reveal if email exists)
- Generate secure reset token (expires in 1 hour)
- Send reset email with link
- Log audit event

---

#### Reset Password
```
POST /auth/reset-password
```

**Request:**
```json
{
  "token": "reset_token_from_email",
  "password": "NewSecurePass123!",
  "password_confirmation": "NewSecurePass123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

**Business Logic:**
- Validate token not expired
- Validate password strength
- Update password hash
- Invalidate all existing sessions
- Send confirmation email
- Log audit event

---

#### Change Password (Authenticated)
```
POST /auth/change-password
```

**Headers:** `Authorization: Bearer <access_token>`

**Request:**
```json
{
  "current_password": "OldPass123!",
  "new_password": "NewSecurePass123!",
  "new_password_confirmation": "NewSecurePass123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

### 1.4 OAuth Authentication

#### Get OAuth URL
```
GET /auth/oauth/{provider}
```

**Parameters:**
- `provider`: `google` | `microsoft` | `linkedin`

**Query:**
- `redirect_uri`: Where to redirect after OAuth

**Response (200):**
```json
{
  "success": true,
  "data": {
    "authorization_url": "https://accounts.google.com/o/oauth2/v2/auth?...",
    "state": "random_state_string"
  }
}
```

---

#### OAuth Callback
```
POST /auth/oauth/{provider}/callback
```

**Request:**
```json
{
  "code": "oauth_authorization_code",
  "state": "random_state_string"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "is_new_user": false,
    "user": { ... }
  }
}
```

**Business Logic:**
- Exchange code for OAuth tokens
- Fetch user profile from provider
- If existing user: link OAuth account, log in
- If new user: create account, prompt for org details
- Store encrypted OAuth tokens
- Log audit event

---

#### Connect OAuth Account (Existing User)
```
POST /auth/oauth/{provider}/connect
```

**Headers:** `Authorization: Bearer <access_token>`

**Request:**
```json
{
  "code": "oauth_authorization_code",
  "state": "random_state_string"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Google account connected successfully",
  "data": {
    "provider": "google",
    "provider_email": "user@gmail.com",
    "connected_at": "2025-01-15T10:30:00Z"
  }
}
```

---

#### Disconnect OAuth Account
```
DELETE /auth/oauth/{provider}
```

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "message": "Google account disconnected"
}
```

---

### 1.5 Multi-Factor Authentication (MFA)

#### Get MFA Status
```
GET /auth/mfa
```

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "mfa_enabled": true,
    "methods": [
      {
        "type": "totp",
        "is_enabled": true,
        "is_verified": true,
        "verified_at": "2025-01-10T10:00:00Z"
      },
      {
        "type": "sms",
        "is_enabled": false,
        "phone_last_4": null
      }
    ],
    "backup_codes_remaining": 8
  }
}
```

---

#### Setup TOTP
```
POST /auth/mfa/totp/setup
```

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "secret": "JBSWY3DPEHPK3PXP",
    "qr_code_url": "data:image/png;base64,...",
    "manual_entry_key": "JBSW Y3DP EHPK 3PXP"
  }
}
```

---

#### Verify & Enable TOTP
```
POST /auth/mfa/totp/verify
```

**Headers:** `Authorization: Bearer <access_token>`

**Request:**
```json
{
  "code": "123456"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "TOTP enabled successfully",
  "data": {
    "backup_codes": [
      "abc12-def34",
      "ghi56-jkl78",
      ...
    ]
  }
}
```

---

#### Verify MFA During Login
```
POST /auth/mfa/verify
```

**Request:**
```json
{
  "mfa_token": "temporary_mfa_token",
  "code": "123456",
  "type": "totp"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "user": { ... }
  }
}
```

---

#### Disable MFA
```
DELETE /auth/mfa/{type}
```

**Headers:** `Authorization: Bearer <access_token>`

**Request:**
```json
{
  "password": "CurrentPassword123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "TOTP disabled successfully"
}
```

---

### 1.6 Sessions

#### List Active Sessions
```
GET /auth/sessions
```

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "device_type": "desktop",
      "device_name": "Chrome on MacOS",
      "browser": "Chrome 120",
      "os": "MacOS 14",
      "ip_address": "192.168.1.1",
      "location": "San Francisco, US",
      "last_used_at": "2025-01-15T10:30:00Z",
      "created_at": "2025-01-10T08:00:00Z",
      "is_current": true
    },
    {
      "id": "uuid",
      "device_type": "mobile",
      "device_name": "Safari on iOS",
      ...
    }
  ]
}
```

---

#### Revoke Session
```
DELETE /auth/sessions/{session_id}
```

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "message": "Session revoked"
}
```

---

## 2. Organizations

### 2.1 Organization Management

#### Get Current Organization
```
GET /organization
```

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Acme Corp",
    "slug": "acme-corp",
    "legal_name": "Acme Corporation Inc.",
    "email": "hr@acme.com",
    "phone": "+1-555-123-4567",
    "website": "https://acme.com",
    "address": {
      "line1": "123 Main St",
      "line2": "Suite 100",
      "city": "San Francisco",
      "state": "California",
      "country": "United States",
      "postal_code": "94105"
    },
    "industry": {
      "id": 1,
      "name": "Technology"
    },
    "company_size": "51-200",
    "founded_year": 2015,
    "description": "Leading tech company...",
    "branding": {
      "logo_url": "https://...",
      "primary_color": "#4F46E5",
      "secondary_color": "#F59E0B"
    },
    "subscription": {
      "tier": "pro",
      "status": "active",
      "current_period_end": "2025-02-15T00:00:00Z",
      "limits": {
        "max_users": 10,
        "max_jobs": 25,
        "max_candidates_per_month": 1000,
        "current_users": 5,
        "current_active_jobs": 8,
        "candidates_this_month": 234
      }
    },
    "settings": {
      "timezone": "America/Los_Angeles",
      "date_format": "MM/DD/YYYY",
      "default_language": "en"
    },
    "features_enabled": {
      "ai_matching": true,
      "portfolio_generation": true,
      "api_access": true,
      "custom_pipelines": true
    },
    "created_at": "2024-06-15T10:00:00Z"
  }
}
```

---

#### Update Organization
```
PATCH /organization
```

**Headers:** `Authorization: Bearer <access_token>`  
**Permission Required:** `settings.edit`

**Request:**
```json
{
  "name": "Acme Corp",
  "legal_name": "Acme Corporation Inc.",
  "email": "hr@acme.com",
  "phone": "+1-555-123-4567",
  "website": "https://acme.com",
  "description": "Updated description...",
  "industry_id": 1,
  "company_size": "51-200",
  "address": {
    "line1": "123 Main St",
    "line2": "Suite 100",
    "city_id": 1234,
    "postal_code": "94105"
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "data": { ... }
}
```

---

#### Update Organization Branding
```
PATCH /organization/branding
```

**Headers:** `Authorization: Bearer <access_token>`  
**Permission Required:** `settings.edit`

**Request (multipart/form-data):**
```
logo: [file]
primary_color: #4F46E5
secondary_color: #F59E0B
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "logo_url": "https://cdn.talentforge.io/orgs/uuid/logo.png",
    "primary_color": "#4F46E5",
    "secondary_color": "#F59E0B"
  }
}
```

---

#### Update Organization Settings
```
PATCH /organization/settings
```

**Headers:** `Authorization: Bearer <access_token>`  
**Permission Required:** `settings.edit`

**Request:**
```json
{
  "timezone": "America/Los_Angeles",
  "date_format": "MM/DD/YYYY",
  "default_language": "en",
  "email_sender_name": "Acme HR Team",
  "career_page_enabled": true,
  "career_page_url": "https://careers.acme.com",
  "auto_reject_threshold": 30,
  "gdpr_enabled": true,
  "data_retention_days": 365
}
```

---

### 2.2 Departments

#### List Departments
```
GET /organization/departments
```

**Headers:** `Authorization: Bearer <access_token>`

**Query Parameters:**
- `include_inactive`: boolean (default: false)
- `include_counts`: boolean (default: false)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Engineering",
      "code": "ENG",
      "parent_id": null,
      "head": {
        "id": "uuid",
        "name": "Jane Smith"
      },
      "description": "Software engineering team",
      "is_active": true,
      "job_count": 5,
      "user_count": 12,
      "children": [
        {
          "id": "uuid",
          "name": "Frontend",
          "code": "ENG-FE",
          "parent_id": "parent_uuid",
          ...
        },
        {
          "id": "uuid",
          "name": "Backend",
          "code": "ENG-BE",
          ...
        }
      ]
    },
    {
      "id": "uuid",
      "name": "Marketing",
      ...
    }
  ]
}
```

---

#### Create Department
```
POST /organization/departments
```

**Headers:** `Authorization: Bearer <access_token>`  
**Permission Required:** `settings.edit`

**Request:**
```json
{
  "name": "Data Science",
  "code": "DS",
  "parent_id": "engineering_uuid",
  "head_user_id": "uuid",
  "description": "Data science and ML team"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Data Science",
    ...
  }
}
```

---

#### Update Department
```
PATCH /organization/departments/{department_id}
```

---

#### Delete Department
```
DELETE /organization/departments/{department_id}
```

**Business Logic:**
- Check no users assigned
- Check no jobs assigned
- Soft delete

---

### 2.3 Locations

#### List Locations
```
GET /organization/locations
```

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Headquarters",
      "location_type": "office",
      "address": {
        "line1": "123 Main St",
        "city": "San Francisco",
        "state": "California",
        "country": "United States",
        "postal_code": "94105"
      },
      "coordinates": {
        "latitude": 37.7749,
        "longitude": -122.4194
      },
      "timezone": "America/Los_Angeles",
      "phone": "+1-555-123-4567",
      "email": "sf@acme.com",
      "is_headquarters": true,
      "is_hiring_location": true,
      "is_active": true,
      "job_count": 8
    }
  ]
}
```

---

#### Create Location
```
POST /organization/locations
```

**Request:**
```json
{
  "name": "New York Office",
  "location_type": "office",
  "address_line1": "456 Broadway",
  "city_id": 5678,
  "country_id": 1,
  "postal_code": "10013",
  "phone": "+1-555-987-6543",
  "is_headquarters": false,
  "is_hiring_location": true
}
```

---

#### Update Location
```
PATCH /organization/locations/{location_id}
```

---

#### Delete Location
```
DELETE /organization/locations/{location_id}
```

---

## 3. Users & Teams

### 3.1 User Management

#### List Users
```
GET /users
```

**Headers:** `Authorization: Bearer <access_token>`  
**Permission Required:** `users.manage` (for full list) or team members only

**Query Parameters:**
- `page`: integer (default: 1)
- `per_page`: integer (default: 20, max: 100)
- `status`: `active` | `inactive` | `pending` | `locked`
- `role`: user_role enum
- `department_id`: UUID
- `search`: string (searches name, email)
- `sort_by`: `name` | `email` | `created_at` | `last_login_at`
- `sort_dir`: `asc` | `desc`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "email": "jane@acme.com",
      "first_name": "Jane",
      "last_name": "Smith",
      "display_name": "Jane Smith",
      "avatar_url": "https://...",
      "job_title": "Senior Recruiter",
      "department": {
        "id": "uuid",
        "name": "Human Resources"
      },
      "role": "recruiter",
      "status": "active",
      "last_login_at": "2025-01-15T08:00:00Z",
      "created_at": "2024-06-20T10:00:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

#### Get User Details
```
GET /users/{user_id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "jane@acme.com",
    "email_verified_at": "2024-06-20T10:30:00Z",
    "phone": "+1-555-123-4567",
    "first_name": "Jane",
    "last_name": "Smith",
    "display_name": "Jane Smith",
    "avatar_url": "https://...",
    "job_title": "Senior Recruiter",
    "department": {
      "id": "uuid",
      "name": "Human Resources"
    },
    "role": "recruiter",
    "permissions": ["jobs.view", "jobs.create", "candidates.view", ...],
    "permission_overrides": [
      { "permission": "reports.export", "is_granted": true }
    ],
    "status": "active",
    "timezone": "America/Los_Angeles",
    "locale": "en-US",
    "notification_settings": {
      "email_new_application": true,
      "email_interview_reminder": true,
      "slack_mentions": true
    },
    "stats": {
      "active_jobs": 5,
      "candidates_reviewed_this_month": 45,
      "interviews_conducted_this_month": 12
    },
    "last_login_at": "2025-01-15T08:00:00Z",
    "last_activity_at": "2025-01-15T10:30:00Z",
    "created_at": "2024-06-20T10:00:00Z"
  }
}
```

---

#### Create User
```
POST /users
```

**Permission Required:** `users.manage`

**Request:**
```json
{
  "email": "new.user@acme.com",
  "first_name": "New",
  "last_name": "User",
  "job_title": "Recruiter",
  "department_id": "uuid",
  "role": "recruiter",
  "send_invitation": true,
  "personal_message": "Welcome to the team!"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "new.user@acme.com",
    "status": "pending",
    "invitation_sent_at": "2025-01-15T10:30:00Z"
  }
}
```

**Business Logic:**
- Check organization user limit
- Create user with pending status
- Send invitation email
- Log audit event

---

#### Update User
```
PATCH /users/{user_id}
```

**Permission Required:** `users.manage` or self

**Request:**
```json
{
  "first_name": "Jane",
  "last_name": "Smith",
  "job_title": "Lead Recruiter",
  "department_id": "uuid",
  "role": "recruiter",
  "status": "active"
}
```

---

#### Delete User
```
DELETE /users/{user_id}
```

**Permission Required:** `users.manage`

**Business Logic:**
- Cannot delete self
- Cannot delete last admin
- Reassign or unassign jobs
- Soft delete
- Revoke all sessions
- Log audit event

---

#### Update User Permissions
```
PATCH /users/{user_id}/permissions
```

**Permission Required:** `users.manage`

**Request:**
```json
{
  "role": "recruiter",
  "permission_overrides": [
    { "permission_code": "reports.export", "is_granted": true },
    { "permission_code": "offers.approve", "is_granted": false }
  ]
}
```

---

### 3.2 User Invitations

#### List Pending Invitations
```
GET /users/invitations
```

**Permission Required:** `users.manage`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "email": "pending@acme.com",
      "role": "recruiter",
      "department": {
        "id": "uuid",
        "name": "Engineering"
      },
      "invited_by": {
        "id": "uuid",
        "name": "Jane Smith"
      },
      "expires_at": "2025-01-22T10:30:00Z",
      "created_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

---

#### Resend Invitation
```
POST /users/invitations/{invitation_id}/resend
```

---

#### Revoke Invitation
```
DELETE /users/invitations/{invitation_id}
```

---

#### Accept Invitation
```
POST /users/invitations/accept
```

**Request:**
```json
{
  "token": "invitation_token",
  "password": "SecurePass123!",
  "password_confirmation": "SecurePass123!"
}
```

---

### 3.3 Current User Profile

#### Get My Profile
```
GET /me
```

**Response:** Same as GET /users/{user_id} for current user

---

#### Update My Profile
```
PATCH /me
```

**Request:**
```json
{
  "first_name": "Jane",
  "last_name": "Smith",
  "display_name": "Jane S.",
  "phone": "+1-555-123-4567",
  "timezone": "America/Los_Angeles",
  "locale": "en-US"
}
```

---

#### Update My Avatar
```
POST /me/avatar
```

**Request (multipart/form-data):**
```
avatar: [file]
```

---

#### Delete My Avatar
```
DELETE /me/avatar
```

---

#### Update My Notification Settings
```
PATCH /me/notifications
```

**Request:**
```json
{
  "email_new_application": true,
  "email_stage_change": true,
  "email_interview_reminder": true,
  "email_daily_digest": false,
  "email_weekly_report": true,
  "push_enabled": true,
  "slack_mentions": true,
  "slack_dm_enabled": false
}
```

---

### 3.4 Team Activity

#### Get Team Activity Feed
```
GET /users/activity
```

**Query Parameters:**
- `page`, `per_page`
- `user_id`: filter by user
- `activity_type`: filter by type
- `entity_type`: filter by entity
- `from_date`, `to_date`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "user": {
        "id": "uuid",
        "name": "Jane Smith",
        "avatar_url": "https://..."
      },
      "activity_type": "stage_changed",
      "title": "Moved John Doe to Interview stage",
      "description": "Application for Senior Developer",
      "entity_type": "application",
      "entity_id": "uuid",
      "related_entity": {
        "type": "job",
        "id": "uuid",
        "title": "Senior Developer"
      },
      "created_at": "2025-01-15T10:30:00Z"
    }
  ],
  "pagination": { ... }
}
```
