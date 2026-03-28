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
