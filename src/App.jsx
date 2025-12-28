import React, { useState, useEffect } from 'react';
import Dashboard from './pages/Dashboard';
import Landing from './pages/Landing';

// ============================================================================
// TALENTFORGE - MAIN APPLICATION
// ============================================================================

export default function App() {
  const [view, setView] = useState('landing'); // 'landing' or 'app'
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  // Check authentication status on mount
  useEffect(() => {
    const token = localStorage.getItem('talentforge_token');
    if (token) {
      setIsAuthenticated(true);
      setView('app');
    }
  }, []);

  // Handle login
  const handleLogin = () => {
    // Simulated login - replace with actual auth
    localStorage.setItem('talentforge_token', 'demo_token');
    setIsAuthenticated(true);
    setView('app');
  };

  // Handle logout
  const handleLogout = () => {
    localStorage.removeItem('talentforge_token');
    setIsAuthenticated(false);
    setView('landing');
  };

  return (
    <div className="talentforge-app">
      {view === 'landing' ? (
        <Landing onGetStarted={handleLogin} />
      ) : (
        <Dashboard onLogout={handleLogout} />
      )}
    </div>
  );
}

// For React Router setup (alternative)
// ============================================================================
/*
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';

export default function AppWithRouter() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Landing />} />
        <Route 
          path="/dashboard/*" 
          element={
            isAuthenticated ? <Dashboard /> : <Navigate to="/" replace />
          } 
        />
        <Route path="/login" element={<Login onLogin={setIsAuthenticated} />} />
        <Route path="/signup" element={<Signup onSignup={setIsAuthenticated} />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
*/
