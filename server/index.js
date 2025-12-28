const express = require('express');
const { Pool } = require('pg');
const multer = require('multer');
const mammoth = require('mammoth');
const OpenAI = require('openai');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(express.json());

const upload = multer({
  dest: '/tmp/uploads/',
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedMimes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only PDF and DOC/DOCX are allowed.'));
    }
  }
});

const openai = new OpenAI({
  apiKey: process.env.AI_INTEGRATIONS_OPENAI_API_KEY,
  baseURL: process.env.AI_INTEGRATIONS_OPENAI_BASE_URL,
});

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

app.get('/api/dashboard/stats', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        (SELECT COUNT(*) FROM candidates WHERE organization_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890') as total_candidates,
        (SELECT COUNT(*) FROM jobs WHERE organization_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890' AND status = 'open') as active_jobs,
        (SELECT COUNT(*) FROM interviews i 
         JOIN applications a ON i.application_id = a.id 
         WHERE a.organization_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890' 
         AND DATE(i.scheduled_at) = CURRENT_DATE) as interviews_today,
        (SELECT COUNT(*) FROM offers o 
         JOIN applications a ON o.application_id = a.id 
         WHERE a.organization_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890' 
         AND o.status IN ('sent', 'pending_approval')) as offers_sent
    `);
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching stats:', err);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

app.get('/api/dashboard/candidates', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        c.id,
        c.first_name || ' ' || c.last_name as name,
        c.current_title as title,
        c.current_company as company,
        ci.name as location,
        COALESCE(a.overall_score, 0) as score,
        c.total_experience_years as experience,
        a.status,
        a.applied_at
      FROM candidates c
      LEFT JOIN cities ci ON c.city_id = ci.id
      LEFT JOIN applications a ON a.candidate_id = c.id
      WHERE c.organization_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
      ORDER BY a.overall_score DESC NULLS LAST, c.created_at DESC
      LIMIT 10
    `);
    
    const candidates = result.rows.map(row => ({
      id: row.id,
      name: row.name,
      title: row.title,
      company: row.company,
      location: row.location || 'India',
      score: row.score || 75,
      experience: row.experience ? `${row.experience} years` : 'N/A',
      status: row.status || 'active',
      appliedDate: row.applied_at ? formatTimeAgo(row.applied_at) : 'Recently',
      avatar: getAvatarEmoji(row.title)
    }));
    
    res.json(candidates);
  } catch (err) {
    console.error('Error fetching candidates:', err);
    res.status(500).json({ error: 'Failed to fetch candidates' });
  }
});

app.get('/api/dashboard/jobs', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        j.id,
        j.title,
        d.name as department,
        l.name as location,
        j.job_type as type,
        j.status,
        j.total_applications as applicants,
        j.new_applications as new_applicants,
        j.published_at,
        j.salary_min,
        j.salary_max,
        cur.symbol as currency_symbol
      FROM jobs j
      LEFT JOIN organization_departments d ON j.department_id = d.id
      LEFT JOIN organization_locations l ON j.location_id = l.id
      LEFT JOIN currencies cur ON j.salary_currency_id = cur.id
      WHERE j.organization_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
      AND j.deleted_at IS NULL
      ORDER BY j.published_at DESC
    `);
    
    const jobs = result.rows.map(row => ({
      id: row.id,
      title: row.title,
      department: row.department || 'General',
      location: row.location || 'India',
      type: formatJobType(row.type),
      status: row.status === 'open' ? 'Active' : row.status,
      applicants: row.applicants || 0,
      newApplicants: row.new_applicants || 0,
      posted: row.published_at ? formatTimeAgo(row.published_at) : 'Recently',
      salary: formatSalary(row.salary_min, row.salary_max, row.currency_symbol)
    }));
    
    res.json(jobs);
  } catch (err) {
    console.error('Error fetching jobs:', err);
    res.status(500).json({ error: 'Failed to fetch jobs' });
  }
});

app.get('/api/dashboard/interviews', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        i.id,
        c.first_name || ' ' || c.last_name as candidate,
        j.title as position,
        it.name as interview_type,
        i.scheduled_at,
        i.status,
        u.first_name || ' ' || u.last_name as interviewer
      FROM interviews i
      JOIN applications a ON i.application_id = a.id
      JOIN candidates c ON a.candidate_id = c.id
      JOIN jobs j ON a.job_id = j.id
      LEFT JOIN interview_types it ON i.interview_type_id = it.id
      LEFT JOIN interview_participants ip ON i.id = ip.interview_id
      LEFT JOIN users u ON ip.user_id = u.id
      WHERE a.organization_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
      AND i.scheduled_at >= NOW() - INTERVAL '1 day'
      ORDER BY i.scheduled_at ASC
      LIMIT 10
    `);
    
    const interviews = result.rows.map(row => ({
      id: row.id,
      candidate: row.candidate,
      position: row.position,
      type: row.interview_type || 'Interview',
      time: formatTime(row.scheduled_at),
      date: formatDate(row.scheduled_at),
      interviewer: row.interviewer || 'TBD',
      status: capitalizeFirst(row.status),
      avatar: getAvatarEmoji(row.position)
    }));
    
    res.json(interviews);
  } catch (err) {
    console.error('Error fetching interviews:', err);
    res.status(500).json({ error: 'Failed to fetch interviews' });
  }
});

