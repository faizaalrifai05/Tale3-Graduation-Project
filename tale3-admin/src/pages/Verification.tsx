import { useEffect, useState } from 'react'
import { collection, getDocs, updateDoc, doc } from 'firebase/firestore'
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

  useEffect(() => {
    fetchDrivers()
  }, [])

  const fetchDrivers = async () => {
    setLoading(true)
    const snap = await getDocs(collection(db, 'users'))
    const data = snap.docs
      .map(d => ({ uid: d.id, ...d.data() } as User))
      .filter(u => u.role === 'driver')
    setDrivers(data)
    setLoading(false)
  }

  const filteredDrivers = drivers.filter(d => d.verificationStatus === filter)

  const handleApprove = async () => {
    if (!selected) return
    setActionLoading(true)
    await updateDoc(doc(db, 'users', selected.uid), {
      verificationStatus: 'verified'
    })
    setDrivers(prev => prev.map(d =>
      d.uid === selected.uid ? { ...d, verificationStatus: 'verified' } : d
    ))
    setSelected(prev => prev ? { ...prev, verificationStatus: 'verified' } : null)
    setActionLoading(false)
  }

  const handleReject = async () => {
    if (!selected) return
    setActionLoading(true)
    await updateDoc(doc(db, 'users', selected.uid), {
      verificationStatus: 'rejected',
      rejectionReason: rejectReason,
    })
    setDrivers(prev => prev.map(d =>
      d.uid === selected.uid ? { ...d, verificationStatus: 'rejected' } : d
    ))
    setSelected(prev => prev ? { ...prev, verificationStatus: 'rejected' } : null)
    setShowRejectInput(false)
    setRejectReason('')
    setActionLoading(false)
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-700'
      case 'verified': return 'bg-green-100 text-green-700'
      case 'rejected': return 'bg-red-100 text-red-700'
      default: return 'bg-gray-100 text-gray-500'
    }
  }

  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <div className="text-primary font-semibold">Loading verifications...</div>
    </div>
  )

  return (
    <div className="flex h-full">
      {/* Image Preview Modal */}
      {previewImg && (
        <div
          className="fixed inset-0 bg-black bg-opacity-80 flex items-center justify-center z-50"
          onClick={() => setPreviewImg(null)}
        >
          <img src={previewImg} className="max-w-2xl max-h-screen rounded-lg shadow-2xl" />
          <button className="absolute top-4 right-4 text-white text-2xl">✕</button>
        </div>
      )}

      {/* Left Panel — Driver List */}
      <div className="w-80 bg-white border-r border-gray-200 flex flex-col">
        <div className="p-5 border-b border-gray-100">
          <h2 className="text-base font-bold text-gray-900">Driver Verification Queue</h2>
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
              </button>
            ))}
          </div>
        </div>

        <div className="flex-1 overflow-y-auto">
          {filteredDrivers.length === 0 ? (
            <div className="text-center py-12 text-gray-400 text-sm">
              No {filter} applications
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
              </div>
              <p className="text-sm font-semibold text-gray-900">{driver.name}</p>
              <p className="text-xs text-gray-400 mt-0.5">{driver.email}</p>
            </div>
          ))}
        </div>

        {/* Queue Stats */}
        <div className="p-4 border-t border-gray-100 bg-gray-50">
          <p className="text-xs text-gray-400">
            Pending: <span className="font-semibold text-yellow-600">{drivers.filter(d => d.verificationStatus === 'pending').length}</span>
            {' · '}
            Verified: <span className="font-semibold text-green-600">{drivers.filter(d => d.verificationStatus === 'verified').length}</span>
            {' · '}
            Rejected: <span className="font-semibold text-red-600">{drivers.filter(d => d.verificationStatus === 'rejected').length}</span>
          </p>
        </div>
      </div>

      {/* Right Panel — Review */}
      <div className="flex-1 overflow-auto p-8">
        {!selected ? (
          <div className="flex flex-col items-center justify-center h-full text-gray-400">
            <span className="text-5xl mb-4">🛡️</span>
            <p className="text-lg font-medium">Select a driver to review</p>
            <p className="text-sm mt-1">Choose from the queue on the left</p>
          </div>
        ) : (
          <div>
            {/* Driver Header */}
            <div className="flex items-start justify-between mb-8">
              <div>
                <p className="text-xs text-gray-400 uppercase tracking-widest mb-1">Reviewing Application</p>
                <h1 className="text-3xl font-bold text-gray-900">{selected.name}</h1>
                <div className="flex items-center gap-4 mt-2 text-sm text-gray-500">
                  <span>📧 {selected.email}</span>
                  {selected.phone && <span>📱 {selected.phone}</span>}
                </div>
              </div>
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

            {/* Reject Input */}
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
                    onClick={() => setShowRejectInput(false)}
                    className="px-4 py-2 text-gray-500 hover:text-gray-700 text-sm"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            )}

            {/* ID Photos */}
            <div className="mb-8">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Document Review</h2>
              <div className="grid grid-cols-2 gap-4">
                {/* Front ID */}
                <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                  <div className="px-4 py-3 bg-gray-50 border-b border-gray-100 flex items-center justify-between">
                    <p className="text-xs font-semibold text-gray-600 uppercase tracking-wide">National ID (Front)</p>
                    {selected.idFrontUrl && (
                      <button
                        onClick={() => setPreviewImg(selected.idFrontUrl)}
                        className="text-xs text-primary hover:underline"
                      >
                        🔍 Zoom
                      </button>
                    )}
                  </div>
                  <div className="p-4 h-48 flex items-center justify-center bg-gray-50">
                    {selected.idFrontUrl ? (
                      <img
                        src={selected.idFrontUrl}
                        className="max-h-full max-w-full object-contain rounded cursor-pointer"
                        onClick={() => setPreviewImg(selected.idFrontUrl)}
                      />
                    ) : (
                      <p className="text-sm text-gray-400">No photo uploaded</p>
                    )}
                  </div>
                </div>

                {/* Back ID */}
                <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
                  <div className="px-4 py-3 bg-gray-50 border-b border-gray-100 flex items-center justify-between">
                    <p className="text-xs font-semibold text-gray-600 uppercase tracking-wide">National ID (Back)</p>
                    {selected.idBackUrl && (
                      <button
                        onClick={() => setPreviewImg(selected.idBackUrl)}
                        className="text-xs text-primary hover:underline"
                      >
                        🔍 Zoom
                      </button>
                    )}
                  </div>
                  <div className="p-4 h-48 flex items-center justify-center bg-gray-50">
                    {selected.idBackUrl ? (
                      <img
                        src={selected.idBackUrl}
                        className="max-h-full max-w-full object-contain rounded cursor-pointer"
                        onClick={() => setPreviewImg(selected.idBackUrl)}
                      />
                    ) : (
                      <p className="text-sm text-gray-400">No photo uploaded</p>
                    )}
                  </div>
                </div>
              </div>
            </div>

            {/* Driver Info */}
            <div className="bg-white rounded-xl border border-gray-100 p-6">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Driver Details</h2>
              <div className="grid grid-cols-3 gap-4">
                {[
                  { label: 'Phone', value: selected.phone || '—' },
                  { label: 'Car Make', value: selected.carMake || '—' },
                  { label: 'Car Model', value: selected.carModel || '—' },
                  { label: 'Car Year', value: selected.carYear || '—' },
                  { label: 'Car Color', value: selected.carColor || '—' },
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