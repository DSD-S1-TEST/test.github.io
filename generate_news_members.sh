#!/bin/bash
cat << 'INNER_EOF' > src/pages/NewsList.tsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { parseFrontMatter, NewsAttributes } from '../utils/mdParser';

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
      <h1 className="cyber-font" style={{ color: 'var(--primary-glow)' }}>&gt; SYSTEM.NEWS_</h1>
      <p style={{ color: 'var(--text-muted)' }}>已截获的系统通信：</p>
      {list.map(item => (
        <div key={item.id} className="card hoverable" onClick={() => navigate(`/news/${item.id}`)} style={{ cursor: 'pointer' }}>
          <div className="cyber-font" style={{ fontSize: '0.8em', color: 'var(--text-muted)', marginBottom: '0.5rem' }}>
            DATE: {item.date} | AUTHOR: {item.author}
          </div>
          <h2 style={{ margin: '0 0 1rem 0' }}>{item.title}</h2>
          <p style={{ color: 'var(--text-muted)' }}>{item.summary}</p>
          <div className="cyber-font" style={{ color: 'var(--primary-glow)', fontSize: '0.9em', marginTop: '1rem' }}>
            [ 点击查阅详细记录 ]
          </div>
        </div>
      ))}
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > src/pages/NewsDetail.tsx
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { parseFrontMatter, NewsAttributes } from '../utils/mdParser';

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
      <h1 className="cyber-font" style={{ color: 'var(--primary-glow)' }}>&gt; ROOT/NEWS/{id}.md</h1>
      <button className="btn" onClick={() => navigate('/news')} style={{ marginBottom: '1rem' }}>
        &lt; 返回上一级
      </button>
      <div className="card markdown-body" style={{ animation: 'flicker 1s forwards' }}>
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{content}</ReactMarkdown>
      </div>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > src/pages/MemberList.tsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { parseFrontMatter, MemberAttributes } from '../utils/mdParser';

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
      <h1 className="cyber-font" style={{ color: 'var(--primary-glow)' }}>&gt; SYSTEM.MEMBERS_</h1>
      <p style={{ color: 'var(--text-muted)' }}>检索系统内的人员档案：</p>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '1.5rem' }}>
        {list.map(member => (
          <div key={member.id} className="card hoverable" onClick={() => navigate(`/members/${member.id}`)} style={{ cursor: 'pointer', textAlign: 'center' }}>
            <div style={{ fontSize: '4rem', marginBottom: '1rem' }}>{member.avatar}</div>
            <h2 style={{ margin: '0 0 0.5rem 0' }}>{member.name}</h2>
            <div className="cyber-font" style={{ color: 'var(--secondary-glow)', fontSize: '0.9em', marginBottom: '1rem' }}>
              {member.role}
            </div>
            <div className="cyber-font" style={{ color: 'var(--primary-glow)', fontSize: '0.8em' }}>
              [ 查询解密档案 ]
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
INNER_EOF

cat << 'INNER_EOF' > src/pages/MemberDetail.tsx
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { parseFrontMatter, MemberAttributes } from '../utils/mdParser';

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
      <h1 className="cyber-font" style={{ color: 'var(--primary-glow)' }}>&gt; RECORDS/MEMBER_{id}_</h1>
      <button className="btn" onClick={() => navigate('/members')} style={{ marginBottom: '1rem' }}>
        &lt; 返回人员列表
      </button>
      <div className="card markdown-body" style={{ animation: 'flicker 1s forwards' }}>
        {meta && (
          <div style={{ borderBottom: '1px solid rgba(255,255,255,0.1)', paddingBottom: '1rem', marginBottom: '1rem', display: 'flex', gap: '2rem', alignItems: 'center' }}>
             <div style={{ fontSize: '5rem' }}>{meta.avatar}</div>
             <div>
               <h1 style={{ border: 'none', margin: 0 }}>{meta.name}</h1>
               <div className="cyber-font" style={{ color: 'var(--secondary-glow)', marginTop: '0.5rem' }}>职位：{meta.role}</div>
               <div className="cyber-font" style={{ color: 'var(--text-muted)', marginTop: '0.5rem' }}>技能：{meta.skills}</div>
             </div>
          </div>
        )}
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{content}</ReactMarkdown>
      </div>
    </div>
  );
}
INNER_EOF