app.get('/api/dashboard/pipeline', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        ps.stage_type,
        ps.name,
        COUNT(a.id) as count
      FROM job_pipeline_stages ps
      LEFT JOIN applications a ON a.current_stage_id = ps.id
      JOIN jobs j ON ps.job_id = j.id
      WHERE j.organization_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
      GROUP BY ps.stage_type, ps.name
      ORDER BY 
        CASE ps.stage_type 
          WHEN 'applied' THEN 1
          WHEN 'screening' THEN 2
          WHEN 'interview' THEN 3
          WHEN 'offer' THEN 4
          WHEN 'hired' THEN 5
        END
    `);
    
    const stageColors = {
      applied: '#00D4FF',
      screening: '#7B61FF',
      interview: '#FFB800',
      offer: '#00E5A0',
      hired: '#FF6B35'
    };
    
    const stageNames = {
      applied: 'New',
      screening: 'Screening',
      interview: 'Interview',
      offer: 'Offer',
      hired: 'Hired'
    };
    
    const pipeline = ['applied', 'screening', 'interview', 'offer', 'hired'].map(stageType => {
      const stage = result.rows.find(r => r.stage_type === stageType);
      return {
        id: stageType,
        name: stageNames[stageType],
        count: stage ? parseInt(stage.count) : 0,
        color: stageColors[stageType]
      };
    });
    
    res.json(pipeline);
  } catch (err) {
    console.error('Error fetching pipeline:', err);
    res.status(500).json({ error: 'Failed to fetch pipeline' });
  }
});

app.get('/api/dashboard/activity', async (req, res) => {
  try {
    const result = await pool.query(`
      (SELECT 
        'application' as type,
        'New application received' as action,
        c.first_name || ' ' || c.last_name || ' applied for ' || j.title as detail,
        a.applied_at as timestamp
      FROM applications a
      JOIN candidates c ON a.candidate_id = c.id
      JOIN jobs j ON a.job_id = j.id
      WHERE a.organization_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
      ORDER BY a.applied_at DESC
      LIMIT 3)
      UNION ALL
      (SELECT 
        'interview' as type,
        'Interview scheduled' as action,
        c.first_name || ' ' || c.last_name || ' - ' || COALESCE(it.name, 'Interview') as detail,
        i.created_at as timestamp
      FROM interviews i
      JOIN applications a ON i.application_id = a.id
      JOIN candidates c ON a.candidate_id = c.id
      LEFT JOIN interview_types it ON i.interview_type_id = it.id
      WHERE a.organization_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
      ORDER BY i.created_at DESC
      LIMIT 2)
      ORDER BY timestamp DESC
      LIMIT 5
    `);
    
    const iconMap = {
      application: '📥',
      interview: '📅',
      offer: '🎉',
      job: '📢'
    };
    
    const colorMap = {
      application: '#00D4FF',
      interview: '#00E5A0',
      offer: '#7B61FF',
      job: '#FFB800'
    };
    
    const activities = result.rows.map(row => ({
      action: row.action,
      detail: row.detail,
      time: formatTimeAgo(row.timestamp),
      icon: iconMap[row.type] || '📌',
      color: colorMap[row.type] || '#00D4FF'
    }));
    
    res.json(activities);
  } catch (err) {
    console.error('Error fetching activity:', err);
    res.status(500).json({ error: 'Failed to fetch activity' });
  }
});

function formatTimeAgo(date) {
  const now = new Date();
  const past = new Date(date);
  const diffMs = now - past;
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);
  
  if (diffMins < 1) return 'Just now';
  if (diffMins < 60) return `${diffMins} min ago`;
  if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
  if (diffDays === 1) return 'Yesterday';
  return `${diffDays} days ago`;
}

function formatTime(date) {
  const d = new Date(date);
  return d.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', hour12: true });
}

function formatDate(date) {
  const d = new Date(date);
  const today = new Date();
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);
  
  if (d.toDateString() === today.toDateString()) return 'Today';
  if (d.toDateString() === tomorrow.toDateString()) return 'Tomorrow';
  return d.toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });
}

function formatJobType(type) {
  const types = {
    full_time: 'Full-time',
    part_time: 'Part-time',
    contract: 'Contract',
    internship: 'Internship'
  };
  return types[type] || type || 'Full-time';
}

function formatSalary(min, max, symbol) {
  if (!min && !max) return 'Competitive';
  symbol = symbol || '₹';
  const formatNum = (n) => {
    if (n >= 10000000) return `${(n / 10000000).toFixed(1)}Cr`;
    if (n >= 100000) return `${(n / 100000).toFixed(1)}L`;
    if (n >= 1000) return `${(n / 1000).toFixed(0)}K`;
    return n;
  };
  if (min && max) return `${symbol}${formatNum(min)} - ${symbol}${formatNum(max)}`;
  if (min) return `${symbol}${formatNum(min)}+`;
  return `Up to ${symbol}${formatNum(max)}`;
}

function getAvatarEmoji(title) {
  const lower = (title || '').toLowerCase();
  if (lower.includes('engineer') || lower.includes('developer')) return '👨‍💻';
  if (lower.includes('product') || lower.includes('manager')) return '👩‍💼';
  if (lower.includes('design')) return '👩‍🎨';
  if (lower.includes('data') || lower.includes('scientist')) return '👨‍🔬';
  if (lower.includes('devops') || lower.includes('ops')) return '👩‍🔧';
  if (lower.includes('sales') || lower.includes('business')) return '👔';
  return '👤';
}

function capitalizeFirst(str) {
  if (!str) return '';
  return str.charAt(0).toUpperCase() + str.slice(1);
}

app.post('/api/resume/parse', upload.single('resume'), async (req, res) => {
  let filePath = null;
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }
    
    filePath = req.file.path;
    const originalName = req.file.originalname || '';
    const ext = originalName.toLowerCase().split('.').pop();
    
    let text = '';
    
    if (ext === 'doc') {
      const { execSync } = require('child_process');
      const uploadsDir = path.dirname(filePath);
      const originalBaseName = path.basename(originalName, '.doc');
      
      try {
        execSync(`soffice --headless --convert-to docx --outdir "${uploadsDir}" "${filePath}"`, {
          timeout: 60000,
          stdio: 'pipe'
        });
        
        const possiblePaths = [
          path.join(uploadsDir, originalBaseName + '.docx'),
          path.join(uploadsDir, path.basename(filePath) + '.docx'),
          filePath.replace(/\.doc$/i, '.docx')
        ];
        
        let docxPath = null;
        for (const p of possiblePaths) {
          if (fs.existsSync(p)) {
            docxPath = p;
            break;
          }
        }
        
        if (docxPath) {
          if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
          }
          filePath = docxPath;
        } else {
          console.error('Converted file not found. Checked:', possiblePaths);
          return res.status(400).json({ 
            error: 'Could not convert .doc file. Please try uploading a .docx or .pdf file instead.' 
          });
        }
      } catch (convertErr) {
        console.error('LibreOffice conversion error:', convertErr);
        return res.status(400).json({ 
          error: 'Could not convert .doc file. Please try uploading a .docx or .pdf file instead.' 
        });
      }
    }
    
    if (req.file.mimetype === 'application/pdf' || ext === 'pdf') {
      const PDFParser = require('pdf2json');
      text = await new Promise((resolve, reject) => {
        const pdfParser = new PDFParser();
        pdfParser.on('pdfParser_dataError', (errData) => reject(errData.parserError));
        pdfParser.on('pdfParser_dataReady', (pdfData) => {
          let extractedText = '';
          if (pdfData && pdfData.Pages) {
            for (const page of pdfData.Pages) {
              if (page.Texts) {
                for (const textItem of page.Texts) {
                  if (textItem.R) {
                    for (const run of textItem.R) {
                      if (run.T) {
                        try {
                          extractedText += decodeURIComponent(run.T) + ' ';
                        } catch (e) {
                          extractedText += run.T.replace(/%20/g, ' ') + ' ';
                        }
                      }
                    }
                  }
                }
              }
              extractedText += '\n';
            }
          }
          console.log('Extracted PDF text length:', extractedText.length);
          console.log('First 200 chars:', extractedText.substring(0, 200));
          resolve(extractedText);
        });
        pdfParser.loadPDF(filePath);
      });
    } else {
      const result = await mammoth.extractRawText({ path: filePath });
      text = result.value;
    }
    
    if (!text || text.trim().length < 50) {
      return res.status(400).json({ error: 'Could not extract text from resume. Please try a different file.' });
    }
    
    const prompt = `Extract ALL information from the following resume text. Return a JSON object with these fields:

PERSONAL INFO:
- firstName (string): First name
- lastName (string): Last name
- email (string): Email address
- phone (string): Phone number
- currentTitle (string): Current/most recent job title
- currentCompany (string): Current/most recent company
- location (string): City/location (prefer Indian cities)
- linkedinUrl (string): LinkedIn URL if present
- portfolioUrl (string): Portfolio/website URL if present
- summary (string): Professional summary/objective if present

SKILLS (array of objects):
- skills: [{ name: string, proficiencyLevel: "beginner"|"intermediate"|"advanced"|"expert", yearsOfExperience: number|null }]
  Extract ALL technical skills, programming languages, frameworks, tools, soft skills mentioned

EDUCATION (array of objects):
- education: [{ 
    institutionName: string,
    degreeName: string (e.g., "Bachelor of Technology", "Master of Science"),
    fieldOfStudy: string (e.g., "Computer Science", "Electronics"),
    startDate: string (YYYY-MM format or year),
    endDate: string (YYYY-MM format or year, "Present" if current),
    gpa: number|null,
    percentage: number|null,
    honors: string|null,
    description: string|null
  }]

EXPERIENCE (array of objects):
- experience: [{
    companyName: string,
    title: string,
    location: string|null,
    startDate: string (YYYY-MM format or year),
    endDate: string (YYYY-MM format or year, "Present" if current),
    isCurrent: boolean,
    description: string (full job description),
    responsibilities: string[] (list of responsibilities),
    achievements: string[] (list of achievements/accomplishments)
  }]

PROJECTS (array of objects):
- projects: [{
    name: string,
    description: string,
    role: string|null,
    technologies: string[] (technologies used),
    url: string|null,
    startDate: string|null,
    endDate: string|null
  }]

CERTIFICATIONS (array of objects):
- certifications: [{ name: string, issuer: string, date: string|null, url: string|null }]

Extract EVERYTHING mentioned in the resume. Do not skip any detail.

Resume text:
${text.substring(0, 15000)}

Return ONLY valid JSON, no explanation.`;

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.1,
      max_tokens: 4000,
    });
    
    const content = response.choices[0]?.message?.content || '{}';
    let parsed;
    try {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      parsed = JSON.parse(jsonMatch ? jsonMatch[0] : content);
    } catch (e) {
      console.error('JSON parse error:', e);
      parsed = {};
    }
    
    console.log('Parsed resume data:', JSON.stringify(parsed, null, 2));
    
    const personalInfo = parsed.PERSONAL_INFO || parsed.personalInfo || parsed;
    const skillsData = parsed.SKILLS || parsed.skills || [];
    const educationData = parsed.EDUCATION || parsed.education || [];
    const experienceData = parsed.EXPERIENCE || parsed.experience || [];
    const projectsData = parsed.PROJECTS || parsed.projects || [];
    const certificationsData = parsed.CERTIFICATIONS || parsed.certifications || [];
    
    const resumesDir = path.join(__dirname, '..', 'uploads', 'resumes');
    if (!fs.existsSync(resumesDir)) {
      fs.mkdirSync(resumesDir, { recursive: true });
    }
    
    const timestamp = Date.now();
    const safeOriginalName = originalName.replace(/[^a-zA-Z0-9._-]/g, '_');
    const savedFileName = `${timestamp}_${safeOriginalName}`;
    const savedFilePath = path.join(resumesDir, savedFileName);
    
    fs.copyFileSync(filePath, savedFilePath);
    const resumeUrl = `/uploads/resumes/${savedFileName}`;
    
    res.json({
      success: true,
      data: {
        firstName: personalInfo.firstName || parsed.firstName || '',
        lastName: personalInfo.lastName || parsed.lastName || '',
        email: personalInfo.email || parsed.email || '',
        phone: personalInfo.phone || parsed.phone || '',
        currentTitle: personalInfo.currentTitle || parsed.currentTitle || '',
        currentCompany: personalInfo.currentCompany || parsed.currentCompany || '',
        location: personalInfo.location || parsed.location || '',
        linkedinUrl: personalInfo.linkedinUrl || parsed.linkedinUrl || '',
        portfolioUrl: personalInfo.portfolioUrl || parsed.portfolioUrl || '',
        summary: personalInfo.summary || parsed.summary || '',
        skills: skillsData,
        education: educationData,
        experience: experienceData,
        projects: projectsData,
        certifications: certificationsData,
        resumeUrl: resumeUrl,
      }
    });
  } catch (err) {
    console.error('Error parsing resume:', err);
    res.status(500).json({ error: 'Failed to parse resume. Please try again.' });
  } finally {
    if (filePath && fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
  }
});

app.post('/api/candidates', async (req, res) => {
  const client = await pool.connect();
  try {
    const { 
      firstName, lastName, email, phone, currentTitle, currentCompany, location,
      linkedinUrl, portfolioUrl, summary, skills, education, experience, projects, certifications,
      resumeUrl
    } = req.body;
    
    if (!firstName || !lastName || !email) {
      return res.status(400).json({ error: 'First name, last name, and email are required' });
    }
    
    await client.query('BEGIN');
    
    const orgId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
    
    const cityResult = await client.query(
      `SELECT id FROM cities WHERE LOWER(name) LIKE LOWER($1) LIMIT 1`,
      [`%${location || 'Bangalore'}%`]
    );
    const cityId = cityResult.rows[0]?.id || null;
    
    const candidateResult = await client.query(
      `INSERT INTO candidates (
        organization_id, first_name, last_name, email, phone,
        current_title, current_company, city_id, linkedin_url, portfolio_url,
        profile_summary, resume_url, status, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, 'active', NOW(), NOW())
      RETURNING id, first_name, last_name, email`,
      [orgId, firstName, lastName, email, phone || null, currentTitle || null, 
       currentCompany || null, cityId, linkedinUrl || null, portfolioUrl || null, summary || null, resumeUrl || null]
    );
    
    const candidateId = candidateResult.rows[0].id;
    
    if (skills && skills.length > 0) {
      for (const rawSkill of skills) {
        const skill = typeof rawSkill === 'string' 
          ? { name: rawSkill, proficiencyLevel: 'intermediate', yearsOfExperience: null }
          : rawSkill;
        
        if (!skill || !skill.name || typeof skill.name !== 'string' || skill.name.trim() === '') {
          continue;
        }
        
        const skillName = skill.name.trim();
        
        try {
          let skillId;
          const existingSkill = await client.query(
            `SELECT id FROM skills WHERE LOWER(canonical_name) = LOWER($1) LIMIT 1`,
            [skillName]
          );
          
          if (existingSkill.rows.length > 0) {
            skillId = existingSkill.rows[0].id;
          } else {
            const newSkill = await client.query(
              `INSERT INTO skills (canonical_name, display_name, is_active, created_at, updated_at)
               VALUES ($1, $2, true, NOW(), NOW()) RETURNING id`,
              [skillName.toLowerCase(), skillName]
            );
            skillId = newSkill.rows[0].id;
          }
          
          await client.query(
            `INSERT INTO candidate_skills (id, candidate_id, skill_id, proficiency_level, years_of_experience, source, is_visible, created_at, updated_at)
             VALUES (gen_random_uuid(), $1, $2, $3, $4, 'resume', true, NOW(), NOW())
             ON CONFLICT DO NOTHING`,
            [candidateId, skillId, skill.proficiencyLevel || 'intermediate', skill.yearsOfExperience || null]
          );
        } catch (skillErr) {
          console.error(`Error saving skill "${skillName}":`, skillErr.message);
        }
      }
    }
    
    if (education && education.length > 0) {
      for (let i = 0; i < education.length; i++) {
        const edu = education[i];
        if (!edu || typeof edu !== 'object' || !edu.institutionName) {
          continue;
        }
        
        try {
          const startDate = parseDate(edu.startDate);
          const endDate = edu.endDate === 'Present' ? null : parseDate(edu.endDate);
          
          await client.query(
            `INSERT INTO candidate_education (
              id, candidate_id, institution_name, degree_name, field_of_study_text,
              start_date, end_date, is_current, gpa, percentage, honors, description,
              sort_order, is_visible, created_at, updated_at
            ) VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, true, NOW(), NOW())`,
            [candidateId, edu.institutionName, edu.degreeName || null, edu.fieldOfStudy || null,
             startDate, endDate, endDate === null, edu.gpa || null, edu.percentage || null,
             edu.honors || null, edu.description || null, i]
          );
        } catch (eduErr) {
          console.error(`Error saving education "${edu.institutionName}":`, eduErr.message);
        }
      }
    }
    
    if (experience && experience.length > 0) {
      for (let i = 0; i < experience.length; i++) {
        const exp = experience[i];
        if (!exp || typeof exp !== 'object' || !exp.companyName || !exp.title) {
          continue;
        }
        
        try {
          const startDate = parseDate(exp.startDate);
          const endDate = exp.endDate === 'Present' ? null : parseDate(exp.endDate);
          
          await client.query(
            `INSERT INTO candidate_experience (
              id, candidate_id, company_name, title, location_text,
              start_date, end_date, is_current, description, responsibilities, achievements,
              sort_order, is_visible, created_at, updated_at
            ) VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, true, NOW(), NOW())`,
            [candidateId, exp.companyName, exp.title, exp.location || null,
             startDate, endDate, exp.isCurrent || endDate === null,
             exp.description || null,
             Array.isArray(exp.responsibilities) ? exp.responsibilities.join('\n') : null,
             Array.isArray(exp.achievements) ? exp.achievements.join('\n') : null, i]
          );
        } catch (expErr) {
          console.error(`Error saving experience "${exp.companyName}":`, expErr.message);
        }
      }
    }
    
    if (projects && projects.length > 0) {
      for (let i = 0; i < projects.length; i++) {
        const proj = projects[i];
        if (!proj || typeof proj !== 'object' || !proj.name) {
          continue;
        }
        
        try {
          await client.query(
            `INSERT INTO candidate_projects (
              id, candidate_id, name, description, role, url, technologies,
              start_date, end_date, sort_order, is_visible, created_at, updated_at
            ) VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9, true, NOW(), NOW())`,
            [candidateId, proj.name, proj.description || null, proj.role || null,
             proj.url || null, Array.isArray(proj.technologies) ? proj.technologies : [], 
             parseDate(proj.startDate), parseDate(proj.endDate), i]
          );
        } catch (projErr) {
          console.error(`Error saving project "${proj.name}":`, projErr.message);
        }
      }
    }
    
    await client.query('COMMIT');
    
    console.log(`Created candidate ${candidateId} with ${skills?.length || 0} skills, ${education?.length || 0} education, ${experience?.length || 0} experience, ${projects?.length || 0} projects`);
    
    res.status(201).json({
      success: true,
      candidate: candidateResult.rows[0],
      savedData: {
        skills: skills?.length || 0,
        education: education?.length || 0,
        experience: experience?.length || 0,
        projects: projects?.length || 0
      }
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error creating candidate:', err);
    if (err.code === '23505') {
      return res.status(400).json({ error: 'A candidate with this email already exists' });
    }
    res.status(500).json({ error: 'Failed to create candidate' });
  } finally {
    client.release();
  }
});

function parseDate(dateStr) {
  if (!dateStr || dateStr === 'Present') return null;
  if (/^\d{4}$/.test(dateStr)) {
    return `${dateStr}-01-01`;
  }
  if (/^\d{4}-\d{2}$/.test(dateStr)) {
    return `${dateStr}-01`;
  }
  const parsed = new Date(dateStr);
  if (!isNaN(parsed.getTime())) {
    return parsed.toISOString().split('T')[0];
  }
  return null;
}

app.get('/api/candidates/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const candidateResult = await pool.query(`
      SELECT 
        c.*,
        ci.name as city_name,
        co.name as country_name
      FROM candidates c
      LEFT JOIN cities ci ON c.city_id = ci.id
      LEFT JOIN countries co ON c.country_id = co.id
      WHERE c.id = $1
    `, [id]);
    
    if (candidateResult.rows.length === 0) {
      return res.status(404).json({ error: 'Candidate not found' });
    }
    
    const candidate = candidateResult.rows[0];
    
    const skillsResult = await pool.query(`
      SELECT cs.*, s.display_name as skill_name, s.canonical_name
      FROM candidate_skills cs
      JOIN skills s ON cs.skill_id = s.id
      WHERE cs.candidate_id = $1
      ORDER BY cs.sort_order, s.display_name
    `, [id]);
    
    const educationResult = await pool.query(`
      SELECT *
      FROM candidate_education
      WHERE candidate_id = $1
      ORDER BY sort_order, end_date DESC NULLS FIRST
    `, [id]);
    
    const experienceResult = await pool.query(`
      SELECT *
      FROM candidate_experience
      WHERE candidate_id = $1
      ORDER BY sort_order, end_date DESC NULLS FIRST
    `, [id]);
    
    const projectsResult = await pool.query(`
      SELECT *
      FROM candidate_projects
      WHERE candidate_id = $1
      ORDER BY sort_order
    `, [id]);
    
    res.json({
      ...candidate,
      skills: skillsResult.rows,
      education: educationResult.rows,
      experience: experienceResult.rows,
      projects: projectsResult.rows
    });
  } catch (err) {
    console.error('Error fetching candidate:', err);
    res.status(500).json({ error: 'Failed to fetch candidate' });
  }
});

app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

app.put('/api/candidates/:id', async (req, res) => {
  const client = await pool.connect();
  try {
    const { id } = req.params;
    const { 
      firstName, lastName, email, phone, currentTitle, currentCompany, location,
      linkedinUrl, portfolioUrl, summary, skills, education, experience, projects
    } = req.body;
    
    await client.query('BEGIN');
    
    let cityId = null;
    if (location) {
      const cityResult = await client.query(
        `SELECT id FROM cities WHERE LOWER(name) LIKE LOWER($1) LIMIT 1`,
        [`%${location}%`]
      );
      cityId = cityResult.rows[0]?.id || null;
    }
    
    await client.query(`
      UPDATE candidates SET
        first_name = $1, last_name = $2, email = $3, phone = $4,
        current_title = $5, current_company = $6, city_id = $7,
        linkedin_url = $8, portfolio_url = $9, profile_summary = $10,
        updated_at = NOW()
      WHERE id = $11
    `, [firstName, lastName, email, phone || null, currentTitle || null, 
        currentCompany || null, cityId, linkedinUrl || null, portfolioUrl || null, 
        summary || null, id]);
    
    await client.query('DELETE FROM candidate_skills WHERE candidate_id = $1', [id]);
    if (skills && Array.isArray(skills)) {
      for (let i = 0; i < skills.length; i++) {
        const skill = skills[i];
        const skillName = typeof skill === 'string' ? skill : skill.skill_name;
        if (!skillName) continue;
        
        let skillResult = await client.query(
          `SELECT id FROM skills WHERE LOWER(display_name) = LOWER($1) OR LOWER(canonical_name) = LOWER($1) LIMIT 1`,
          [skillName]
        );
        
        let skillId;
        if (skillResult.rows.length === 0) {
          const insertSkill = await client.query(
            `INSERT INTO skills (display_name, canonical_name, created_at) VALUES ($1, $2, NOW()) RETURNING id`,
            [skillName, skillName.toLowerCase().replace(/\s+/g, '-')]
          );
          skillId = insertSkill.rows[0].id;
        } else {
          skillId = skillResult.rows[0].id;
        }
        
        await client.query(`
          INSERT INTO candidate_skills (candidate_id, skill_id, proficiency_level, years_of_experience, sort_order)
          VALUES ($1, $2, $3, $4, $5)
        `, [id, skillId, skill.proficiency_level || 'intermediate', skill.years_of_experience || null, i]);
      }
    }
    
    await client.query('DELETE FROM candidate_experience WHERE candidate_id = $1', [id]);
    if (experience && Array.isArray(experience)) {
      for (let i = 0; i < experience.length; i++) {
        const exp = experience[i];
        if (!exp.title && !exp.company_name) continue;
        
        await client.query(`
          INSERT INTO candidate_experience (candidate_id, title, company_name, location_text, start_date, end_date, is_current, description, sort_order)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        `, [id, exp.title || '', exp.company_name || '', exp.location_text || null,
            exp.start_date ? parseDate(exp.start_date) : null, 
            exp.end_date ? parseDate(exp.end_date) : null,
            exp.is_current || false, exp.description || null, i]);
      }
    }
    
    await client.query('DELETE FROM candidate_education WHERE candidate_id = $1', [id]);
    if (education && Array.isArray(education)) {
      for (let i = 0; i < education.length; i++) {
        const edu = education[i];
        if (!edu.institution_name && !edu.degree_name) continue;
        
        await client.query(`
          INSERT INTO candidate_education (candidate_id, institution_name, degree_name, field_of_study_text, start_date, end_date, is_current, sort_order)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        `, [id, edu.institution_name || '', edu.degree_name || '', edu.field_of_study_text || null,
            edu.start_date ? parseDate(edu.start_date) : null,
            edu.end_date ? parseDate(edu.end_date) : null,
            edu.is_current || false, i]);
      }
    }
    
    await client.query('DELETE FROM candidate_projects WHERE candidate_id = $1', [id]);
    if (projects && Array.isArray(projects)) {
      for (let i = 0; i < projects.length; i++) {
        const proj = projects[i];
        if (!proj.name) continue;
        
        await client.query(`
          INSERT INTO candidate_projects (candidate_id, name, role, description, technologies, sort_order)
          VALUES ($1, $2, $3, $4, $5, $6)
        `, [id, proj.name, proj.role || null, proj.description || null,
            proj.technologies || [], i]);
      }
    }
    
    await client.query('COMMIT');
    
    res.json({ success: true, message: 'Candidate updated successfully' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error updating candidate:', err);
    res.status(500).json({ error: 'Failed to update candidate' });
  } finally {
    client.release();
  }
});

const PORT = 3001;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`API server running on port ${PORT}`);
});
