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
    let text = '';
    
    if (req.file.mimetype === 'application/pdf') {
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
                        extractedText += decodeURIComponent(run.T) + ' ';
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
    
    const prompt = `Extract candidate information from the following resume text. Return a JSON object with these fields:
- firstName (string): The candidate's first name
- lastName (string): The candidate's last name  
- email (string): Email address
- phone (string): Phone number
- currentTitle (string): Current or most recent job title
- currentCompany (string): Current or most recent company name
- location (string): City or location mentioned (prefer Indian cities if mentioned)

If a field cannot be found, use an empty string.

Resume text:
${text.substring(0, 8000)}

Return ONLY valid JSON, no explanation.`;

    const response = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.1,
      max_tokens: 500,
    });
    
    const content = response.choices[0]?.message?.content || '{}';
    let parsed;
    try {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      parsed = JSON.parse(jsonMatch ? jsonMatch[0] : content);
    } catch (e) {
      parsed = {};
    }
    
    res.json({
      success: true,
      data: {
        firstName: parsed.firstName || '',
        lastName: parsed.lastName || '',
        email: parsed.email || '',
        phone: parsed.phone || '',
        currentTitle: parsed.currentTitle || '',
        currentCompany: parsed.currentCompany || '',
        location: parsed.location || '',
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

const PORT = 3001;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`API server running on port ${PORT}`);
});
