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
      <h1 style={{ margin: '0 0 1.5rem 0' }}>Releases</h1>
      <p style={{ color: 'var(--text-muted)', marginBottom: '2rem' }}>Team delivery history & resources.</p>
      
      <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
        {releases.map(release => (
          <Link key={release.id} to={`/releases/${release.id}`} className="card hoverable" style={{ display: 'block', padding: '1.5rem', textDecoration: 'none', color: 'inherit', cursor: 'pointer' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '1rem' }}>
              <h2 style={{ margin: 0, fontSize: '1.25rem', color: 'var(--primary-glow)', display: 'flex', alignItems: 'center', gap: '10px' }}>
                {release.title}
                {release.latest && (
                  <span style={{ 
                    fontSize: '0.6em', 
                    backgroundColor: '#ff003c', 
                    color: '#fff', 
                    padding: '2px 6px', 
                    borderRadius: '4px',
                    fontWeight: 'bold',
                    textShadow: 'none'
                  }}>
                    LATEST
                  </span>
                )}
              </h2>
              <span style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>{release.date}</span>
            </div>
            <p style={{ marginBottom: '1rem', color: 'var(--text-color)' }}>{release.summary}</p>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '0.875rem', color: '#ff003c' }}>Publisher: {release.publisher}</span>
              <span style={{ color: 'var(--primary-glow)', borderBottom: '1px dashed var(--primary-glow)' }}>
                [ Read More ]
              </span>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
