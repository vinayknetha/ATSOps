import React from 'react';

// ============================================================================
// TALENTFORGE - SHARED COMPONENTS LIBRARY
// Reusable UI components for the TalentForge ATS
// ============================================================================

// Theme Colors
export const colors = {
  primary: '#0A1628',
  secondary: '#1A2942',
  tertiary: '#243B55',
  accent: '#00D4FF',
  accentAlt: '#7B61FF',
  accentGreen: '#00E5A0',
  accentOrange: '#FF6B35',
  accentPink: '#FF3D71',
  white: '#FFFFFF',
  gray100: '#F7F9FC',
  gray200: '#E4E9F2',
  gray300: '#C5CEE0',
  gray400: '#8F9BB3',
  gray500: '#5D6B82',
  success: '#00E5A0',
  warning: '#FFB800',
  error: '#FF3D71',
  info: '#00D4FF',
};

// ============================================================================
// BUTTON COMPONENT
// ============================================================================
export function Button({ 
  children, 
  variant = 'primary', 
  size = 'md', 
  icon, 
  iconPosition = 'left',
  disabled = false,
  loading = false,
  fullWidth = false,
  onClick,
  ...props 
}) {
  const baseStyles = {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '8px',
    fontFamily: "'Inter', sans-serif",
    fontWeight: 600,
    borderRadius: '12px',
    cursor: disabled ? 'not-allowed' : 'pointer',
    transition: 'all 0.2s ease',
    opacity: disabled ? 0.5 : 1,
    width: fullWidth ? '100%' : 'auto',
  };

  const sizeStyles = {
    sm: { padding: '8px 16px', fontSize: '13px' },
    md: { padding: '12px 24px', fontSize: '14px' },
    lg: { padding: '16px 32px', fontSize: '16px' },
  };

  const variantStyles = {
    primary: {
      background: 'linear-gradient(135deg, #00D4FF 0%, #7B61FF 100%)',
      border: 'none',
      color: '#fff',
    },
    secondary: {
      background: '#1A2942',
      border: '1px solid rgba(255, 255, 255, 0.1)',
      color: '#E4E9F2',
    },
    outline: {
      background: 'transparent',
      border: '1px solid rgba(0, 212, 255, 0.5)',
      color: '#00D4FF',
    },
    ghost: {
      background: 'transparent',
      border: 'none',
      color: '#8F9BB3',
    },
    danger: {
      background: 'rgba(255, 61, 113, 0.1)',
      border: '1px solid rgba(255, 61, 113, 0.3)',
      color: '#FF3D71',
    },
    success: {
      background: 'rgba(0, 229, 160, 0.1)',
      border: '1px solid rgba(0, 229, 160, 0.3)',
      color: '#00E5A0',
    },
  };

  return (
    <button
      style={{
        ...baseStyles,
        ...sizeStyles[size],
        ...variantStyles[variant],
      }}
      disabled={disabled || loading}
      onClick={onClick}
      {...props}
    >
      {loading ? (
        <Spinner size={size === 'sm' ? 14 : size === 'lg' ? 20 : 16} />
      ) : (
        <>
          {icon && iconPosition === 'left' && icon}
          {children}
          {icon && iconPosition === 'right' && icon}
        </>
      )}
    </button>
  );
}

// ============================================================================
// SPINNER COMPONENT
// ============================================================================
export function Spinner({ size = 20, color = 'currentColor' }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      style={{ animation: 'spin 1s linear infinite' }}
    >
      <circle
        cx="12"
        cy="12"
        r="10"
        stroke={color}
        strokeWidth="3"
        strokeLinecap="round"
        strokeDasharray="31.4 31.4"
        opacity="0.25"
      />
      <circle
        cx="12"
        cy="12"
        r="10"
        stroke={color}
        strokeWidth="3"
        strokeLinecap="round"
        strokeDasharray="31.4 31.4"
        strokeDashoffset="23.55"
      />
      <style>{`
        @keyframes spin {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
      `}</style>
    </svg>
  );
}

