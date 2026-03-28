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
