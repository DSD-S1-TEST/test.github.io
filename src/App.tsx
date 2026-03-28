import { HashRouter, Routes, Route, Link, useLocation } from 'react-router-dom';
import Home from './pages/Home';
import Progress from './pages/Progress';
import NewsList from './pages/NewsList';
import NewsDetail from './pages/NewsDetail';
import MemberList from './pages/MemberList';
import MemberDetail from './pages/MemberDetail';
import './index.css';

function Navbar() {
  const location = useLocation();
  const isActive = (path: string) => location.pathname === path || (path !== '/' && location.pathname.startsWith(path)) ? 'active' : '';

  return (
    <nav style={{
      display: 'flex', gap: '2rem', padding: '1.5rem 2rem',
      borderBottom: '1px solid rgba(0, 240, 255, 0.2)',
      background: 'rgba(5, 7, 12, 0.8)',
      backdropFilter: 'blur(10px)',
      boxShadow: '0 4px 30px rgba(0,0,0,0.5)',
      position: 'sticky', top: 0, zIndex: 100
    }} className="cyber-font">
      <div style={{ fontWeight: 'bold', marginRight: 'auto', textShadow: '0 0 8px var(--primary-glow)' }}>
        DSD-TEAM-S1
      </div>
      <Link className={`nav-link ${isActive('/')}`} to="/">[ HOME ]</Link>
      <Link className={`nav-link ${isActive('/progress')}`} to="/progress">[ PROGRESS ]</Link>
      <Link className={`nav-link ${isActive('/news')}`} to="/news">[ NEWS ]</Link>
      <Link className={`nav-link ${isActive('/members')}`} to="/members">[ MEMBERS ]</Link>
    </nav>
  );
}

export default function App() {
  return (
    <HashRouter>
      <Navbar />
      <div style={{ maxWidth: '900px', margin: '2rem auto', padding: '0 1rem', minHeight: '80vh' }}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/progress" element={<Progress />} />
          <Route path="/news" element={<NewsList />} />
          <Route path="/news/:id" element={<NewsDetail />} />
          <Route path="/members" element={<MemberList />} />
          <Route path="/members/:id" element={<MemberDetail />} />
        </Routes>
      </div>
      <footer style={{ textAlign: 'center', padding: '2rem', borderTop: '1px solid rgba(0, 240, 255, 0.2)', color: 'var(--text-muted)' }} className="cyber-font">
        DSD-TEAM-S1<br/>
        © {new Date().getFullYear()}
      </footer>
    </HashRouter>
  );
}
