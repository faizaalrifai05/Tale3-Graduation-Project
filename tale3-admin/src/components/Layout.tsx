import { Outlet, NavLink, useNavigate } from 'react-router-dom'
import { auth } from '../firebase/config'
import { signOut } from 'firebase/auth'

const navItems = [
  { path: '/', label: 'Dashboard', icon: '📊' },
  { path: '/users', label: 'User Management', icon: '👥' },
  { path: '/rides', label: 'Rides', icon: '🚗' },
  { path: '/pricing', label: 'Pricing', icon: '💰' },
  { path: '/verification', label: 'Verification', icon: '✅' },
]

export default function Layout() {
  const navigate = useNavigate()

  const handleLogout = async () => {
    await signOut(auth)
    navigate('/login')
  }

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <aside className="w-64 bg-white border-r border-gray-200 flex flex-col">
        <div className="p-6 border-b border-gray-200">
          <h1 className="text-xl font-bold text-primary">Tale3 Admin</h1>
          <p className="text-xs text-gray-500 mt-1">The Digital Curator</p>
        </div>

        <nav className="flex-1 p-4 space-y-1">
          {navItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.path === '/'}
              className={({ isActive }) =>
                `flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-primary-light text-primary'
                    : 'text-gray-600 hover:bg-gray-100'
                }`
              }
            >
              <span>{item.icon}</span>
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="p-4 border-t border-gray-200">
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium text-gray-600 hover:bg-gray-100 transition-colors"
          >
            <span>🚪</span>
            Logout
          </button>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 overflow-auto">
        <Outlet />
      </main>
    </div>
  )
}