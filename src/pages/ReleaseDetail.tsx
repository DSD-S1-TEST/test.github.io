import { useParams, Link } from 'react-router-dom';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { parseFrontMatter } from '../utils/mdParser';
import type { ReleaseAttributes } from '../utils/mdParser';

const releaseFiles = import.meta.glob('../content/releases/*.md', { query: '?raw', import: 'default', eager: true });

export default function ReleaseDetail() {
  const { id } = useParams();
  const filePath = `../content/releases/${id}.md`;
  const fileContent = releaseFiles[filePath] as string;

  if (!fileContent) {
    return <div style={{ textAlign: 'center', padding: '4rem' }}><h2>404 - Release Not Found</h2><Link to="/releases">Back to Releases</Link></div>;
  }

  const { attributes, body } = parseFrontMatter<ReleaseAttributes>(fileContent);

  return (
    <div className="card">
      <Link to="/releases" style={{ display: 'inline-block', marginBottom: '2rem', color: 'var(--text-muted)' }}>
        ← 返回发布列表 (Back to Releases)
      </Link>
      
      <h1 style={{ color: 'var(--primary-glow)', marginBottom: '0.5rem' }}>{attributes.title}</h1>
      
      <div style={{ display: 'flex', gap: '2rem', color: 'var(--text-muted)', fontSize: '0.9rem', marginBottom: '1.5rem', borderBottom: '1px solid rgba(0, 240, 255, 0.2)', paddingBottom: '1rem' }}>
        <span>📅 Date: {attributes.date}</span>
        <span style={{ color: '#ff003c' }}>👤 Publisher: {attributes.publisher}</span>
      </div>

      {/* 条件渲染 附件按钮 */}
      {(attributes.pdf_url || attributes.github_url) && (
        <div style={{ padding: '1rem', background: 'rgba(0, 240, 255, 0.05)', borderRadius: '4px', marginBottom: '2rem', display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
          {attributes.pdf_url && (
            <a href={attributes.pdf_url} download style={{ display: 'inline-block', padding: '0.5rem 1rem', background: 'rgba(0, 240, 255, 0.1)', border: '1px solid var(--primary-glow)', color: 'var(--primary-glow)', textDecoration: 'none', borderRadius: '4px' }}>
              📥 下载 PDF 报告 / Download PDF
            </a>
          )}
          
          {attributes.github_url && (
            <a href={attributes.github_url} target="_blank" rel="noopener noreferrer" style={{ display: 'inline-block', padding: '0.5rem 1rem', background: 'rgba(255, 0, 60, 0.1)', border: '1px solid rgba(255, 0, 60, 0.5)', color: '#ff003c', textDecoration: 'none', borderRadius: '4px' }}>
              🐙 前往 GitHub 仓库 / GitHub Repo
            </a>
          )}
        </div>
      )}

      <div style={{ lineHeight: '1.6' }}>
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{body}</ReactMarkdown>
      </div>
    </div>
  );
}
