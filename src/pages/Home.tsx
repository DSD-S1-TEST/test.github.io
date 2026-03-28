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
