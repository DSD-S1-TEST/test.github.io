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
