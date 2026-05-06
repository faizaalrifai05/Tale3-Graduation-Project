import { useEffect, useState } from 'react'
import { collection, getDocs, doc, updateDoc } from 'firebase/firestore'
import { db } from '../firebase/config'
import { User } from '../types'

export default function UserManagement() {
  const [users, setUsers] = useState<User[]>([])
  const [filtered, setFiltered] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [tab, setTab] = useState<'all' | 'driver' | 'passenger'>('all')
  const [actionLoading, setActionLoading] = useState<string | null>(null)

  useEffect(() => {
    fetchUsers()
  }, [])

  useEffect(() => {
    let result = users
    if (tab !== 'all') result = result.filter(u => u.role === tab)
    if (search) result = result.filter(u =>
      u.name?.toLowerCase().includes(search.toLowerCase()) ||
      u.email?.toLowerCase().includes(search.toLowerCase())
    )
    setFiltered(result)
  }, [users, tab, search])

  const fetchUsers = async () => {
    setLoading(true)
    const snap = await getDocs(collection(db, 'users'))
    const data = snap.docs.map(d => ({ uid: d.id, ...d.data() } as User))
    setUsers(data)
    setLoading(false)
  }

  const toggleBlock = async (user: User) => {
    setActionLoading(user.uid)
    const newBlocked = !user.isBlocked
    await updateDoc(doc(db, 'users', user.uid), { isBlocked: newBlocked })
    setUsers(prev => prev.map(u => u.uid === user.uid ? { ...u, isBlocked: newBlocked } : u))
    setActionLoading(null)
  }

  const getRoleBadge = (role: string) => {
    switch (role) {
      case 'driver': return 'bg-blue-100 text-blue-700'
      case 'passenger': return 'bg-purple-100 text-purple-700'
      case 'admin': return 'bg-red-100 text-red-700'
      default: return 'bg-gray-100 text-gray-700'
    }
  }

  const getVerificationBadge = (status: string) => {
    switch (status) {
      case 'verified': return 'bg-green-100 text-green-700'
      case 'pending': return 'bg-yellow-100 text-yellow-700'
      case 'rejected': return 'bg-red-100 text-red-700'
      default: return 'bg-gray-100 text-gray-500'
    }
  }

  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <div className="text-primary font-semibold">Loading users...</div>
    </div>
  )

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-start justify-between mb-8">
        <div>
          <p className="text-xs text-gray-400 uppercase tracking-widest mb-1">Directory</p>
          <h1 className="text-3xl font-bold text-gray-900">User Management</h1>
          <p className="text-gray-500 mt-1">Manage roles, verify credentials, and curate the user ecosystem.</p>
        </div>
        <div className="flex gap-2">
          {(['all', 'driver', 'passenger'] as const).map(t => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`px-5 py-2 rounded-lg text-sm font-medium capitalize transition ${
                tab === t ? 'bg-primary text-white' : 'bg-white border border-gray-200 text-gray-600 hover:bg-gray-50'
              }`}
            >
              {t === 'all' ? 'All Users' : t === 'driver' ? 'Drivers Only' : 'Passengers'}
            </button>
          ))}
        </div>
      </div>

      {/* Search */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mb-6">
        <div className="flex items-center gap-4">
          <div className="flex-1 relative">
            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">🔍</span>
            <input
              type="text"
              placeholder="Search users, IDs, or emails..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
          <button
            onClick={fetchUsers}
            className="p-2.5 border border-gray-200 rounded-lg hover:bg-gray-50 transition"
            title="Refresh"
          >
            🔄
          </button>
        </div>
        <p className="text-xs text-gray-400 mt-3">Showing {filtered.length} of {users.length} users</p>
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-100">
            <tr className="text-xs text-gray-400 uppercase tracking-wide">
              <th className="text-left px-6 py-4">Identity</th>
              <th className="text-left px-6 py-4">Role</th>
              <th className="text-left px-6 py-4">Contact</th>
              <th className="text-left px-6 py-4">Verification</th>
              <th className="text-left px-6 py-4">Status</th>
              <th className="text-left px-6 py-4">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-50">
            {filtered.length === 0 ? (
              <tr>
                <td colSpan={6} className="text-center py-12 text-gray-400">No users found</td>
              </tr>
            ) : filtered.map(user => (
              <tr key={user.uid} className="hover:bg-gray-50 transition">
                <td className="px-6 py-4">
                  <div className="flex items-center gap-3">
                    {user.photoUrl ? (
                      <img src={user.photoUrl} className="w-10 h-10 rounded-full object-cover" />
                    ) : (
                      <div className="w-10 h-10 rounded-full bg-primary-light flex items-center justify-center text-primary font-bold text-sm">
                        {user.name?.charAt(0).toUpperCase() || '?'}
                      </div>
                    )}
                    <div>
                      <p className="text-sm font-semibold text-gray-900">{user.name || 'No name'}</p>
                      <p className="text-xs text-gray-400">
                        {user.createdAt?.toDate
                          ? `Joined ${new Date(user.createdAt.toDate()).toLocaleDateString('en-US', { month: 'short', year: 'numeric' })}`
                          : 'Recently joined'}
                      </p>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4">
                  <span className={`text-xs px-3 py-1 rounded-full font-medium capitalize ${getRoleBadge(user.role)}`}>
                    {user.role}
                  </span>
                </td>
                <td className="px-6 py-4 text-sm text-gray-600">{user.email}</td>
                <td className="px-6 py-4">
                  {user.role === 'driver' ? (
                    <span className={`text-xs px-3 py-1 rounded-full font-medium capitalize ${getVerificationBadge(user.verificationStatus)}`}>
                      {user.verificationStatus || 'unsubmitted'}
                    </span>
                  ) : (
                    <span className="text-xs text-gray-300">—</span>
                  )}
                </td>
                <td className="px-6 py-4">
                  <span className={`text-xs px-3 py-1 rounded-full font-medium ${
                    user.isBlocked ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'
                  }`}>
                    {user.isBlocked ? 'Blocked' : 'Active'}
                  </span>
                </td>
                <td className="px-6 py-4">
                  <button
                    onClick={() => toggleBlock(user)}
                    disabled={actionLoading === user.uid || user.role === 'admin'}
                    className={`text-xs px-4 py-2 rounded-lg font-medium transition disabled:opacity-40 ${
                      user.isBlocked
                        ? 'bg-green-50 text-green-700 hover:bg-green-100'
                        : 'bg-red-50 text-red-700 hover:bg-red-100'
                    }`}
                  >
                    {actionLoading === user.uid ? '...' : user.isBlocked ? 'Unblock' : 'Block'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* Bottom stats */}
        <div className="border-t border-gray-100 px-6 py-4 grid grid-cols-3 gap-4">
          <div className="bg-primary rounded-xl p-4 text-white">
            <p className="text-xs text-red-200 uppercase tracking-wide">Total Drivers</p>
            <p className="text-2xl font-bold mt-1">{users.filter(u => u.role === 'driver').length}</p>
          </div>
          <div className="bg-gray-800 rounded-xl p-4 text-white">
            <p className="text-xs text-gray-400 uppercase tracking-wide">Pending Verification</p>
            <p className="text-2xl font-bold mt-1">{users.filter(u => u.verificationStatus === 'pending').length}</p>
          </div>
          <div className="bg-gray-100 rounded-xl p-4">
            <p className="text-xs text-gray-400 uppercase tracking-wide">Blocked Users</p>
            <p className="text-2xl font-bold mt-1 text-gray-900">{users.filter(u => u.isBlocked).length}</p>
          </div>
        </div>
      </div>
    </div>
  )
}