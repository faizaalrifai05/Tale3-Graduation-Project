import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { onAuthStateChanged } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from './firebase/config';
import Login from './pages/Login';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import UserManagement from './pages/UserManagement';
import Rides from './pages/Rides';
import Pricing from './pages/Pricing';
import Verification from './pages/Verification';

function App() {
  const [isAdmin, setIsAdmin] = useState<boolean | null>(null);

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, async (user) => {
      if (user) {
        const snap = await getDoc(doc(db, 'users', user.uid));
        const data = snap.data();
        setIsAdmin(data?.role === 'admin');
      } else {
        setIsAdmin(false);
      }
    });
    return () => unsub();
  }, []);

  if (isAdmin === null) return (
    <div className="flex items-center justify-center h-screen bg-primary-light">
      <p className="text-primary font-bold text-xl">Loading...</p>
    </div>
  );

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={!isAdmin ? <Login /> : <Navigate to="/" />} />
        <Route path="/" element={isAdmin ? <Layout /> : <Navigate to="/login" />}>
          <Route index element={<Dashboard />} />
          <Route path="users" element={<UserManagement />} />
          <Route path="rides" element={<Rides />} />
          <Route path="pricing" element={<Pricing />} />
          <Route path="verification" element={<Verification />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;