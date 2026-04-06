import { Link } from 'react-router-dom';
import { parseFrontMatter } from '../utils/mdParser';
import type { ReleaseAttributes } from '../utils/mdParser';

// Dynamic import of all release markdown files
const releaseFiles = import.meta.glob('../content/releases/*.md', { query: '?raw', import: 'default', eager: true });

export default function ReleaseList() {
  const releases = Object.entries(releaseFiles).map(([path, content]) => {
    const id = path.split('/').pop()?.replace('.md', '') || '';
    const parsed = parseFrontMatter<ReleaseAttributes>(content as string);
    return { id, ...parsed.attributes };
  }).sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

  return (
    <div>
      <h1 style={{ margin: '0 0 1.5rem 0' }}>交付发布 (Releases)</h1>
      <p style={{ color: 'var(--text-muted)', marginBottom: '2rem' }}>Team delivery history & resources.</p>
      
      <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
        {releases.map(release => (
          <div key={release.id} className="card" style={{ display: 'block', padding: '1.5rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '1rem' }}>
              <h2 style={{ margin: 0, fontSize: '1.25rem', color: 'var(--primary-glow)' }}>{release.title}</h2>
              <span style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>{release.date}</span>
            </div>
            <p style={{ marginBottom: '1rem', color: 'var(--text-color)' }}>{release.summary}</p>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '0.875rem', color: '#ff003c' }}>Publisher: {release.publisher}</span>
              <Link to={`/releases/${release.id}`} style={{ color: 'var(--primary-color)', textDecoration: 'none', borderBottom: '1px dashed var(--primary-color)' }}>
                [ Read More / 下载附件 ]
              </Link>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