// ============================================================================
// INPUT COMPONENT
// ============================================================================
export function Input({
  label,
  placeholder,
  type = 'text',
  value,
  onChange,
  icon,
  error,
  helperText,
  disabled = false,
  fullWidth = false,
  ...props
}) {
  const containerStyle = {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px',
    width: fullWidth ? '100%' : 'auto',
  };

  const labelStyle = {
    fontSize: '14px',
    fontWeight: 500,
    color: '#E4E9F2',
  };

  const inputWrapperStyle = {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    background: '#1A2942',
    border: `1px solid ${error ? '#FF3D71' : 'rgba(255, 255, 255, 0.1)'}`,
    borderRadius: '12px',
    padding: '12px 16px',
    transition: 'all 0.2s ease',
  };

  const inputStyle = {
    flex: 1,
    background: 'transparent',
    border: 'none',
    outline: 'none',
    color: '#E4E9F2',
    fontSize: '14px',
    fontFamily: "'Inter', sans-serif",
  };

  const helperStyle = {
    fontSize: '12px',
    color: error ? '#FF3D71' : '#8F9BB3',
  };

  return (
    <div style={containerStyle}>
      {label && <label style={labelStyle}>{label}</label>}
      <div style={inputWrapperStyle}>
        {icon && <span style={{ color: '#8F9BB3' }}>{icon}</span>}
        <input
          type={type}
          placeholder={placeholder}
          value={value}
          onChange={onChange}
          disabled={disabled}
          style={inputStyle}
          {...props}
        />
      </div>
      {(error || helperText) && (
        <span style={helperStyle}>{error || helperText}</span>
      )}
    </div>
  );
}

// ============================================================================
// SELECT COMPONENT
// ============================================================================
export function Select({
  label,
  options = [],
  value,
  onChange,
  placeholder = 'Select...',
  disabled = false,
  fullWidth = false,
  ...props
}) {
  const containerStyle = {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px',
    width: fullWidth ? '100%' : 'auto',
  };

  const labelStyle = {
    fontSize: '14px',
    fontWeight: 500,
    color: '#E4E9F2',
  };

  const selectStyle = {
    background: '#1A2942',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '12px',
    padding: '12px 16px',
    color: '#E4E9F2',
    fontSize: '14px',
    fontFamily: "'Inter', sans-serif",
    cursor: 'pointer',
    outline: 'none',
    appearance: 'none',
    backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%238F9BB3' stroke-width='2'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E")`,
    backgroundRepeat: 'no-repeat',
    backgroundPosition: 'right 16px center',
    paddingRight: '44px',
  };

  return (
    <div style={containerStyle}>
      {label && <label style={labelStyle}>{label}</label>}
      <select
        value={value}
        onChange={onChange}
        disabled={disabled}
        style={selectStyle}
        {...props}
      >
        <option value="" disabled>{placeholder}</option>
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </div>
  );
}

// ============================================================================
// BADGE COMPONENT
// ============================================================================
export function Badge({ 
  children, 
  variant = 'default',
  size = 'md',
  dot = false,
}) {
  const baseStyles = {
    display: 'inline-flex',
    alignItems: 'center',
    gap: '6px',
    fontFamily: "'Inter', sans-serif",
    fontWeight: 500,
    borderRadius: '100px',
  };

  const sizeStyles = {
    sm: { padding: '2px 8px', fontSize: '11px' },
    md: { padding: '4px 12px', fontSize: '12px' },
    lg: { padding: '6px 16px', fontSize: '14px' },
  };

  const variantStyles = {
    default: { background: '#243B55', color: '#E4E9F2' },
    primary: { background: 'rgba(0, 212, 255, 0.15)', color: '#00D4FF' },
    success: { background: 'rgba(0, 229, 160, 0.15)', color: '#00E5A0' },
    warning: { background: 'rgba(255, 184, 0, 0.15)', color: '#FFB800' },
    error: { background: 'rgba(255, 61, 113, 0.15)', color: '#FF3D71' },
    purple: { background: 'rgba(123, 97, 255, 0.15)', color: '#7B61FF' },
  };

  return (
    <span style={{ ...baseStyles, ...sizeStyles[size], ...variantStyles[variant] }}>
      {dot && (
        <span style={{
          width: '6px',
          height: '6px',
          borderRadius: '50%',
          background: 'currentColor',
        }} />
      )}
      {children}
    </span>
  );
}

