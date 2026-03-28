#!/bin/bash

# Update App.tsx
cat << 'INNER_EOF' > src/App.tsx
import { HashRouter, Routes, Route, Link, useLocation } from 'react-router-dom';
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
      <div style={{ fontWeight: 'bold', marginRight: 'auto', textShadow: '0 0 8px var(--primary-glow)' }}>
        DSD-S1-TEST
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
        DSD-S1-TEST<br/>
        © {new Date().getFullYear()}
      </footer>
    </HashRouter>
  );
}
INNER_EOF

# Update Progress.tsx
cat << 'INNER_EOF' > src/pages/Progress.tsx
import { useEffect, useRef, useState } from 'react';
import mermaid from 'mermaid';

const progressModule = import.meta.glob('../content/progress/*.md', { query: '?raw', import: 'default', eager: true });

export default function Progress() {
  const chartRef = useRef<HTMLPreElement>(null);
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
      <h1 style={{ margin: '0 0 1rem 0' }}>Progress</h1>
      <p style={{ color: 'var(--text-muted)', marginBottom: '2rem' }}>Project Schedule:</p>
      <div className="card" style={{ overflowX: 'auto' }}>
        <pre className="mermaid" ref={chartRef}>
          {chartDef}
        </pre>
      </div>
    </div>
  );
}
INNER_EOF

# Update NewsList.tsx
cat << 'INNER_EOF' > src/pages/NewsList.tsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { parseFrontMatter, type NewsAttributes } from '../utils/mdParser';

const newsModules = import.meta.glob('../content/news/*.md', { query: '?raw', import: 'default', eager: true });

export default function NewsList() {
  const navigate = useNavigate();
  const [list, setList] = useState<Array<NewsAttributes & { id: string }>>([]);

  useEffect(() => {
    const loaded = Object.entries(newsModules).map(([path, content]) => {
      const id = path.split('/').pop()?.replace('.md', '') || '';
      const parsed = parseFrontMatter<NewsAttributes>(content as string);
      return { id, ...parsed.attributes };
    });
    setList(loaded.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime()));
  }, []);

  return (
    <div>
      <h1 style={{ margin: '0 0 1rem 0' }}>News</h1>
      <p style={{ color: 'var(--text-muted)', marginBottom: '2rem' }}>Latest Project Updates:</p>
      {list.map(item => (
        <div key={item.id} className="card hoverable" onClick={() => navigate(`/news/${item.id}`)} style={{ cursor: 'pointer' }}>
          <div className="cyber-font" style={{ fontSize: '0.8em', color: 'var(--text-muted)', marginBottom: '0.5rem' }}>
            DATE: {item.date} | AUTHOR: {item.author}
          </div>
          <h2 style={{ margin: '0 0 1rem 0' }}>{item.title}</h2>
          <p style={{ color: 'var(--text-muted)' }}>{item.summary}</p>
          <div style={{ color: 'var(--primary-glow)', fontSize: '0.9em', marginTop: '1rem' }}>
            [ Read More ]
          </div>
        </div>
      ))}
    </div>
  );
}
INNER_EOF

# Update NewsDetail.tsx
cat << 'INNER_EOF' > src/pages/NewsDetail.tsx
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { parseFrontMatter, type NewsAttributes } from '../utils/mdParser';

const newsModules = import.meta.glob('../content/news/*.md', { query: '?raw', import: 'default', eager: false });

export default function NewsDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [content, setContent] = useState('');

  useEffect(() => {
    const loadContent = async () => {
      const path = `../content/news/${id}.md`;
      if (newsModules[path]) {
        const raw = await newsModules[path]() as string;
        const parsed = parseFrontMatter<NewsAttributes>(raw);
        setContent(parsed.body);
      } else {
        setContent('# 404 NOT FOUND');
      }
    };
    loadContent();
  }, [id]);

  return (
    <div>
      <button className="btn" onClick={() => navigate('/news')} style={{ marginBottom: '2rem' }}>
        &lt; Back to News
      </button>
      <div className="card markdown-body" style={{ animation: 'flicker 1s forwards' }}>
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{content}</ReactMarkdown>
      </div>
    </div>
  );
}
INNER_EOF

# Update MemberList.tsx
cat << 'INNER_EOF' > src/pages/MemberList.tsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { parseFrontMatter, type MemberAttributes } from '../utils/mdParser';

const memberModules = import.meta.glob('../content/members/*.md', { query: '?raw', import: 'default', eager: true });

