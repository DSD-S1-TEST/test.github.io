#!/bin/bash
cat << 'INNER_EOF' > src/index.css
:root {
  --bg-color: #0b0f19;
  --panel-bg: rgba(11, 15, 25, 0.6);
  --primary-glow: #00f0ff;
  --secondary-glow: #ff003c;
  --text-main: #e2e8f0;
  --text-muted: #8b949e;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  background-color: var(--bg-color);
  color: var(--text-main);
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  background-image: 
    linear-gradient(rgba(0, 240, 255, 0.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 240, 255, 0.05) 1px, transparent 1px);
  background-size: 30px 30px;
}

code, .cyber-font {
  font-family: 'JetBrains Mono', 'Fira Code', Consolas, monospace;
}

.nav-link {
  color: var(--text-muted);
  text-decoration: none;
  font-weight: bold;
  padding: 0.5rem 1rem;
  transition: all 0.3s;
}

.nav-link:hover, .nav-link.active {
  color: var(--primary-glow);
  text-shadow: 0 0 8px var(--primary-glow);
}

.card {
  background: var(--panel-bg);
  border: 1px solid rgba(0, 240, 255, 0.2);
  border-radius: 4px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.card::before {
  content: '';
  position: absolute;
  top: 0; left: 0;
  width: 4px; height: 100%;
  background: var(--primary-glow);
  box-shadow: 0 0 10px var(--primary-glow);
  opacity: 0;
  transition: opacity 0.3s;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 20px rgba(0, 240, 255, 0.1);
  border-color: rgba(0, 240, 255, 0.5);
}

.card.hoverable:hover::before {
  opacity: 1;
}

.markdown-body {
  line-height: 1.6;
}

.markdown-body h1, .markdown-body h2, .markdown-body h3 {
  color: #fff;
  border-bottom: 1px solid rgba(255,255,255,0.1);
  padding-bottom: 0.3em;
}

.markdown-body code {
  background: rgba(0, 240, 255, 0.1);
  padding: 0.2em 0.4em;
  border-radius: 3px;
  color: var(--primary-glow);
}

.btn {
  display: inline-block;
  background: transparent;
  color: var(--primary-glow);
  border: 1px solid var(--primary-glow);
  padding: 0.5rem 1rem;
  text-decoration: none;
  font-family: monospace;
  text-transform: uppercase;
  cursor: pointer;
  transition: all 0.2s;
}

.btn:hover {
  background: var(--primary-glow);
  color: var(--bg-color);
  box-shadow: 0 0 15px var(--primary-glow);
}

/* CRT CRT-Flicker */
.crt-flicker {
  animation: flicker 0.15s infinite;
}
@keyframes flicker {
  0% { opacity: 0.95; }
  50% { opacity: 1; }
  100% { opacity: 0.9; }
}
INNER_EOF

cat << 'INNER_EOF' > src/App.tsx
import { HashRouter, Routes, Route, Link, useLocation } from 'react-router-dom';
import { useEffect } from 'react';
import Home from './pages/Home';
import Progress from './pages/Progress';
import NewsList from './pages/NewsList';
import NewsDetail from './pages/NewsDetail';
import MemberList from './pages/MemberList';
import MemberDetail from './pages/MemberDetail';
import './index.css';

function Navbar() {
  const location = useLocation();
  const isActive = (path: string) => location.pathname === path || (path !== '/' && location.pathname.startsWith(path)) ? 'active' : '';

  return (
    <nav style={{
      display: 'flex', gap: '2rem', padding: '1.5rem 2rem',
      borderBottom: '1px solid rgba(0, 240, 255, 0.2)',
      background: 'rgba(5, 7, 12, 0.8)',
      backdropFilter: 'blur(10px)',
      boxShadow: '0 4px 30px rgba(0,0,0,0.5)',
      position: 'sticky', top: 0, zIndex: 100
    }} className="cyber-font">
      <div style={{ color: 'var(--primary-glow)', fontWeight: 'bold', marginRight: 'auto', textShadow: '0 0 8px var(--primary-glow)' }}>
        SYS_OS // ONLINE
      </div>
      <Link className={`nav-link ${isActive('/')}`} to="/">[ HOME ]</Link>
      <Link className={`nav-link ${isActive('/progress')}`} to="/progress">[ PROGRESS ]</Link>
      <Link className={`nav-link ${isActive('/news')}`} to="/news">[ NEWS ]</Link>
      <Link className={`nav-link ${isActive('/members')}`} to="/members">[ MEMBERS ]</Link>
    </nav>
  );
}

export default function App() {
  return (
    <HashRouter>
      <Navbar />
      <div style={{ maxWidth: '900px', margin: '2rem auto', padding: '0 1rem', minHeight: '80vh' }}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/progress" element={<Progress />} />
          <Route path="/news" element={<NewsList />} />
          <Route path="/news/:id" element={<NewsDetail />} />
          <Route path="/members" element={<MemberList />} />
          <Route path="/members/:id" element={<MemberDetail />} />
        </Routes>
      </div>
      <footer style={{ textAlign: 'center', padding: '2rem', borderTop: '1px solid rgba(0, 240, 255, 0.2)', color: 'var(--text-muted)' }} className="cyber-font">
        DSD-S1-TEST // SECURE TERMINAL<br/>
        © {new Date().getFullYear()} ORGANIZATION
      </footer>
    </HashRouter>
  );
}
INNER_EOF

mkdir -p src/pages

cat << 'INNER_EOF' > src/pages/Home.tsx
import { useState, useEffect } from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';

const homeModule = import.meta.glob('../content/home/index.md', { query: '?raw', import: 'default', eager: true });

export default function Home() {
  const [content, setContent] = useState('');

  useEffect(() => {
    const rawContent = Object.values(homeModule)[0] as string;
    setContent(rawContent || '# SYSTEM ERROR: NO HOME CONTENT');
  }, []);

  return (
    <div className="card markdown-body" style={{ animation: 'flicker 2s forwards' }}>
      <ReactMarkdown remarkPlugins={[remarkGfm]}>{content}</ReactMarkdown>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > src/pages/Progress.tsx
import { useEffect, useRef, useState } from 'react';
import mermaid from 'mermaid';

const progressModule = import.meta.glob('../content/progress/*.md', { query: '?raw', import: 'default', eager: true });

export default function Progress() {
  const chartRef = useRef<HTMLDivElement>(null);
  const [chartDef, setChartDef] = useState('');

  useEffect(() => {
    const rawContent = Object.values(progressModule)[0] as string;
    setChartDef(rawContent || 'gantt\n title NO DATA');
    
    mermaid.initialize({
      startOnLoad: true,
      theme: 'dark',
      themeVariables: {
        primaryColor: '#00f0ff',
        primaryTextColor: '#fff',
        primaryBorderColor: '#00f0ff',
        lineColor: '#ff003c',
        secondaryColor: '#1a1f2e',
        tertiaryColor: '#1a1f2e'
      }
    });
  }, []);

  useEffect(() => {
    if (chartRef.current && chartDef) {
       mermaid.contentLoaded();
    }
  }, [chartDef]);

  return (
    <div>
      <h1 className="cyber-font" style={{ color: 'var(--primary-glow)' }}>&gt; SYSTEM.PROGRESS_</h1>
      <p style={{ color: 'var(--text-muted)' }}>任务调度甘特图面板：</p>
      <div className="card" style={{ overflowX: 'auto' }}>
        <pre className="mermaid" ref={chartRef}>
          {chartDef}
        </pre>
      </div>
    </div>
  );
}
INNER_EOF

