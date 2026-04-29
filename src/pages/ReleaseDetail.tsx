import { useParams, Link } from 'react-router-dom';
import { useEffect, useRef } from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import mermaid from 'mermaid';
import { parseFrontMatter } from '../utils/mdParser';
import type { ReleaseAttributes } from '../utils/mdParser';

const releaseFiles = import.meta.glob('../content/releases/*.md', { query: '?raw', import: 'default', eager: true });

const Mermaid = ({ chart }: { chart: string }) => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    mermaid.initialize({ startOnLoad: false, theme: 'dark', securityLevel: 'loose' });
    if (containerRef.current) {
      const id = `mermaid-${Math.random().toString(36).substr(2, 9)}`;
      mermaid.render(id, chart).then(({ svg }) => {
        if (containerRef.current) {
          containerRef.current.innerHTML = svg;
        }
      }).catch(e => {
        console.error("Mermaid rendering error:", e);
      });
    }
  }, [chart]);

  return <div ref={containerRef} className="mermaid-container" style={{ display: 'flex', justifyContent: 'center', margin: '2rem 0' }} />;
};

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
        ← (Back to Releases)
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
              📥 Download PDF
            </a>
          )}
          
          {attributes.github_url && (
            <a href={attributes.github_url} target="_blank" rel="noopener noreferrer" style={{ display: 'inline-block', padding: '0.5rem 1rem', background: 'rgba(255, 0, 60, 0.1)', border: '1px solid rgba(255, 0, 60, 0.5)', color: '#ff003c', textDecoration: 'none', borderRadius: '4px' }}>
              🐙 GitHub Repo
            </a>
          )}
        </div>
      )}

      <div style={{ lineHeight: '1.6' }}>
        <ReactMarkdown 
          remarkPlugins={[remarkGfm]}
          components={{
            a(props) {
              const { node, href, children, ...rest } = props;
              if (href && href.endsWith('.md')) {
                return <a href={href} download {...rest}>{children}</a>;
              }
              return <a href={href} {...rest}>{children}</a>;
            },
            code({ node, className, children, ...props }: any) {
              const match = /language-(\w+)/.exec(className || '');
              if (match && match[1] === 'mermaid') {
                return <Mermaid chart={String(children).replace(/\n$/, '')} />;
              }
              return <code className={className} {...props}>{children}</code>;
            }
          }}
        >
          {body}
        </ReactMarkdown>
      </div>
    </div>
  );
}
