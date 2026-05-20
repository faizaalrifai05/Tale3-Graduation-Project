import { useEffect, useState } from 'react'
import { collection, getDocs, updateDoc, doc } from 'firebase/firestore'
import { db } from '../firebase/config'
import { User } from '../types'

interface Report {
  id: string
  reporterId: string
  reporterName: string
  reporterRole: string
  reportedUserId: string
  reportedUserName: string
  reportedUserRole: string
  reason: string
  description: string
  rideId: string
  origin: string
  destination: string
  status: 'pending' | 'reviewed' | 'resolved' | 'dismissed'
  createdAt: any
  adminNote?: string
}

export default function Reports() {
  const [reports, setReports] = useState<Report[]>([])
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [selected, setSelected] = useState<Report | null>(null)
  const [filter, setFilter] = useState<'all' | 'pending' | 'reviewed' | 'resolved' | 'dismissed'>('pending')
  const [actionLoading, setActionLoading] = useState(false)
  const [adminNote, setAdminNote] = useState('')
  const [search, setSearch] = useState('')

  useEffect(() => { fetchData() }, [])

  const fetchData = async () => {
    setLoading(true)
    const [reportsSnap, usersSnap] = await Promise.all([
      getDocs(collection(db, 'reports')),
      getDocs(collection(db, 'users')),
    ])
    const reportsData = reportsSnap.docs
      .map(d => ({ id: d.id, ...d.data() } as Report))
      .sort((a, b) => {
        const aTime = a.createdAt?.toDate?.()?.getTime() || 0
        const bTime = b.createdAt?.toDate?.()?.getTime() || 0
        return bTime - aTime
      })
    setReports(reportsData)
    setUsers(usersSnap.docs.map(d => ({ uid: d.id, ...d.data() } as User)))
    setLoading(false)
  }

  const filtered = reports.filter(r => {
    const matchFilter = filter === 'all' || r.status === filter
    const matchSearch =
      r.reporterName?.toLowerCase().includes(search.toLowerCase()) ||
      r.reportedUserName?.toLowerCase().includes(search.toLowerCase()) ||
      r.reason?.toLowerCase().includes(search.toLowerCase()) ||
      r.origin?.toLowerCase().includes(search.toLowerCase()) ||
      r.destination?.toLowerCase().includes(search.toLowerCase())
    return matchFilter && matchSearch
  })

  const updateStatus = async (
    report: Report,
    status: Report['status'],
    note?: string
  ) => {
    setActionLoading(true)
    await updateDoc(doc(db, 'reports', report.id), {
      status,
      adminNote: note || '',
      reviewedAt: new Date().toISOString(),
    })
    setReports(prev => prev.map(r =>
      r.id === report.id ? { ...r, status, adminNote: note || '' } : r
    ))
    setSelected(prev =>
      prev?.id === report.id ? { ...prev, status, adminNote: note || '' } : prev
    )
    setActionLoading(false)
  }

  const handleBlockUser = async (userId: string, name: string) => {
    if (!confirm(`Block ${name}? They will be signed out immediately.`)) return
    setActionLoading(true)
    await updateDoc(doc(db, 'users', userId), { isBlocked: true })
    setUsers(prev => prev.map(u => u.uid === userId ? { ...u, isBlocked: true } : u))
    setActionLoading(false)
  }

  const getStatusStyle = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-700'
      case 'reviewed': return 'bg-blue-100 text-blue-700'
      case 'resolved': return 'bg-green-100 text-green-700'
      case 'dismissed': return 'bg-gray-100 text-gray-500'
      default: return 'bg-gray-100 text-gray-500'
    }
  }

  const getRoleStyle = (role: string) =>
    role === 'driver'
      ? 'bg-blue-50 text-blue-700'
      : 'bg-purple-50 text-purple-700'

  const formatDate = (ts: any) => {
    if (!ts) return '—'
    try {
      const date = ts.toDate ? ts.toDate() : new Date(ts)
      return date.toLocaleDateString('en-US', {
        day: 'numeric', month: 'short', year: 'numeric',
        hour: '2-digit', minute: '2-digit'
      })
    } catch { return '—' }
  }

  const pendingCount = reports.filter(r => r.status === 'pending').length
  const reportedUser = selected
    ? users.find(u => u.uid === selected.reportedUserId)
    : null

  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <div className="font-semibold" style={{ color: '#8B1A1A' }}>Loading reports...</div>
    </div>
  )

  return (
    <div className="flex h-full">

      {/* ── Left Panel ── */}
      <div className="w-96 bg-white border-r border-gray-200 flex flex-col flex-shrink-0">
        <div className="p-5 border-b border-gray-100">
          <div className="flex items-center justify-between mb-1">
            <h2 className="text-base font-bold text-gray-900">User Reports</h2>
            {pendingCount > 0 && (
              <span className="text-xs px-2 py-0.5 rounded-full bg-yellow-100 text-yellow-700 font-semibold">
                {pendingCount} pending
              </span>
            )}
          </div>
          <p className="text-xs text-gray-400">{reports.length} total reports</p>

          {/* Search */}
          <div className="relative mt-3">
            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">🔍</span>
            <input
              type="text"
              placeholder="Search name, reason, route..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="w-full pl-8 pr-3 py-2 border border-gray-200 rounded-lg text-xs focus:outline-none"
            />
          </div>

          {/* Filter tabs */}
          <div className="flex gap-1 mt-3 flex-wrap">
            {(['all', 'pending', 'reviewed', 'resolved', 'dismissed'] as const).map(f => (
              <button
                key={f}
                onClick={() => { setFilter(f); setSelected(null) }}
                className={`text-xs px-2.5 py-1.5 rounded-lg font-medium capitalize transition ${
                  filter === f ? 'text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200'
                }`}
                style={filter === f ? { backgroundColor: '#8B1A1A' } : {}}
              >
                {f}
              </button>
            ))}
          </div>
        </div>

        {/* Report list */}
        <div className="flex-1 overflow-y-auto">
          {filtered.length === 0 ? (
            <div className="text-center py-12 text-gray-400 text-sm">
              No {filter === 'all' ? '' : filter} reports
            </div>
          ) : filtered.map(report => (
            <div
              key={report.id}
              onClick={() => {
                setSelected(report)
                setAdminNote(report.adminNote || '')
              }}
              className={`p-4 border-b border-gray-50 cursor-pointer hover:bg-gray-50 transition ${
                selected?.id === report.id ? 'bg-red-50 border-l-4' : ''
              }`}
              style={selected?.id === report.id ? { borderLeftColor: '#8B1A1A' } : {}}
            >
              {/* Status + date */}
              <div className="flex items-center justify-between mb-2">
                <span className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${getStatusStyle(report.status)}`}>
                  {report.status}
                </span>
                <span className="text-xs text-gray-400">
                  {formatDate(report.createdAt).split(',')[0]}
                </span>
              </div>

              {/* Reporter → Reported */}
              <div className="flex items-center gap-1.5 mb-1 flex-wrap">
                <span className={`text-xs px-1.5 py-0.5 rounded font-medium capitalize ${getRoleStyle(report.reporterRole)}`}>
                  {report.reporterRole}
                </span>
                <span className="text-sm font-semibold text-gray-900 truncate max-w-20">
                  {report.reporterName}
                </span>
                <span className="text-gray-300">→</span>
                <span className={`text-xs px-1.5 py-0.5 rounded font-medium capitalize ${getRoleStyle(report.reportedUserRole)}`}>
                  {report.reportedUserRole}
                </span>
                <span className="text-sm font-semibold text-gray-900 truncate max-w-20">
                  {report.reportedUserName}
                </span>
              </div>

              {/* Route */}
              {report.origin && (
                <p className="text-xs text-gray-400 mt-1">
                  🗺️ {report.origin} → {report.destination}
                </p>
              )}

              {/* Reason */}
              <p className="text-xs text-gray-500 mt-1 truncate">⚠️ {report.reason}</p>
            </div>
          ))}
        </div>

        {/* Stats footer */}
        <div className="p-4 border-t border-gray-100 bg-gray-50 grid grid-cols-4 gap-2">
          {[
            { label: 'Pending', count: reports.filter(r => r.status === 'pending').length, color: 'text-yellow-600' },
            { label: 'Reviewed', count: reports.filter(r => r.status === 'reviewed').length, color: 'text-blue-600' },
            { label: 'Resolved', count: reports.filter(r => r.status === 'resolved').length, color: 'text-green-600' },
            { label: 'Dismissed', count: reports.filter(r => r.status === 'dismissed').length, color: 'text-gray-500' },
          ].map(s => (
            <div key={s.label} className="text-center">
              <p className={`text-sm font-bold ${s.color}`}>{s.count}</p>
              <p className="text-xs text-gray-400">{s.label}</p>
            </div>
          ))}
        </div>
      </div>

      {/* ── Right Panel ── */}
      <div className="flex-1 overflow-auto p-8">
        {!selected ? (
          <div className="flex flex-col items-center justify-center h-full text-gray-400">
            <span className="text-6xl mb-4">🚩</span>
            <p className="text-lg font-medium">Select a report to review</p>
            <p className="text-sm mt-1">Choose from the list on the left</p>
          </div>
        ) : (
          <div>

            {/* Header */}
            <div className="flex items-start justify-between mb-8">
              <div>
                <p className="text-xs text-gray-400 uppercase tracking-widest mb-1">Report Details</p>
                <h1 className="text-2xl font-bold text-gray-900">{selected.reason}</h1>
                <p className="text-sm text-gray-400 mt-1">{formatDate(selected.createdAt)}</p>
              </div>
              <span className={`px-4 py-2 rounded-lg text-sm font-semibold capitalize ${getStatusStyle(selected.status)}`}>
                {selected.status}
              </span>
            </div>

            {/* Trip info */}
            {selected.origin && (
              <div className="bg-gray-50 rounded-xl border border-gray-200 px-5 py-4 mb-6 flex items-center gap-3">
                <span className="text-2xl">🗺️</span>
                <div>
                  <p className="text-xs text-gray-400 uppercase tracking-wide mb-0.5">Trip Route</p>
                  <p className="text-base font-bold text-gray-900">
                    {selected.origin} → {selected.destination}
                  </p>
                  {selected.rideId && (
                    <p className="text-xs text-gray-400 font-mono mt-0.5">
                      Ride ID: {selected.rideId}
                    </p>
                  )}
                </div>
              </div>
            )}

            {/* Reporter & Reported */}
            <div className="grid grid-cols-2 gap-4 mb-6">

              {/* Reporter */}
              <div className="bg-white rounded-xl border border-gray-100 p-5">
                <p className="text-xs text-gray-400 uppercase tracking-wide mb-3 font-semibold">
                  Reported By
                </p>
                <div className="flex items-center gap-3">
                  <div className="w-11 h-11 rounded-full flex items-center justify-center text-white font-bold text-sm"
                    style={{ backgroundColor: '#8B1A1A' }}>
                    {selected.reporterName?.[0]?.toUpperCase() || '?'}
                  </div>
                  <div>
                    <p className="text-sm font-bold text-gray-900">{selected.reporterName}</p>
                    <span className={`text-xs px-2 py-0.5 rounded font-medium capitalize ${getRoleStyle(selected.reporterRole)}`}>
                      {selected.reporterRole}
                    </span>
                  </div>
                </div>
              </div>

              {/* Reported User */}
              <div className="bg-red-50 rounded-xl border border-red-100 p-5">
                <p className="text-xs text-red-400 uppercase tracking-wide mb-3 font-semibold">
                  Reported User
                </p>
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-11 h-11 rounded-full bg-red-200 flex items-center justify-center text-red-700 font-bold text-sm">
                    {selected.reportedUserName?.[0]?.toUpperCase() || '?'}
                  </div>
                  <div>
                    <p className="text-sm font-bold text-gray-900">{selected.reportedUserName}</p>
                    <div className="flex items-center gap-2 mt-0.5">
                      <span className={`text-xs px-2 py-0.5 rounded font-medium capitalize ${getRoleStyle(selected.reportedUserRole)}`}>
                        {selected.reportedUserRole}
                      </span>
                      {reportedUser?.isBlocked && (
                        <span className="text-xs px-2 py-0.5 rounded bg-red-100 text-red-700 font-medium">
                          🚫 Blocked
                        </span>
                      )}
                    </div>
                  </div>
                </div>
                {reportedUser && !reportedUser.isBlocked && (
                  <button
                    onClick={() => handleBlockUser(selected.reportedUserId, selected.reportedUserName)}
                    disabled={actionLoading}
                    className="w-full py-2 bg-red-100 text-red-700 rounded-lg text-xs font-semibold hover:bg-red-200 transition disabled:opacity-50"
                  >
                    🚫 Block This User
                  </button>
                )}
              </div>
            </div>

            {/* Report Content */}
            <div className="bg-white rounded-xl border border-gray-100 p-6 mb-6">
              <h2 className="text-sm font-semibold text-gray-900 mb-4">Report Content</h2>
              <div className="space-y-4">
                <div>
                  <p className="text-xs text-gray-400 uppercase tracking-wide mb-1">Reason</p>
                  <div className="flex items-center gap-2 bg-yellow-50 rounded-lg px-3 py-2.5">
                    <span>⚠️</span>
                    <p className="text-sm font-semibold text-gray-900">{selected.reason}</p>
                  </div>
                </div>

                {selected.description ? (
                  <div>
                    <p className="text-xs text-gray-400 uppercase tracking-wide mb-1">
                      Description
                    </p>
                    <p className="text-sm text-gray-700 bg-gray-50 rounded-lg p-3 leading-relaxed">
                      {selected.description}
                    </p>
                  </div>
                ) : (
                  <div>
                    <p className="text-xs text-gray-400 uppercase tracking-wide mb-1">
                      Description
                    </p>
                    <p className="text-sm text-gray-300 italic">No additional description provided</p>
                  </div>
                )}

                {selected.adminNote && (
                  <div>
                    <p className="text-xs text-gray-400 uppercase tracking-wide mb-1">
                      Admin Note
                    </p>
                    <p className="text-sm text-blue-700 bg-blue-50 rounded-lg p-3">
                      {selected.adminNote}
                    </p>
                  </div>
                )}
              </div>
            </div>

            {/* Admin Actions */}
            {selected.status === 'pending' ? (
              <div className="bg-white rounded-xl border border-gray-100 p-6">
                <h2 className="text-sm font-semibold text-gray-900 mb-4">Take Action</h2>
                <div className="mb-4">
                  <label className="text-xs text-gray-400 uppercase tracking-wide mb-1 block">
                    Admin Note (optional)
                  </label>
                  <textarea
                    value={adminNote}
                    onChange={e => setAdminNote(e.target.value)}
                    placeholder="Describe what action was taken..."
                    rows={3}
                    className="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none resize-none"
                  />
                </div>
                <div className="grid grid-cols-3 gap-3">
                  <button
                    onClick={() => updateStatus(selected, 'reviewed', adminNote)}
                    disabled={actionLoading}
                    className="py-2.5 bg-blue-50 text-blue-700 rounded-lg text-sm font-semibold hover:bg-blue-100 transition disabled:opacity-50"
                  >
                    👁️ Mark Reviewed
                  </button>
                  <button
                    onClick={() => updateStatus(selected, 'resolved', adminNote)}
                    disabled={actionLoading}
                    className="py-2.5 bg-green-50 text-green-700 rounded-lg text-sm font-semibold hover:bg-green-100 transition disabled:opacity-50"
                  >
                    ✅ Mark Resolved
                  </button>
                  <button
                    onClick={() => updateStatus(selected, 'dismissed', adminNote)}
                    disabled={actionLoading}
                    className="py-2.5 bg-gray-100 text-gray-600 rounded-lg text-sm font-semibold hover:bg-gray-200 transition disabled:opacity-50"
                  >
                    🗑️ Dismiss
                  </button>
                </div>
              </div>
            ) : (
              <div className="bg-gray-50 rounded-xl border border-gray-200 p-5 flex items-center justify-between">
                <div>
                  <p className="text-sm font-semibold text-gray-700 capitalize">
                    Report {selected.status}
                  </p>
                  {selected.adminNote && (
                    <p className="text-xs text-gray-400 mt-0.5">{selected.adminNote}</p>
                  )}
                </div>
                <button
                  onClick={() => updateStatus(selected, 'pending')}
                  className="text-xs px-3 py-1.5 border border-gray-300 rounded-lg text-gray-500 hover:bg-white transition"
                >
                  Reopen
                </button>
              </div>
            )}

          </div>
        )}
      </div>
    </div>
  )
}