export default function MemberList() {
  const navigate = useNavigate();
  const [list, setList] = useState<Array<MemberAttributes & { id: string }>>([]);

  useEffect(() => {
    const loaded = Object.entries(memberModules).map(([path, content]) => {
      const id = path.split('/').pop()?.replace('.md', '') || '';
      const parsed = parseFrontMatter<MemberAttributes>(content as string);
      return { id, ...parsed.attributes };
    });
    setList(loaded);
  }, []);

  return (
    <div>
      <h1 style={{ margin: '0 0 1rem 0' }}>Members</h1>
      <p style={{ color: 'var(--text-muted)', marginBottom: '2rem' }}>Team Directory:</p>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '1.5rem' }}>
        {list.map(member => (
          <div key={member.id} className="card hoverable" onClick={() => navigate(`/members/${member.id}`)} style={{ cursor: 'pointer', textAlign: 'center' }}>
            <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>{member.avatar}</div>
            <h2 style={{ margin: '0 0 0.5rem 0' }}>{member.name}</h2>
            <div style={{ color: 'var(--secondary-glow)', fontSize: '0.9em', marginBottom: '1rem' }}>
              {member.role}
            </div>
            <div style={{ color: 'var(--primary-glow)', fontSize: '0.8em' }}>
              [ View Profile ]
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
INNER_EOF

# Update MemberDetail.tsx
cat << 'INNER_EOF' > src/pages/MemberDetail.tsx
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { parseFrontMatter, type MemberAttributes } from '../utils/mdParser';

const memberModules = import.meta.glob('../content/members/*.md', { query: '?raw', import: 'default', eager: false });

export default function MemberDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [meta, setMeta] = useState<MemberAttributes | null>(null);
  const [content, setContent] = useState('');

  useEffect(() => {
    const loadContent = async () => {
      const path = `../content/members/${id}.md`;
      if (memberModules[path]) {
        const raw = await memberModules[path]() as string;
        const parsed = parseFrontMatter<MemberAttributes>(raw);
        setMeta(parsed.attributes);
        setContent(parsed.body);
      } else {
        setContent('# 404 RECORD NOT FOUND');
      }
    };
    loadContent();
  }, [id]);

  return (
    <div>
      <button className="btn" onClick={() => navigate('/members')} style={{ marginBottom: '2rem' }}>
        &lt; Back to Members
      </button>
      <div className="card markdown-body" style={{ animation: 'flicker 1s forwards' }}>
        {meta && (
          <div style={{ borderBottom: '1px solid rgba(255,255,255,0.1)', paddingBottom: '1rem', marginBottom: '1rem', display: 'flex', gap: '2rem', alignItems: 'center' }}>
             <div style={{ fontSize: '5rem' }}>{meta.avatar}</div>
             <div>
               <h1 style={{ border: 'none', margin: 0 }}>{meta.name}</h1>
               <div style={{ color: 'var(--secondary-glow)', marginTop: '0.5rem' }}>Role: {meta.role}</div>
               <div style={{ color: 'var(--text-muted)', marginTop: '0.5rem' }}>Skills: {meta.skills}</div>
             </div>
          </div>
        )}
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{content}</ReactMarkdown>
      </div>
    </div>
  );
}
INNER_EOF

# Update Markdown Contents
cat << 'INNER_EOF' > src/content/home/index.md
# DSD-S1-TEST Frontend

Welcome to the **DSD-S1-TEST** development hub.
This site is powered by static Markdown files for efficient collaboration.

## Core Features
- 🚀 **Static Generation**: Vite + React for ultimate speed.
- 📝 **Markdown Driven**: Organization members simply submit \`.md\` files to publish news or update progress.
- 📊 **Diagrams as Code**: Built-in Mermaid parser for easy Gantt chart rendering.
- 🤖 **Automated Deployment**: One-click push triggers GitHub Actions for serverless deployment.

## Navigation Guide
Use the top navigation bar to explore the data archives:
* \`[News]\` - Project announcements and update logs.
* \`[Progress]\` - Visualized progress charts of the architecture.
* \`[Members]\` - Profiles and roles of the development team.
INNER_EOF

cat << 'INNER_EOF' > src/content/progress/gantt.md
gantt
    title DSD-S1-TEST Development Schedule
    dateFormat  YYYY-MM-DD
    axisFormat  %m-%d

    section Phase 1: Infrastructure
    Tech Stack Planning       :done,    task1, 2026-03-25, 2026-03-26
    Static Server & Routing   :done,    task2, 2026-03-27, 2d
    Tech UI Refactoring       :active,  task3, 2026-03-29, 2d
    Markdown Parsing Engine   :         task4, after task3, 3d

    section Phase 2: Features
    CI/CD Pipeline            :         task5, 2026-04-02, 3d
    Testing & Integration     :         task6, after task5, 4d
INNER_EOF

cat << 'INNER_EOF' > src/content/news/2026-03-28-init.md
---
title: "Development Hub V1.0 Initialized"
date: "2026-03-28"
author: "Admin"
summary: "We have launched the new tech-themed architecture and the automated Markdown build system."
---

# Development Hub V1.0 Initialized

Today, the DSD-S1-TEST frontend system has undergone a major refactoring.

To ensure that all members can effortlessly update the website without touching complex frontend code, we migrated the entire content library to the \`src/content/\` directory.

## Update Guide
1. **Add News**: Create a new \`.md\` file in \`src/content/news/\` and fill in the Frontmatter info like Title.
2. **Update Gantt**: Modify \`src/content/progress/gantt.md\`.
3. **Add Member Profile**: Add a new file in \`src/content/members/\`.

Enjoy the seamless experience.
INNER_EOF

cat << 'INNER_EOF' > src/content/members/alice.md
---
name: "Alice"
role: "Frontend Engineer / UI Design"
avatar: "👩‍💻"
skills: "React, Tailwind, CSS Animation"
---
# Alice Profile

Responsible for the visual experience and interaction design of DSD-S1-TEST.
Transforming mundane code into a sleek console interface.
INNER_EOF

cat << 'INNER_EOF' > src/content/members/bob.md
---
name: "Bob"
role: "System Architecture / DevOps"
avatar: "👨‍🔧"
skills: "GitHub Actions, Node.js, Vite"
---
# Bob Profile

Focused on process automation and engineering infrastructure.
Maintaining the lifeblood and systems of this project.
INNER_EOF