// ============================================================================
// AVATAR COMPONENT
// ============================================================================
export function Avatar({ 
  src, 
  name, 
  size = 'md',
  status,
}) {
  const sizes = {
    sm: 32,
    md: 40,
    lg: 56,
    xl: 80,
  };

  const dimension = sizes[size];
  const initials = name ? name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2) : '';

  const containerStyle = {
    position: 'relative',
    width: dimension,
    height: dimension,
    borderRadius: '12px',
    overflow: 'hidden',
    flexShrink: 0,
  };

  const avatarStyle = {
    width: '100%',
    height: '100%',
    background: 'linear-gradient(135deg, #7B61FF 0%, #00D4FF 100%)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    color: '#fff',
    fontSize: dimension * 0.4,
    fontWeight: 600,
    fontFamily: "'Plus Jakarta Sans', sans-serif",
  };

  const statusColors = {
    online: '#00E5A0',
    away: '#FFB800',
    busy: '#FF3D71',
    offline: '#5D6B82',
  };

  return (
    <div style={containerStyle}>
      {src ? (
        <img src={src} alt={name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
      ) : (
        <div style={avatarStyle}>{initials}</div>
      )}
      {status && (
        <div style={{
          position: 'absolute',
          bottom: -2,
          right: -2,
          width: dimension * 0.3,
          height: dimension * 0.3,
          background: statusColors[status],
          borderRadius: '50%',
          border: '2px solid #0A1628',
        }} />
      )}
    </div>
  );
}

// ============================================================================
// CARD COMPONENT
// ============================================================================
export function Card({ 
  children, 
  padding = 'md',
  hover = false,
  onClick,
  ...props 
}) {
  const paddingSizes = {
    sm: '16px',
    md: '24px',
    lg: '32px',
  };

  const cardStyle = {
    background: '#1A2942',
    borderRadius: '16px',
    padding: paddingSizes[padding],
    border: '1px solid rgba(255, 255, 255, 0.06)',
    transition: 'all 0.3s ease',
    cursor: onClick ? 'pointer' : 'default',
  };

  return (
    <div style={cardStyle} onClick={onClick} {...props}>
      {children}
    </div>
  );
}

// ============================================================================
// PROGRESS BAR COMPONENT
// ============================================================================
export function ProgressBar({ 
  value = 0, 
  max = 100, 
  color = '#00D4FF',
  size = 'md',
  showLabel = false,
}) {
  const percentage = Math.min(100, Math.max(0, (value / max) * 100));

  const heights = { sm: 4, md: 8, lg: 12 };

  const trackStyle = {
    width: '100%',
    height: heights[size],
    background: 'rgba(255, 255, 255, 0.1)',
    borderRadius: heights[size] / 2,
    overflow: 'hidden',
  };

  const fillStyle = {
    width: `${percentage}%`,
    height: '100%',
    background: `linear-gradient(90deg, ${color}, ${color}88)`,
    borderRadius: heights[size] / 2,
    transition: 'width 0.5s ease',
  };

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
      <div style={trackStyle}>
        <div style={fillStyle} />
      </div>
      {showLabel && (
        <span style={{ fontSize: '13px', fontWeight: 600, color: '#E4E9F2', minWidth: '40px' }}>
          {Math.round(percentage)}%
        </span>
      )}
    </div>
  );
}

