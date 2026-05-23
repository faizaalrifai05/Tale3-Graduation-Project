import { useEffect, useState } from 'react'
import { collection, onSnapshot, updateDoc, doc, query, where } from 'firebase/firestore'
import { db } from '../firebase/config'
import { User } from '../types'

export default function Verification() {
  const [drivers, setDrivers] = useState<User[]>([])
  const [selected, setSelected] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [actionLoading, setActionLoading] = useState(false)
  const [filter, setFilter] = useState<'pending' | 'verified' | 'rejected'>('pending')
  const [rejectReason, setRejectReason] = useState('')
  const [showRejectInput, setShowRejectInput] = useState(false)
  const [previewImg, setPreviewImg] = useState<string | null>(null)

  // ── Real-time listener on the 'users' collection ──────────────────────────
  // Previously used getDocs() (a one-shot fetch) which meant newly registered
  // drivers never appeared without a manual page refresh. onSnapshot() keeps
  // the list live so new pending drivers show up instantly.
  useEffect(() => {
    setLoading(true)

    const q = query(collection(db, 'users'), where('role', '==', 'driver'))

    const unsubscribe = onSnapshot(
      q,
      (snap) => {
        const data = snap.docs.map(d => ({ uid: d.id, ...d.data() } as User))
        setDrivers(data)

        // If the currently selected driver was updated externally (e.g. another
        // admin approved them), refresh the selected panel too.
        setSelected(prev => {
          if (!prev) return prev
          const updated = data.find(d => d.uid === prev.uid)
          return updated ?? prev
        })

        setLoading(false)
      },
      (error) => {
        console.error('Verification listener error:', error)
        setLoading(false)
      }
    )

    return () => unsubscribe()
  }, [])

  const filteredDrivers = drivers.filter(d => d.verificationStatus === filter)

  // ── Counts for the queue stats footer ────────────────────────────────────
  const pendingCount  = drivers.filter(d => d.verificationStatus === 'pending').length
  const verifiedCount = drivers.filter(d => d.verificationStatus === 'verified').length
  const rejectedCount = drivers.filter(d => d.verificationStatus === 'rejected').length

  // ── Actions ───────────────────────────────────────────────────────────────
  const handleApprove = async () => {
    if (!selected) return
    setActionLoading(true)
    try {
      await updateDoc(doc(db, 'users', selected.uid), {
        verificationStatus: 'verified',
      })
      // onSnapshot will update `drivers` and `selected` automatically.
    } catch (err) {
      console.error('Approve failed:', err)
    } finally {
      setActionLoading(false)
    }
  }

  const handleReject = async () => {
    if (!selected) return
    setActionLoading(true)
    try {
      await updateDoc(doc(db, 'users', selected.uid), {
        verificationStatus: 'rejected',
        rejectionReason: rejectReason,
      })
      setShowRejectInput(false)
      setRejectReason('')
    } catch (err) {
      console.error('Reject failed:', err)
    } finally {
      setActionLoading(false)
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending':  return 'bg-yellow-100 text-yellow-700'
      case 'verified': return 'bg-green-100 text-green-700'
      case 'rejected': return 'bg-red-100 text-red-700'
      default:         return 'bg-gray-100 text-gray-500'
    }
  }

  const formatDate = (ts: any): string => {
    if (!ts) return '—'
    try {
      const date = ts.toDate ? ts.toDate() : new Date(ts)
      return date.toLocaleDateString('en-GB', {
        day: '2-digit', month: 'short', year: 'numeric',
      })
    } catch {
      return '—'
    }
  }

  // ── Photo card helper — handles empty/missing URLs gracefully ─────────────
  const PhotoCard = ({ label, url }: { label: string; url?: string }) => (
    <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <div className="px-4 py-3 bg-gray-50 border-b border-gray-100 flex items-center justify-between">
        <p className="text-xs font-semibold text-gray-600 uppercase tracking-wide">{label}</p>
        {url && (
          <button
            onClick={() => setPreviewImg(url)}
            className="text-xs text-primary hover:underline"
          >
            🔍 Zoom
          </button>
        )}
      </div>
      <div className="p-4 h-48 flex items-center justify-center bg-gray-50">
        {url ? (
          <img
            src={url}
            className="max-h-full max-w-full object-contain rounded cursor-pointer"
            onClick={() => setPreviewImg(url)}
            onError={(e) => {
              // If the URL is stale or Storage is disabled, show placeholder
              ;(e.target as HTMLImageElement).style.display = 'none'
            }}
          />
        ) : (
          <div className="text-center">
            <p className="text-2xl mb-1">📷</p>
            <p className="text-sm text-gray-400">No photo uploaded</p>
            <p className="text-xs text-gray-300 mt-1">(Firebase Storage may be disabled)</p>
          </div>
        )}
      </div>
    </div>
  )

  // ── Loading state ─────────────────────────────────────────────────────────
  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <div className="text-center">
        <div className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-3" />
        <p className="text-primary font-semibold text-sm">Loading verifications...</p>
      </div>
    </div>
  )

  // ── Render ────────────────────────────────────────────────────────────────
  return (
    <div className="flex h-full">

      {/* ── Image Preview Modal ────────────────────────────────────────────── */}
      {previewImg && (
        <div
          className="fixed inset-0 bg-black bg-opacity-80 flex items-center justify-center z-50"
          onClick={() => setPreviewImg(null)}
        >
          <img src={previewImg} className="max-w-2xl max-h-screen rounded-lg shadow-2xl" alt="Preview" />
          <button
            className="absolute top-4 right-4 text-white text-2xl font-bold hover:opacity-70"
            onClick={() => setPreviewImg(null)}
          >
            ✕
          </button>
        </div>
      )}

      {/* ── Left Panel — Driver Queue ──────────────────────────────────────── */}
      <div className="w-80 bg-white border-r border-gray-200 flex flex-col">
        <div className="p-5 border-b border-gray-100">
          <h2 className="text-base font-bold text-gray-900">Driver Verification Queue</h2>

          {/* Filter tabs */}
          <div className="flex gap-1 mt-3">
            {(['pending', 'verified', 'rejected'] as const).map(f => (
              <button
                key={f}
                onClick={() => { setFilter(f); setSelected(null) }}
                className={`flex-1 text-xs py-1.5 rounded-lg font-medium capitalize transition ${
                  filter === f ? 'bg-primary text-white' : 'bg-gray-100 text-gray-500 hover:bg-gray-200'
                }`}
              >
                {f}
                {/* Live badge counts */}
                <span className={`ml-1 px-1.5 py-0.5 rounded-full text-[10px] font-bold ${
                  filter === f ? 'bg-white bg-opacity-30 text-white' : 'bg-gray-200 text-gray-500'
                }`}>
                  {f === 'pending' ? pendingCount : f === 'verified' ? verifiedCount : rejectedCount}
                </span>
              </button>
            ))}
          </div>
        </div>

        {/* Driver list */}
        <div className="flex-1 overflow-y-auto">
          {filteredDrivers.length === 0 ? (
            <div className="text-center py-12 px-4">
              <p className="text-3xl mb-2">
                {filter === 'pending' ? '⏳' : filter === 'verified' ? '✅' : '❌'}
              </p>
              <p className="text-gray-400 text-sm font-medium">No {filter} applications</p>
              {filter === 'pending' && (
                <p className="text-gray-300 text-xs mt-1">
                  New drivers will appear here after completing registration
                </p>
              )}
            </div>
          ) : filteredDrivers.map(driver => (
            <div
              key={driver.uid}
              onClick={() => setSelected(driver)}
              className={`p-4 border-b border-gray-50 cursor-pointer hover:bg-gray-50 transition ${
                selected?.uid === driver.uid ? 'bg-primary-light border-l-4 border-l-primary' : ''
              }`}
            >
              <div className="flex items-center justify-between mb-1">
                <span className={`text-xs px-2 py-0.5 rounded font-medium uppercase ${getStatusColor(driver.verificationStatus)}`}>
                  {driver.verificationStatus}
                </span>
                <span className="text-xs text-gray-300">{formatDate(driver.createdAt)}</span>
              </div>
              <p className="text-sm font-semibold text-gray-900 mt-1">{driver.name}</p>
              <p className="text-xs text-gray-400 mt-0.5">{driver.email}</p>
              {driver.phone && (
                <p className="text-xs text-gray-300 mt-0.5">📱 {driver.phone}</p>
              )}
            </div>
          ))}
        </div>

        {/* Queue stats */}
        <div className="p-4 border-t border-gray-100 bg-gray-50">
          <p className="text-xs text-gray-400">
            Pending: <span className="font-semibold text-yellow-600">{pendingCount}</span>
            {' · '}
            Verified: <span className="font-semibold text-green-600">{verifiedCount}</span>
            {' · '}
            Rejected: <span className="font-semibold text-red-600">{rejectedCount}</span>
          </p>
          <p className="text-[10px] text-gray-300 mt-1">Updates in real-time</p>
        </div>
      </div>

      {/* ── Right Panel — Review ───────────────────────────────────────────── */}
      <div className="flex-1 overflow-auto p-8">
        {!selected ? (
          <div className="flex flex-col items-center justify-center h-full text-gray-400">
            <span className="text-5xl mb-4">🛡️</span>
            <p className="text-lg font-medium">Select a driver to review</p>
            <p className="text-sm mt-1">Choose from the queue on the left</p>
          </div>
        ) : (
          <div>

            {/* ── Driver header ────────────────────────────────────────────── */}
            <div className="flex items-start justify-between mb-8">
              <div>
                <p className="text-xs text-gray-400 uppercase tracking-widest mb-1">Reviewing Application</p>
                <h1 className="text-3xl font-bold text-gray-900">{selected.name}</h1>
                <div className="flex items-center gap-4 mt-2 text-sm text-gray-500">
                  <span>📧 {selected.email}</span>
                  {selected.phone && <span>📱 {selected.phone}</span>}
                  <span>📅 Registered {formatDate(selected.createdAt)}</span>
                </div>
              </div>

              {/* Action buttons — only shown when pending */}
              <div className="flex gap-3">
                {selected.verificationStatus === 'pending' && (
                  <>
                    <button
                      onClick={() => setShowRejectInput(!showRejectInput)}
                      className="px-5 py-2.5 border border-red-200 text-red-600 rounded-lg text-sm font-medium hover:bg-red-50 transition"
                    >
                      Deny Driver
                    </button>
                    <button
                      onClick={handleApprove}
                      disabled={actionLoading}
                      className="px-5 py-2.5 bg-primary text-white rounded-lg text-sm font-semibold hover:bg-opacity-90 transition disabled:opacity-50"
                    >
                      {actionLoading ? 'Processing...' : 'Approve Application'}
                    </button>
                  </>
                )}
                {selected.verificationStatus === 'verified' && (
                  <span className="px-5 py-2.5 bg-green-100 text-green-700 rounded-lg text-sm font-semibold">
                    ✓ Verified
                  </span>
                )}
                {selected.verificationStatus === 'rejected' && (
                  <span className="px-5 py-2.5 bg-red-100 text-red-700 rounded-lg text-sm font-semibold">
                    ✕ Rejected
                  </span>
                )}
              </div>
            </div>

            {/* ── Rejection reason input ───────────────────────────────────── */}
            {showRejectInput && (
              <div className="mb-6 bg-red-50 rounded-xl p-4">
                <p className="text-sm font-medium text-red-700 mb-2">Rejection Reason (optional)</p>
                <input
                  type="text"
                  value={rejectReason}
                  onChange={e => setRejectReason(e.target.value)}
                  placeholder="e.g. ID photo unclear, expired license..."
                  className="w-full border border-red-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 bg-white"
                />
                <div className="flex gap-2 mt-3">
                  <button
                    onClick={handleReject}
                    disabled={actionLoading}
                    className="px-4 py-2 bg-red-600 text-white rounded-lg text-sm font-medium hover:bg-red-700 disabled:opacity-50"
                  >
                    {actionLoading ? 'Processing...' : 'Confirm Rejection'}
                  </button>
                  <button
                    onClick={() => { setShowRejectInput(false); setRejectReason('') }}
                    className="px-4 py-2 text-gray-500 hover:text-gray-700 text-sm"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            )}

            {/* ── ID Document photos ───────────────────────────────────────── */}
            <div className="mb-8">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Identity Documents</h2>
              <div className="grid grid-cols-2 gap-4">
                <PhotoCard label="National ID (Front)" url={selected.idFrontUrl || ''} />
                <PhotoCard label="National ID (Back)"  url={selected.idBackUrl  || ''} />
              </div>
            </div>

            {/* ── Car photos ───────────────────────────────────────────────── */}
            <div className="mb-8">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Vehicle Photos</h2>
              <div className="grid grid-cols-2 gap-4">
                <PhotoCard label="Car (Front)" url={(selected as any).carFrontUrl || ''} />
                <PhotoCard label="Car (Back)"  url={(selected as any).carBackUrl  || ''} />
              </div>
            </div>

            {/* ── Driver & vehicle details ─────────────────────────────────── */}
            <div className="bg-white rounded-xl border border-gray-100 p-6">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Driver & Vehicle Details</h2>
              <div className="grid grid-cols-3 gap-4">
                {[
                  { label: 'Phone',        value: selected.phone       || '—' },
                  { label: 'Car Make',     value: selected.carMake     || '—' },
                  { label: 'Car Model',    value: selected.carModel    || '—' },
                  { label: 'Car Year',     value: selected.carYear     || '—' },
                  { label: 'Car Color',    value: selected.carColor    || '—' },
                  { label: 'Plate Number', value: selected.plateNumber || '—' },
                ].map(item => (
                  <div key={item.label} className="bg-gray-50 rounded-lg p-3">
                    <p className="text-xs text-gray-400 uppercase tracking-wide">{item.label}</p>
                    <p className="text-sm font-semibold text-gray-900 mt-1">{item.value}</p>
                  </div>
                ))}
              </div>
            </div>

          </div>
        )}
      </div>

    </div>
  )
}