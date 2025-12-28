import React, { useState, useEffect, useRef } from 'react';

// ============================================================================
// TALENTFORGE - STUNNING LANDING PAGE
// A marketing website that showcases the ATS platform
// ============================================================================

export default function TalentForgeLanding({ onGetStarted }) {
  const [scrollY, setScrollY] = useState(0);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [activeFeature, setActiveFeature] = useState(0);
  const [animatedStats, setAnimatedStats] = useState({ candidates: 0, hires: 0, time: 0, satisfaction: 0 });

  useEffect(() => {
    const handleScroll = () => setScrollY(window.scrollY);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Animate stats on mount
  useEffect(() => {
    const duration = 2000;
    const steps = 60;
    const interval = duration / steps;
    
    let step = 0;
    const timer = setInterval(() => {
      step++;
      const progress = step / steps;
      const easeOut = 1 - Math.pow(1 - progress, 3);
      
      setAnimatedStats({
        candidates: Math.floor(250000 * easeOut),
        hires: Math.floor(45000 * easeOut),
        time: Math.floor(65 * easeOut),
        satisfaction: Math.floor(98 * easeOut),
      });
      
      if (step >= steps) clearInterval(timer);
    }, interval);

    return () => clearInterval(timer);
  }, []);

  const features = [
    {
      title: 'AI-Powered Matching',
      description: 'Our intelligent algorithms analyze skills, experience, and cultural fit to surface your best candidates instantly.',
      icon: '🎯',
      color: '#00D4FF',
      image: 'matching',
    },
    {
      title: 'Smart Pipelines',
      description: 'Customizable hiring workflows that adapt to your process. Automate tasks and keep candidates moving.',
      icon: '⚡',
      color: '#7B61FF',
      image: 'pipeline',
    },
    {
      title: 'Collaborative Hiring',
      description: 'Bring your entire team together with shared scorecards, feedback, and real-time communication.',
      icon: '👥',
      color: '#00E5A0',
      image: 'collaboration',
    },
    {
      title: 'Analytics & Insights',
      description: 'Data-driven decisions with comprehensive dashboards tracking every aspect of your hiring funnel.',
      icon: '📊',
      color: '#FFB800',
      image: 'analytics',
    },
  ];

  const testimonials = [
    {
      quote: "TalentForge reduced our time-to-hire by 60%. The AI matching is incredibly accurate.",
      author: "Sarah Chen",
      role: "VP of People, TechCorp",
      avatar: "👩‍💼",
      company: "TechCorp"
    },
    {
      quote: "The best ATS we've ever used. Clean interface, powerful features, and amazing support.",
      author: "Marcus Johnson",
      role: "Head of Talent, ScaleUp",
      avatar: "👨‍💻",
      company: "ScaleUp"
    },
    {
      quote: "We hired 200+ engineers last year using TalentForge. It's been a game-changer.",
      author: "Emily Rodriguez",
      role: "CEO, InnovateCo",
      avatar: "👩‍🔬",
      company: "InnovateCo"
    },
  ];

  const pricingPlans = [
    {
      name: 'Starter',
      price: 49,
      description: 'Perfect for small teams just getting started',
      features: ['Up to 3 active jobs', '500 candidates/month', 'Basic AI matching', 'Email support', 'Standard integrations'],
      cta: 'Start Free Trial',
      popular: false,
    },
    {
      name: 'Professional',
      price: 149,
      description: 'For growing teams with serious hiring needs',
      features: ['Up to 25 active jobs', '5,000 candidates/month', 'Advanced AI matching', 'Priority support', 'All integrations', 'Custom pipelines', 'Analytics dashboard'],
      cta: 'Start Free Trial',
      popular: true,
    },
    {
      name: 'Enterprise',
      price: 'Custom',
      description: 'For large organizations with custom requirements',
      features: ['Unlimited jobs', 'Unlimited candidates', 'Dedicated AI models', '24/7 phone support', 'Custom integrations', 'SSO & SAML', 'Dedicated CSM', 'SLA guarantee'],
      cta: 'Contact Sales',
      popular: false,
    },
  ];

  return (
    <div style={styles.container}>
      <style>{globalStyles}</style>

      {/* Navigation */}
      <nav style={{
        ...styles.nav,
        background: scrollY > 50 ? 'rgba(10, 22, 40, 0.95)' : 'transparent',
        backdropFilter: scrollY > 50 ? 'blur(20px)' : 'none',
        borderBottom: scrollY > 50 ? '1px solid rgba(255, 255, 255, 0.06)' : 'none',
      }}>
        <div style={styles.navContent}>
          <div style={styles.logo}>
            <div style={styles.logoIcon}>⚡</div>
            <span style={styles.logoText}>TalentForge</span>
          </div>
          
          <div style={styles.navLinks}>
            <a href="#features" style={styles.navLink}>Features</a>
            <a href="#how-it-works" style={styles.navLink}>How It Works</a>
            <a href="#pricing" style={styles.navLink}>Pricing</a>
            <a href="#testimonials" style={styles.navLink}>Testimonials</a>
          </div>

          <div style={styles.navActions}>
            <button style={styles.loginBtn} onClick={onGetStarted}>Log In</button>
            <button style={styles.ctaBtn} onClick={onGetStarted}>Start Free Trial</button>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section style={styles.hero}>
        <div style={styles.heroBackground}>
          <div style={styles.heroGradient1} />
          <div style={styles.heroGradient2} />
          <div style={styles.heroGrid} />
        </div>
        
        <div style={styles.heroContent}>
          <div style={styles.heroBadge}>
            <span style={styles.heroBadgeIcon}>✨</span>
            <span>Powered by AI • Loved by 10,000+ teams</span>
          </div>
          
          <h1 style={styles.heroTitle}>
            Hire <span style={styles.heroTitleGradient}>exceptional</span> talent,<br />
            <span style={styles.heroTitleLight}>effortlessly.</span>
          </h1>
          
          <p style={styles.heroSubtitle}>
            The modern ATS that combines AI-powered candidate matching with 
            intuitive workflows. Find, engage, and hire the best talent 60% faster.
          </p>
          
          <div style={styles.heroActions}>
            <button style={styles.heroPrimaryBtn} onClick={onGetStarted}>
              Start Free Trial
              <span style={styles.btnArrow}>→</span>
            </button>
            <button style={styles.heroSecondaryBtn}>
              <span style={styles.playIcon}>▶</span>
              Watch Demo
            </button>
          </div>

          <div style={styles.heroTrust}>
            <span style={styles.heroTrustLabel}>Trusted by teams at</span>
            <div style={styles.heroLogos}>
              {['Google', 'Meta', 'Stripe', 'Airbnb', 'Netflix'].map((company) => (
                <span key={company} style={styles.heroLogo}>{company}</span>
              ))}
            </div>
          </div>
        </div>

        <div style={styles.heroImage}>
          <div style={styles.dashboardPreview}>
            <div style={styles.dashboardHeader}>
              <div style={styles.dashboardDots}>
                <span style={{...styles.dot, background: '#FF5F57'}} />
                <span style={{...styles.dot, background: '#FEBC2E'}} />
                <span style={{...styles.dot, background: '#28C840'}} />
              </div>
            </div>
            <div style={styles.dashboardContent}>
              <div style={styles.dashboardSidebar}>
                {['Dashboard', 'Jobs', 'Candidates', 'Interviews'].map((item, i) => (
                  <div key={item} style={{
                    ...styles.dashboardMenuItem,
                    background: i === 0 ? 'rgba(0, 212, 255, 0.1)' : 'transparent',
                    color: i === 0 ? '#00D4FF' : '#8F9BB3',
                  }}>{item}</div>
                ))}
              </div>
              <div style={styles.dashboardMain}>
                <div style={styles.dashboardStats}>
                  {[
                    { label: 'Candidates', value: '1,248', color: '#00D4FF' },
                    { label: 'Interviews', value: '24', color: '#7B61FF' },
                    { label: 'Offers', value: '8', color: '#00E5A0' },
                  ].map((stat) => (
                    <div key={stat.label} style={styles.dashboardStat}>
                      <span style={{...styles.dashboardStatValue, color: stat.color}}>{stat.value}</span>
                      <span style={styles.dashboardStatLabel}>{stat.label}</span>
                    </div>
                  ))}
                </div>
                <div style={styles.dashboardCards}>
                  {[1, 2, 3].map((i) => (
                    <div key={i} style={styles.dashboardCard}>
                      <div style={styles.dashboardCardAvatar}>👤</div>
                      <div style={styles.dashboardCardLines}>
                        <div style={styles.dashboardCardLine} />
                        <div style={{...styles.dashboardCardLine, width: '60%'}} />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section style={styles.stats}>
        <div style={styles.statsContent}>
          {[
            { value: animatedStats.candidates.toLocaleString(), suffix: '+', label: 'Candidates Processed', icon: '👥' },
            { value: animatedStats.hires.toLocaleString(), suffix: '+', label: 'Successful Hires', icon: '✅' },
            { value: animatedStats.time, suffix: '%', label: 'Faster Time-to-Hire', icon: '⚡' },
            { value: animatedStats.satisfaction, suffix: '%', label: 'Customer Satisfaction', icon: '⭐' },
          ].map((stat, index) => (
            <div key={index} style={styles.statItem}>
              <span style={styles.statIcon}>{stat.icon}</span>
              <span style={styles.statValue}>{stat.value}{stat.suffix}</span>
              <span style={styles.statLabel}>{stat.label}</span>
            </div>
          ))}
        </div>
      </section>

      {/* Features Section */}
      <section id="features" style={styles.features}>
        <div style={styles.sectionHeader}>
          <span style={styles.sectionTag}>Features</span>
          <h2 style={styles.sectionTitle}>Everything you need to hire better</h2>
          <p style={styles.sectionSubtitle}>
            Powerful features designed to streamline your entire hiring process, 
            from sourcing to onboarding.
          </p>
        </div>

        <div style={styles.featuresGrid}>
          <div style={styles.featuresList}>
            {features.map((feature, index) => (
              <div 
                key={index}
                style={{
                  ...styles.featureItem,
                  background: activeFeature === index ? `linear-gradient(135deg, ${feature.color}11 0%, transparent 100%)` : 'transparent',
                  borderColor: activeFeature === index ? `${feature.color}44` : 'rgba(255, 255, 255, 0.06)',
                }}
                onClick={() => setActiveFeature(index)}
                className="feature-item"
              >
                <div style={{...styles.featureIcon, background: `${feature.color}22`, color: feature.color}}>
                  {feature.icon}
                </div>
                <div style={styles.featureContent}>
                  <h3 style={styles.featureTitle}>{feature.title}</h3>
                  <p style={styles.featureDescription}>{feature.description}</p>
                </div>
                <div style={{...styles.featureArrow, opacity: activeFeature === index ? 1 : 0}}>→</div>
              </div>
            ))}
          </div>

          <div style={styles.featurePreview}>
            <div style={{
              ...styles.featurePreviewCard,
              borderColor: `${features[activeFeature].color}44`,
            }}>
              <div style={styles.featurePreviewHeader}>
                <span style={styles.featurePreviewDot} />
                <span style={styles.featurePreviewDot} />
                <span style={styles.featurePreviewDot} />
              </div>
              <div style={styles.featurePreviewContent}>
                {activeFeature === 0 && (
                  <div style={styles.matchingPreview}>
                    <div style={styles.matchingHeader}>
                      <span style={styles.matchingTitle}>AI Match Score</span>
                      <span style={styles.matchingScore}>94%</span>
                    </div>
                    <div style={styles.matchingBars}>
                      {['Skills Match', 'Experience', 'Culture Fit', 'Education'].map((label, i) => (
                        <div key={label} style={styles.matchingBar}>
                          <span style={styles.matchingBarLabel}>{label}</span>
                          <div style={styles.matchingBarTrack}>
                            <div style={{
                              ...styles.matchingBarFill,
                              width: `${90 - i * 5}%`,
                              background: features[0].color,
                            }} />
                          </div>
                          <span style={styles.matchingBarValue}>{90 - i * 5}%</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
                {activeFeature === 1 && (
                  <div style={styles.pipelinePreview}>
                    {['Applied', 'Screening', 'Interview', 'Offer', 'Hired'].map((stage, i) => (
                      <div key={stage} style={styles.pipelineStage}>
                        <div style={{
                          ...styles.pipelineStageDot,
                          background: i <= 2 ? features[1].color : '#243B55',
                        }} />
                        <span style={{
                          ...styles.pipelineStageName,
                          color: i <= 2 ? '#fff' : '#8F9BB3',
                        }}>{stage}</span>
                        {i < 4 && <div style={{
                          ...styles.pipelineLine,
                          background: i < 2 ? features[1].color : '#243B55',
                        }} />}
                      </div>
                    ))}
                  </div>
                )}
                {activeFeature === 2 && (
                  <div style={styles.collaborationPreview}>
                    {['Sarah gave thumbs up', 'Mike left feedback', 'Lisa scheduled interview'].map((action, i) => (
                      <div key={i} style={styles.collaborationItem}>
                        <div style={styles.collaborationAvatar}>
                          {['👩', '👨', '👩‍🦰'][i]}
                        </div>
                        <span style={styles.collaborationText}>{action}</span>
                        <span style={styles.collaborationTime}>{['2m', '5m', '10m'][i]} ago</span>
                      </div>
                    ))}
                  </div>
                )}
                {activeFeature === 3 && (
                  <div style={styles.analyticsPreview}>
                    <div style={styles.analyticsChart}>
                      {[40, 65, 45, 80, 55, 90, 70].map((height, i) => (
                        <div key={i} style={styles.analyticsBar}>
                          <div style={{
                            ...styles.analyticsBarFill,
                            height: `${height}%`,
                            background: `linear-gradient(180deg, ${features[3].color} 0%, ${features[3].color}44 100%)`,
                          }} />
                        </div>
                      ))}
                    </div>
                    <div style={styles.analyticsLabels}>
                      {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => (
                        <span key={day} style={styles.analyticsLabel}>{day}</span>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section id="how-it-works" style={styles.howItWorks}>
        <div style={styles.sectionHeader}>
          <span style={styles.sectionTag}>How It Works</span>
          <h2 style={styles.sectionTitle}>Start hiring in minutes</h2>
          <p style={styles.sectionSubtitle}>
            Get up and running quickly with our intuitive platform
          </p>
        </div>

        <div style={styles.stepsContainer}>
          {[
            { step: '01', title: 'Post Your Job', description: 'Create a job posting in seconds. Our AI helps optimize your listing for maximum visibility.', icon: '📝' },
            { step: '02', title: 'AI Finds Matches', description: 'Our algorithms analyze thousands of candidates and surface the best matches for your role.', icon: '🎯' },
            { step: '03', title: 'Collaborate & Decide', description: 'Review candidates with your team, conduct interviews, and make data-driven decisions.', icon: '👥' },
            { step: '04', title: 'Hire & Onboard', description: 'Send offers, get signatures, and seamlessly transition to onboarding.', icon: '🎉' },
          ].map((item, index) => (
            <div key={index} style={styles.stepCard} className="step-card">
              <div style={styles.stepNumber}>{item.step}</div>
              <div style={styles.stepIcon}>{item.icon}</div>
              <h3 style={styles.stepTitle}>{item.title}</h3>
              <p style={styles.stepDescription}>{item.description}</p>
              {index < 3 && <div style={styles.stepConnector} />}
            </div>
          ))}
        </div>
      </section>

      {/* Testimonials */}
      <section id="testimonials" style={styles.testimonials}>
        <div style={styles.sectionHeader}>
          <span style={styles.sectionTag}>Testimonials</span>
          <h2 style={styles.sectionTitle}>Loved by hiring teams everywhere</h2>
        </div>

        <div style={styles.testimonialsGrid}>
          {testimonials.map((testimonial, index) => (
            <div key={index} style={styles.testimonialCard} className="testimonial-card">
              <div style={styles.testimonialQuote}>"</div>
              <p style={styles.testimonialText}>{testimonial.quote}</p>
              <div style={styles.testimonialAuthor}>
                <div style={styles.testimonialAvatar}>{testimonial.avatar}</div>
                <div style={styles.testimonialInfo}>
                  <span style={styles.testimonialName}>{testimonial.author}</span>
                  <span style={styles.testimonialRole}>{testimonial.role}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Pricing */}
      <section id="pricing" style={styles.pricing}>
        <div style={styles.sectionHeader}>
          <span style={styles.sectionTag}>Pricing</span>
          <h2 style={styles.sectionTitle}>Simple, transparent pricing</h2>
          <p style={styles.sectionSubtitle}>
            Start free, upgrade when you need more. No hidden fees.
          </p>
        </div>

        <div style={styles.pricingGrid}>
          {pricingPlans.map((plan, index) => (
            <div 
              key={index} 
              style={{
                ...styles.pricingCard,
                ...(plan.popular ? styles.pricingCardPopular : {}),
              }}
              className="pricing-card"
            >
              {plan.popular && <div style={styles.popularBadge}>Most Popular</div>}
              <h3 style={styles.pricingName}>{plan.name}</h3>
              <div style={styles.pricingPrice}>
                {typeof plan.price === 'number' ? (
                  <>
                    <span style={styles.pricingCurrency}>$</span>
                    <span style={styles.pricingAmount}>{plan.price}</span>
                    <span style={styles.pricingPeriod}>/month</span>
                  </>
                ) : (
                  <span style={styles.pricingCustom}>{plan.price}</span>
                )}
              </div>
              <p style={styles.pricingDescription}>{plan.description}</p>
              <ul style={styles.pricingFeatures}>
                {plan.features.map((feature, i) => (
                  <li key={i} style={styles.pricingFeature}>
                    <span style={styles.pricingCheck}>✓</span>
                    {feature}
                  </li>
                ))}
              </ul>
              <button style={{
                ...styles.pricingBtn,
                ...(plan.popular ? styles.pricingBtnPopular : {}),
              }}>
                {plan.cta}
              </button>
            </div>
          ))}
        </div>
      </section>

      {/* CTA Section */}
      <section style={styles.cta}>
        <div style={styles.ctaContent}>
          <h2 style={styles.ctaTitle}>Ready to transform your hiring?</h2>
          <p style={styles.ctaSubtitle}>
            Join thousands of teams already hiring smarter with TalentForge.
            Start your free trial today.
          </p>
          <div style={styles.ctaActions}>
            <button style={styles.ctaPrimaryBtn}>
              Start Free Trial
              <span style={styles.btnArrow}>→</span>
            </button>
            <button style={styles.ctaSecondaryBtn}>
              Talk to Sales
            </button>
          </div>
          <p style={styles.ctaNote}>No credit card required • 14-day free trial • Cancel anytime</p>
        </div>
        <div style={styles.ctaGlow} />
      </section>

      {/* Footer */}
      <footer style={styles.footer}>
        <div style={styles.footerContent}>
          <div style={styles.footerBrand}>
            <div style={styles.logo}>
              <div style={styles.logoIcon}>⚡</div>
              <span style={styles.logoText}>TalentForge</span>
            </div>
            <p style={styles.footerTagline}>
              The modern ATS for exceptional hiring.
            </p>
            <div style={styles.footerSocial}>
              {['Twitter', 'LinkedIn', 'GitHub'].map((social) => (
                <a key={social} href="#" style={styles.footerSocialLink}>{social}</a>
              ))}
            </div>
          </div>

          <div style={styles.footerLinks}>
            <div style={styles.footerColumn}>
              <h4 style={styles.footerColumnTitle}>Product</h4>
              {['Features', 'Pricing', 'Integrations', 'API', 'Changelog'].map((link) => (
                <a key={link} href="#" style={styles.footerLink}>{link}</a>
              ))}
            </div>
            <div style={styles.footerColumn}>
              <h4 style={styles.footerColumnTitle}>Company</h4>
              {['About', 'Blog', 'Careers', 'Press', 'Contact'].map((link) => (
                <a key={link} href="#" style={styles.footerLink}>{link}</a>
              ))}
            </div>
            <div style={styles.footerColumn}>
              <h4 style={styles.footerColumnTitle}>Resources</h4>
              {['Help Center', 'Community', 'Guides', 'Webinars', 'Templates'].map((link) => (
                <a key={link} href="#" style={styles.footerLink}>{link}</a>
              ))}
            </div>
            <div style={styles.footerColumn}>
              <h4 style={styles.footerColumnTitle}>Legal</h4>
              {['Privacy', 'Terms', 'Security', 'Cookies', 'GDPR'].map((link) => (
                <a key={link} href="#" style={styles.footerLink}>{link}</a>
              ))}
            </div>
          </div>
        </div>

        <div style={styles.footerBottom}>
          <span style={styles.footerCopyright}>© 2025 TalentForge. All rights reserved.</span>
          <div style={styles.footerBadges}>
            <span style={styles.footerBadge}>SOC 2</span>
            <span style={styles.footerBadge}>GDPR</span>
            <span style={styles.footerBadge}>ISO 27001</span>
          </div>
        </div>
      </footer>
    </div>
  );
}

// Global Styles
const globalStyles = `
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');
  
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  
  html {
    scroll-behavior: smooth;
  }
  
  body {
    font-family: 'Inter', sans-serif;
    background: #0A1628;
    color: #E4E9F2;
    overflow-x: hidden;
  }

  .feature-item {
    transition: all 0.3s ease;
    cursor: pointer;
  }

  .feature-item:hover {
    transform: translateX(8px);
  }

  .step-card {
    transition: all 0.3s ease;
  }

  .step-card:hover {
    transform: translateY(-8px);
  }

  .testimonial-card {
    transition: all 0.3s ease;
  }

  .testimonial-card:hover {
    transform: translateY(-4px);
    border-color: rgba(0, 212, 255, 0.3);
  }

  .pricing-card {
    transition: all 0.3s ease;
  }

  .pricing-card:hover {
    transform: translateY(-8px);
  }

  @keyframes float {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-20px); }
  }

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
  }

  @keyframes gradient {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
  }
`;

// Styles
const styles = {
  container: {
    minHeight: '100vh',
    background: '#0A1628',
  },

  // Navigation
  nav: {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 1000,
    padding: '16px 0',
    transition: 'all 0.3s ease',
  },

  navContent: {
    maxWidth: '1280px',
    margin: '0 auto',
    padding: '0 32px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
  },

  logo: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
  },

  logoIcon: {
    width: '40px',
    height: '40px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    borderRadius: '12px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '20px',
  },

  logoText: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '22px',
    fontWeight: 700,
    color: '#fff',
  },

  navLinks: {
    display: 'flex',
    gap: '32px',
  },

  navLink: {
    color: '#C5CEE0',
    textDecoration: 'none',
    fontSize: '15px',
    fontWeight: 500,
    transition: 'color 0.2s ease',
  },

  navActions: {
    display: 'flex',
    gap: '12px',
  },

  loginBtn: {
    padding: '10px 20px',
    background: 'transparent',
    border: '1px solid rgba(255, 255, 255, 0.2)',
    borderRadius: '10px',
    color: '#fff',
    fontSize: '14px',
    fontWeight: 500,
    cursor: 'pointer',
  },

  ctaBtn: {
    padding: '10px 20px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    border: 'none',
    borderRadius: '10px',
    color: '#fff',
    fontSize: '14px',
    fontWeight: 600,
    cursor: 'pointer',
  },

  // Hero
  hero: {
    position: 'relative',
    minHeight: '100vh',
    display: 'flex',
    alignItems: 'center',
    padding: '120px 32px 80px',
    maxWidth: '1280px',
    margin: '0 auto',
    gap: '60px',
  },

  heroBackground: {
    position: 'absolute',
    inset: 0,
    overflow: 'hidden',
    pointerEvents: 'none',
  },

  heroGradient1: {
    position: 'absolute',
    top: '-200px',
    right: '-200px',
    width: '600px',
    height: '600px',
    background: 'radial-gradient(circle, rgba(0, 212, 255, 0.15) 0%, transparent 70%)',
    animation: 'float 8s ease-in-out infinite',
  },

  heroGradient2: {
    position: 'absolute',
    bottom: '-100px',
    left: '-100px',
    width: '400px',
    height: '400px',
    background: 'radial-gradient(circle, rgba(123, 97, 255, 0.15) 0%, transparent 70%)',
    animation: 'float 6s ease-in-out infinite reverse',
  },

  heroGrid: {
    position: 'absolute',
    inset: 0,
    backgroundImage: `
      linear-gradient(rgba(255, 255, 255, 0.02) 1px, transparent 1px),
      linear-gradient(90deg, rgba(255, 255, 255, 0.02) 1px, transparent 1px)
    `,
    backgroundSize: '60px 60px',
  },

  heroContent: {
    flex: 1,
    position: 'relative',
    zIndex: 1,
  },

  heroBadge: {
    display: 'inline-flex',
    alignItems: 'center',
    gap: '8px',
    padding: '8px 16px',
    background: 'rgba(0, 212, 255, 0.1)',
    border: '1px solid rgba(0, 212, 255, 0.2)',
    borderRadius: '100px',
    fontSize: '14px',
    color: '#00D4FF',
    marginBottom: '24px',
  },

  heroBadgeIcon: {
    fontSize: '16px',
  },

  heroTitle: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '64px',
    fontWeight: 800,
    lineHeight: 1.1,
    color: '#fff',
    marginBottom: '24px',
  },

  heroTitleGradient: {
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    WebkitBackgroundClip: 'text',
    WebkitTextFillColor: 'transparent',
    backgroundClip: 'text',
  },

  heroTitleLight: {
    color: '#8F9BB3',
  },

  heroSubtitle: {
    fontSize: '20px',
    color: '#8F9BB3',
    lineHeight: 1.6,
    maxWidth: '520px',
    marginBottom: '32px',
  },

  heroActions: {
    display: 'flex',
    gap: '16px',
    marginBottom: '48px',
  },

  heroPrimaryBtn: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    padding: '16px 32px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    border: 'none',
    borderRadius: '12px',
    color: '#fff',
    fontSize: '16px',
    fontWeight: 600,
    cursor: 'pointer',
  },

  btnArrow: {
    transition: 'transform 0.2s ease',
  },

  heroSecondaryBtn: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    padding: '16px 32px',
    background: 'rgba(255, 255, 255, 0.05)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '12px',
    color: '#fff',
    fontSize: '16px',
    fontWeight: 500,
    cursor: 'pointer',
  },

  playIcon: {
    width: '32px',
    height: '32px',
    background: 'rgba(0, 212, 255, 0.2)',
    borderRadius: '50%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '12px',
  },

  heroTrust: {
    display: 'flex',
    alignItems: 'center',
    gap: '24px',
  },

  heroTrustLabel: {
    fontSize: '14px',
    color: '#5D6B82',
  },

  heroLogos: {
    display: 'flex',
    gap: '32px',
  },

  heroLogo: {
    fontSize: '16px',
    fontWeight: 600,
    color: '#5D6B82',
    opacity: 0.7,
  },

  heroImage: {
    flex: 1,
    position: 'relative',
    zIndex: 1,
  },

  dashboardPreview: {
    background: '#1A2942',
    borderRadius: '16px',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    overflow: 'hidden',
    boxShadow: '0 40px 80px rgba(0, 0, 0, 0.4)',
  },

  dashboardHeader: {
    padding: '12px 16px',
    background: '#0D1B2A',
    borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
  },

  dashboardDots: {
    display: 'flex',
    gap: '8px',
  },

  dot: {
    width: '12px',
    height: '12px',
    borderRadius: '50%',
  },

  dashboardContent: {
    display: 'flex',
    minHeight: '300px',
  },

  dashboardSidebar: {
    width: '160px',
    padding: '16px',
    borderRight: '1px solid rgba(255, 255, 255, 0.06)',
    display: 'flex',
    flexDirection: 'column',
    gap: '8px',
  },

  dashboardMenuItem: {
    padding: '10px 12px',
    borderRadius: '8px',
    fontSize: '13px',
    fontWeight: 500,
  },

  dashboardMain: {
    flex: 1,
    padding: '20px',
  },

  dashboardStats: {
    display: 'flex',
    gap: '16px',
    marginBottom: '20px',
  },

  dashboardStat: {
    flex: 1,
    background: 'rgba(255, 255, 255, 0.03)',
    borderRadius: '12px',
    padding: '16px',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
  },

  dashboardStatValue: {
    fontSize: '24px',
    fontWeight: 700,
  },

  dashboardStatLabel: {
    fontSize: '12px',
    color: '#8F9BB3',
  },

  dashboardCards: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px',
  },

  dashboardCard: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    padding: '12px',
    background: 'rgba(255, 255, 255, 0.03)',
    borderRadius: '8px',
  },

  dashboardCardAvatar: {
    width: '36px',
    height: '36px',
    background: '#243B55',
    borderRadius: '8px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  dashboardCardLines: {
    flex: 1,
    display: 'flex',
    flexDirection: 'column',
    gap: '6px',
  },

  dashboardCardLine: {
    height: '8px',
    background: '#243B55',
    borderRadius: '4px',
  },

  // Stats
  stats: {
    background: '#0D1B2A',
    padding: '60px 32px',
    borderTop: '1px solid rgba(255, 255, 255, 0.06)',
    borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
  },

  statsContent: {
    maxWidth: '1280px',
    margin: '0 auto',
    display: 'flex',
    justifyContent: 'space-around',
  },

  statItem: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '8px',
  },

  statIcon: {
    fontSize: '32px',
    marginBottom: '8px',
  },

  statValue: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '48px',
    fontWeight: 800,
    color: '#fff',
  },

  statLabel: {
    fontSize: '16px',
    color: '#8F9BB3',
  },

  // Section Common
  sectionHeader: {
    textAlign: 'center',
    marginBottom: '60px',
  },

  sectionTag: {
    display: 'inline-block',
    padding: '8px 16px',
    background: 'rgba(0, 212, 255, 0.1)',
    border: '1px solid rgba(0, 212, 255, 0.2)',
    borderRadius: '100px',
    fontSize: '14px',
    fontWeight: 500,
    color: '#00D4FF',
    marginBottom: '16px',
  },

  sectionTitle: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '44px',
    fontWeight: 800,
    color: '#fff',
    marginBottom: '16px',
  },

  sectionSubtitle: {
    fontSize: '18px',
    color: '#8F9BB3',
    maxWidth: '600px',
    margin: '0 auto',
    lineHeight: 1.6,
  },

  // Features
  features: {
    padding: '100px 32px',
    maxWidth: '1280px',
    margin: '0 auto',
  },

  featuresGrid: {
    display: 'flex',
    gap: '40px',
  },

  featuresList: {
    flex: 1,
    display: 'flex',
    flexDirection: 'column',
    gap: '16px',
  },

  featureItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '20px',
    padding: '24px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
    borderRadius: '16px',
    transition: 'all 0.3s ease',
  },

  featureIcon: {
    width: '56px',
    height: '56px',
    borderRadius: '14px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '24px',
    flexShrink: 0,
  },

  featureContent: {
    flex: 1,
  },

  featureTitle: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '18px',
    fontWeight: 600,
    color: '#fff',
    marginBottom: '4px',
  },

  featureDescription: {
    fontSize: '14px',
    color: '#8F9BB3',
    lineHeight: 1.5,
    margin: 0,
  },

  featureArrow: {
    fontSize: '20px',
    color: '#00D4FF',
    transition: 'opacity 0.3s ease',
  },

  featurePreview: {
    flex: 1,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  featurePreviewCard: {
    width: '100%',
    maxWidth: '400px',
    background: '#1A2942',
    borderRadius: '20px',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    overflow: 'hidden',
  },

  featurePreviewHeader: {
    padding: '12px 16px',
    background: '#0D1B2A',
    display: 'flex',
    gap: '8px',
  },

  featurePreviewDot: {
    width: '10px',
    height: '10px',
    background: '#243B55',
    borderRadius: '50%',
  },

  featurePreviewContent: {
    padding: '24px',
  },

  // Matching Preview
  matchingPreview: {},

  matchingHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '20px',
  },

  matchingTitle: {
    fontSize: '16px',
    fontWeight: 600,
    color: '#fff',
  },

  matchingScore: {
    fontSize: '24px',
    fontWeight: 700,
    color: '#00D4FF',
  },

  matchingBars: {
    display: 'flex',
    flexDirection: 'column',
    gap: '16px',
  },

  matchingBar: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
  },

  matchingBarLabel: {
    width: '100px',
    fontSize: '13px',
    color: '#8F9BB3',
  },

  matchingBarTrack: {
    flex: 1,
    height: '8px',
    background: '#243B55',
    borderRadius: '4px',
    overflow: 'hidden',
  },

  matchingBarFill: {
    height: '100%',
    borderRadius: '4px',
    transition: 'width 0.5s ease',
  },

  matchingBarValue: {
    width: '40px',
    fontSize: '13px',
    fontWeight: 600,
    color: '#fff',
    textAlign: 'right',
  },

  // Pipeline Preview
  pipelinePreview: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '20px 0',
  },

  pipelineStage: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    position: 'relative',
  },

  pipelineStageDot: {
    width: '24px',
    height: '24px',
    borderRadius: '50%',
    marginBottom: '8px',
  },

  pipelineStageName: {
    fontSize: '12px',
    fontWeight: 500,
  },

  pipelineLine: {
    position: 'absolute',
    top: '12px',
    left: '24px',
    width: '40px',
    height: '2px',
  },

  // Collaboration Preview
  collaborationPreview: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },

  collaborationItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    padding: '12px',
    background: '#243B55',
    borderRadius: '10px',
  },

  collaborationAvatar: {
    fontSize: '24px',
  },

  collaborationText: {
    flex: 1,
    fontSize: '14px',
    color: '#E4E9F2',
  },

  collaborationTime: {
    fontSize: '12px',
    color: '#5D6B82',
  },

  // Analytics Preview
  analyticsPreview: {},

  analyticsChart: {
    display: 'flex',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    height: '150px',
    padding: '0 10px',
    marginBottom: '12px',
  },

  analyticsBar: {
    width: '32px',
    height: '100%',
    display: 'flex',
    alignItems: 'flex-end',
  },

  analyticsBarFill: {
    width: '100%',
    borderRadius: '4px 4px 0 0',
    transition: 'height 0.5s ease',
  },

  analyticsLabels: {
    display: 'flex',
    justifyContent: 'space-between',
    padding: '0 10px',
  },

  analyticsLabel: {
    fontSize: '12px',
    color: '#5D6B82',
    width: '32px',
    textAlign: 'center',
  },

  // How It Works
  howItWorks: {
    padding: '100px 32px',
    background: '#0D1B2A',
  },

  stepsContainer: {
    maxWidth: '1280px',
    margin: '0 auto',
    display: 'flex',
    justifyContent: 'space-between',
    gap: '24px',
  },

  stepCard: {
    flex: 1,
    position: 'relative',
    background: '#1A2942',
    borderRadius: '20px',
    padding: '32px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  stepNumber: {
    position: 'absolute',
    top: '-16px',
    left: '32px',
    fontSize: '14px',
    fontWeight: 700,
    color: '#00D4FF',
    background: '#1A2942',
    padding: '8px 16px',
    borderRadius: '8px',
    border: '1px solid rgba(0, 212, 255, 0.3)',
  },

  stepIcon: {
    fontSize: '40px',
    marginBottom: '16px',
    marginTop: '8px',
  },

  stepTitle: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '20px',
    fontWeight: 600,
    color: '#fff',
    marginBottom: '8px',
  },

  stepDescription: {
    fontSize: '14px',
    color: '#8F9BB3',
    lineHeight: 1.6,
    margin: 0,
  },

  stepConnector: {
    position: 'absolute',
    top: '50%',
    right: '-32px',
    width: '40px',
    height: '2px',
    background: 'linear-gradient(90deg, #00D4FF, transparent)',
  },

  // Testimonials
  testimonials: {
    padding: '100px 32px',
    maxWidth: '1280px',
    margin: '0 auto',
  },

  testimonialsGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(3, 1fr)',
    gap: '24px',
  },

  testimonialCard: {
    background: '#1A2942',
    borderRadius: '20px',
    padding: '32px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  testimonialQuote: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '64px',
    fontWeight: 800,
    color: '#00D4FF',
    lineHeight: 0.5,
    marginBottom: '20px',
  },

  testimonialText: {
    fontSize: '16px',
    color: '#E4E9F2',
    lineHeight: 1.6,
    marginBottom: '24px',
  },

  testimonialAuthor: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
  },

  testimonialAvatar: {
    width: '48px',
    height: '48px',
    background: '#243B55',
    borderRadius: '12px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '24px',
  },

  testimonialInfo: {
    display: 'flex',
    flexDirection: 'column',
  },

  testimonialName: {
    fontSize: '15px',
    fontWeight: 600,
    color: '#fff',
  },

  testimonialRole: {
    fontSize: '13px',
    color: '#8F9BB3',
  },

  // Pricing
  pricing: {
    padding: '100px 32px',
    background: '#0D1B2A',
  },

  pricingGrid: {
    maxWidth: '1100px',
    margin: '0 auto',
    display: 'grid',
    gridTemplateColumns: 'repeat(3, 1fr)',
    gap: '24px',
  },

  pricingCard: {
    position: 'relative',
    background: '#1A2942',
    borderRadius: '24px',
    padding: '32px',
    border: '1px solid rgba(255, 255, 255, 0.06)',
  },

  pricingCardPopular: {
    background: 'linear-gradient(135deg, rgba(0, 212, 255, 0.1) 0%, rgba(123, 97, 255, 0.1) 100%)',
    border: '1px solid rgba(0, 212, 255, 0.3)',
  },

  popularBadge: {
    position: 'absolute',
    top: '-12px',
    left: '50%',
    transform: 'translateX(-50%)',
    padding: '6px 16px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    borderRadius: '100px',
    fontSize: '12px',
    fontWeight: 600,
    color: '#fff',
  },

  pricingName: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '24px',
    fontWeight: 700,
    color: '#fff',
    marginBottom: '16px',
  },

  pricingPrice: {
    marginBottom: '8px',
  },

  pricingCurrency: {
    fontSize: '24px',
    fontWeight: 600,
    color: '#fff',
    verticalAlign: 'top',
  },

  pricingAmount: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '56px',
    fontWeight: 800,
    color: '#fff',
  },

  pricingPeriod: {
    fontSize: '16px',
    color: '#8F9BB3',
  },

  pricingCustom: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '40px',
    fontWeight: 800,
    color: '#fff',
  },

  pricingDescription: {
    fontSize: '14px',
    color: '#8F9BB3',
    marginBottom: '24px',
  },

  pricingFeatures: {
    listStyle: 'none',
    marginBottom: '32px',
  },

  pricingFeature: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    fontSize: '14px',
    color: '#E4E9F2',
    padding: '8px 0',
  },

  pricingCheck: {
    color: '#00E5A0',
    fontWeight: 700,
  },

  pricingBtn: {
    width: '100%',
    padding: '14px',
    background: '#243B55',
    border: 'none',
    borderRadius: '12px',
    color: '#fff',
    fontSize: '15px',
    fontWeight: 600,
    cursor: 'pointer',
  },

  pricingBtnPopular: {
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
  },

  // CTA
  cta: {
    position: 'relative',
    padding: '120px 32px',
    textAlign: 'center',
    overflow: 'hidden',
  },

  ctaContent: {
    position: 'relative',
    zIndex: 1,
    maxWidth: '700px',
    margin: '0 auto',
  },

  ctaTitle: {
    fontFamily: "'Plus Jakarta Sans', sans-serif",
    fontSize: '48px',
    fontWeight: 800,
    color: '#fff',
    marginBottom: '16px',
  },

  ctaSubtitle: {
    fontSize: '18px',
    color: '#8F9BB3',
    marginBottom: '32px',
    lineHeight: 1.6,
  },

  ctaActions: {
    display: 'flex',
    justifyContent: 'center',
    gap: '16px',
    marginBottom: '24px',
  },

  ctaPrimaryBtn: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    padding: '16px 32px',
    background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
    border: 'none',
    borderRadius: '12px',
    color: '#fff',
    fontSize: '16px',
    fontWeight: 600,
    cursor: 'pointer',
  },

  ctaSecondaryBtn: {
    padding: '16px 32px',
    background: 'rgba(255, 255, 255, 0.05)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '12px',
    color: '#fff',
    fontSize: '16px',
    fontWeight: 500,
    cursor: 'pointer',
  },

  ctaNote: {
    fontSize: '14px',
    color: '#5D6B82',
  },

  ctaGlow: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    width: '800px',
    height: '400px',
    background: 'radial-gradient(ellipse, rgba(0, 212, 255, 0.15) 0%, transparent 70%)',
    pointerEvents: 'none',
  },

  // Footer
  footer: {
    padding: '80px 32px 32px',
    background: '#0D1B2A',
    borderTop: '1px solid rgba(255, 255, 255, 0.06)',
  },

  footerContent: {
    maxWidth: '1280px',
    margin: '0 auto',
    display: 'flex',
    gap: '80px',
    marginBottom: '60px',
  },

  footerBrand: {
    maxWidth: '280px',
  },

  footerTagline: {
    fontSize: '14px',
    color: '#8F9BB3',
    marginTop: '16px',
    marginBottom: '24px',
    lineHeight: 1.6,
  },

  footerSocial: {
    display: 'flex',
    gap: '16px',
  },

  footerSocialLink: {
    fontSize: '14px',
    color: '#8F9BB3',
    textDecoration: 'none',
  },

  footerLinks: {
    flex: 1,
    display: 'flex',
    gap: '60px',
  },

  footerColumn: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px',
  },

  footerColumnTitle: {
    fontSize: '14px',
    fontWeight: 600,
    color: '#fff',
    marginBottom: '8px',
  },

  footerLink: {
    fontSize: '14px',
    color: '#8F9BB3',
    textDecoration: 'none',
  },

  footerBottom: {
    maxWidth: '1280px',
    margin: '0 auto',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: '32px',
    borderTop: '1px solid rgba(255, 255, 255, 0.06)',
  },

  footerCopyright: {
    fontSize: '14px',
    color: '#5D6B82',
  },

  footerBadges: {
    display: 'flex',
    gap: '12px',
  },

  footerBadge: {
    padding: '6px 12px',
    background: '#1A2942',
    borderRadius: '6px',
    fontSize: '12px',
    fontWeight: 500,
    color: '#8F9BB3',
  },
};