// ============================================================================
// SCORE RING COMPONENT
// ============================================================================
export function ScoreRing({ 
  score, 
  size = 60, 
  strokeWidth = 4,
  showLabel = true,
}) {
  const radius = (size - strokeWidth) / 2;
  const circumference = radius * 2 * Math.PI;
  const offset = circumference - (score / 100) * circumference;

  const getColor = (score) => {
    if (score >= 90) return '#00E5A0';
    if (score >= 80) return '#00D4FF';
    if (score >= 70) return '#FFB800';
    return '#FF3D71';
  };

  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke="#243B55"
          strokeWidth={strokeWidth}
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke={getColor(score)}
          strokeWidth={strokeWidth}
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          strokeLinecap="round"
          style={{ transition: 'stroke-dashoffset 0.5s ease' }}
        />
      </svg>
      {showLabel && (
        <div style={{
          position: 'absolute',
          inset: 0,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: size * 0.28,
          fontWeight: 700,
          color: '#fff',
          fontFamily: "'Plus Jakarta Sans', sans-serif",
        }}>
          {score}
        </div>
      )}
    </div>
  );
}

// ============================================================================
// TOOLTIP COMPONENT
// ============================================================================
export function Tooltip({ children, content, position = 'top' }) {
  const [visible, setVisible] = React.useState(false);

  const positions = {
    top: { bottom: '100%', left: '50%', transform: 'translateX(-50%)', marginBottom: '8px' },
    bottom: { top: '100%', left: '50%', transform: 'translateX(-50%)', marginTop: '8px' },
    left: { right: '100%', top: '50%', transform: 'translateY(-50%)', marginRight: '8px' },
    right: { left: '100%', top: '50%', transform: 'translateY(-50%)', marginLeft: '8px' },
  };

  return (
    <div 
      style={{ position: 'relative', display: 'inline-flex' }}
      onMouseEnter={() => setVisible(true)}
      onMouseLeave={() => setVisible(false)}
    >
      {children}
      {visible && (
        <div style={{
          position: 'absolute',
          ...positions[position],
          background: '#0D1B2A',
          border: '1px solid rgba(255, 255, 255, 0.1)',
          borderRadius: '8px',
          padding: '8px 12px',
          fontSize: '13px',
          color: '#E4E9F2',
          whiteSpace: 'nowrap',
          zIndex: 1000,
          boxShadow: '0 4px 20px rgba(0, 0, 0, 0.3)',
        }}>
          {content}
        </div>
      )}
    </div>
  );
}

// ============================================================================
// MODAL COMPONENT
// ============================================================================
export function Modal({ 
  isOpen, 
  onClose, 
  title, 
  children, 
  size = 'md',
  footer,
}) {
  if (!isOpen) return null;

  const sizes = {
    sm: '400px',
    md: '560px',
    lg: '720px',
    xl: '960px',
  };

  return (
    <div style={{
      position: 'fixed',
      inset: 0,
      background: 'rgba(0, 0, 0, 0.6)',
      backdropFilter: 'blur(4px)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 1000,
      padding: '24px',
    }} onClick={onClose}>
      <div style={{
        background: '#1A2942',
        borderRadius: '20px',
        border: '1px solid rgba(255, 255, 255, 0.1)',
        width: '100%',
        maxWidth: sizes[size],
        maxHeight: '90vh',
        display: 'flex',
        flexDirection: 'column',
        animation: 'modalIn 0.3s ease',
      }} onClick={(e) => e.stopPropagation()}>
        {/* Header */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '20px 24px',
          borderBottom: '1px solid rgba(255, 255, 255, 0.06)',
        }}>
          <h3 style={{
            fontFamily: "'Plus Jakarta Sans', sans-serif",
            fontSize: '18px',
            fontWeight: 600,
            color: '#fff',
            margin: 0,
          }}>{title}</h3>
          <button 
            onClick={onClose}
            style={{
              background: 'rgba(255, 255, 255, 0.05)',
              border: 'none',
              borderRadius: '8px',
              width: '32px',
              height: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#8F9BB3',
              cursor: 'pointer',
            }}
          >
            ✕
          </button>
        </div>

        {/* Body */}
        <div style={{
          flex: 1,
          overflow: 'auto',
          padding: '24px',
        }}>
          {children}
        </div>

        {/* Footer */}
        {footer && (
          <div style={{
            display: 'flex',
            justifyContent: 'flex-end',
            gap: '12px',
            padding: '16px 24px',
            borderTop: '1px solid rgba(255, 255, 255, 0.06)',
          }}>
            {footer}
          </div>
        )}
      </div>
      <style>{`
        @keyframes modalIn {
          from {
            opacity: 0;
            transform: scale(0.95) translateY(10px);
          }
          to {
            opacity: 1;
            transform: scale(1) translateY(0);
          }
        }
      `}</style>
    </div>
  );
}

