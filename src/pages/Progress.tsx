import { useEffect, useRef, useState } from 'react';
import mermaid from 'mermaid';

const progressModule = import.meta.glob('../content/progress/*.md', { query: '?raw', import: 'default', eager: true });

export default function Progress() {
  const chartRef = useRef<HTMLPreElement>(null);
  const [chartDef, setChartDef] = useState('');

  useEffect(() => {
    const rawContent = Object.values(progressModule)[0] as string;
    setChartDef(rawContent || 'gantt\n title NO DATA');
    
    mermaid.initialize({
      startOnLoad: true,
      theme: 'dark',
      themeVariables: {
        primaryColor: '#00f0ff',
        primaryTextColor: '#fff',
        primaryBorderColor: '#00f0ff',
        lineColor: '#ff003c',
        secondaryColor: '#1a1f2e',
        tertiaryColor: '#1a1f2e'
      }
    });
  }, []);

  useEffect(() => {
    if (chartRef.current && chartDef) {
       mermaid.contentLoaded();
    }
  }, [chartDef]);

  return (
    <div>
      <h1 className="cyber-font" style={{ color: 'var(--primary-glow)' }}>&gt; SYSTEM.PROGRESS_</h1>
      <p style={{ color: 'var(--text-muted)' }}>任务调度甘特图面板：</p>
      <div className="card" style={{ overflowX: 'auto' }}>
        <pre className="mermaid" ref={chartRef}>
          {chartDef}
        </pre>
      </div>
    </div>
  );
}
