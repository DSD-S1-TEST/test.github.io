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