// ============================================================================
// TABS COMPONENT
// ============================================================================
export function Tabs({ tabs, activeTab, onChange }) {
  return (
    <div style={{
      display: 'flex',
      gap: '4px',
      background: '#1A2942',
      padding: '4px',
      borderRadius: '12px',
    }}>
      {tabs.map((tab) => (
        <button
          key={tab.id}
          onClick={() => onChange(tab.id)}
          style={{
            padding: '10px 20px',
            background: activeTab === tab.id ? 'rgba(0, 212, 255, 0.1)' : 'transparent',
            border: 'none',
            borderRadius: '8px',
            color: activeTab === tab.id ? '#00D4FF' : '#8F9BB3',
            fontSize: '14px',
            fontWeight: 500,
            cursor: 'pointer',
            transition: 'all 0.2s ease',
          }}
        >
          {tab.icon && <span style={{ marginRight: '8px' }}>{tab.icon}</span>}
          {tab.label}
          {tab.count !== undefined && (
            <span style={{
              marginLeft: '8px',
              background: activeTab === tab.id ? '#00D4FF' : '#243B55',
              color: activeTab === tab.id ? '#0A1628' : '#8F9BB3',
              padding: '2px 8px',
              borderRadius: '10px',
              fontSize: '11px',
              fontWeight: 600,
            }}>
              {tab.count}
            </span>
          )}
        </button>
      ))}
    </div>
  );
}

// ============================================================================
// EMPTY STATE COMPONENT
// ============================================================================
export function EmptyState({ 
  icon = '📭', 
  title, 
  description, 
  action,
}) {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '60px 20px',
      textAlign: 'center',
    }}>
      <div style={{
        fontSize: '48px',
        marginBottom: '16px',
      }}>{icon}</div>
      <h3 style={{
        fontFamily: "'Plus Jakarta Sans', sans-serif",
        fontSize: '20px',
        fontWeight: 600,
        color: '#fff',
        marginBottom: '8px',
      }}>{title}</h3>
      <p style={{
        fontSize: '14px',
        color: '#8F9BB3',
        maxWidth: '400px',
        marginBottom: '24px',
        lineHeight: 1.6,
      }}>{description}</p>
      {action}
    </div>
  );
}

// ============================================================================
// SKELETON LOADER COMPONENT
// ============================================================================
export function Skeleton({ 
  width = '100%', 
  height = '20px', 
  variant = 'text',
  count = 1,
}) {
  const baseStyle = {
    background: 'linear-gradient(90deg, #243B55 25%, #2D4A6A 50%, #243B55 75%)',
    backgroundSize: '200% 100%',
    animation: 'shimmer 1.5s infinite',
    borderRadius: variant === 'circle' ? '50%' : variant === 'card' ? '16px' : '8px',
  };

  const skeletons = Array(count).fill(null).map((_, i) => (
    <div
      key={i}
      style={{
        ...baseStyle,
        width: variant === 'circle' ? height : width,
        height,
        marginBottom: i < count - 1 ? '8px' : 0,
      }}
    />
  ));

  return (
    <>
      {skeletons}
      <style>{`
        @keyframes shimmer {
          0% { background-position: 200% 0; }
          100% { background-position: -200% 0; }
        }
      `}</style>
    </>
  );
}

export default {
  Button,
  Spinner,
  Input,
  Select,
  Badge,
  Avatar,
  Card,
  ProgressBar,
  ScoreRing,
  Tooltip,
  Modal,
  Tabs,
  EmptyState,
  Skeleton,
  colors,
};
