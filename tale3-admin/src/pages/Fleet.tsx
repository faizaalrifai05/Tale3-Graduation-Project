import { useEffect, useState } from 'react'
import { collection, getDocs } from 'firebase/firestore'
import { db } from '../firebase/config'
import { User } from '../types'

interface DriverWithCar extends User {
  ridesCount: number
  totalEarnings: number
}

export default function Fleet() {
  const [drivers, setDrivers] = useState<DriverWithCar[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState<'all' | 'verified' | 'pending' | 'unsubmitted'>('all')
  const [selected, setSelected] = useState<DriverWithCar | null>(null)
  const [previewImg, setPreviewImg] = useState<string | null>(null)

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    setLoading(true)
    const [usersSnap, ridesSnap] = await Promise.all([
      getDocs(collection(db, 'users')),
      getDocs(collection(db, 'rides')),
    ])

    const rides = ridesSnap.docs.map(d => ({ id: d.id, ...d.data() } as any))

    const driverData = usersSnap.docs
      .map(d => ({ uid: d.id, ...d.data() } as User))
      .filter(u => u.role === 'driver')
      .map(driver => {
        const driverRides = rides.filter((r: any) => r.driverId === driver.uid)
        const totalEarnings = driverRides.reduce((sum: number, r: any) =>
          sum + (r.pricePerSeat * r.bookedSeats), 0)
        return { ...driver, ridesCount: driverRides.length, totalEarnings }
      })
      .sort((a, b) => b.ridesCount - a.ridesCount)

    setDrivers(driverData)
    setLoading(false)
  }

  const filtered = drivers.filter(d => {
    const matchSearch =
      d.name?.toLowerCase().includes(search.toLowerCase()) ||
      d.plateNumber?.toLowerCase().includes(search.toLowerCase()) ||
      d.carMake?.toLowerCase().includes(search.toLowerCase()) ||
      d.carModel?.toLowerCase().includes(search.toLowerCase())
    const matchFilter = filter === 'all' || d.verificationStatus === filter
    return matchSearch && matchFilter
  })

  const getVerificationBadge = (status: string) => {
    switch (status) {
      case 'verified': return 'bg-green-100 text-green-700'
      case 'pending': return 'bg-yellow-100 text-yellow-700'
      case 'rejected': return 'bg-red-100 text-red-700'
      default: return 'bg-gray-100 text-gray-500'
    }
  }

  const totalCars = drivers.filter(d => d.carMake).length
  const verifiedCars = drivers.filter(d => d.verificationStatus === 'verified').length
  const pendingCars = drivers.filter(d => d.verificationStatus === 'pending').length

  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <div className="text-primary font-semibold">Loading fleet...</div>
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
          <img src={previewImg} className="max-w-3xl max-h-screen rounded-xl shadow-2xl object-contain" />
          <button
            className="absolute top-4 right-4 text-white text-3xl hover:opacity-70"
            onClick={() => setPreviewImg(null)}
          >
            ✕
          </button>
        </div>
      )}

      {/* ── Left Panel — Car List ── */}
      <div className="w-80 bg-white border-r border-gray-200 flex flex-col flex-shrink-0">

        {/* Header */}
        <div className="p-5 border-b border-gray-100">
          <h2 className="text-base font-bold text-gray-900">Fleet Directory</h2>
          <p className="text-xs text-gray-400 mt-0.5">{totalCars} registered vehicles</p>

          {/* Search */}
          <div className="relative mt-3">
            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm">🔍</span>
            <input
              type="text"
              placeholder="Search plate, make, driver..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="w-full pl-8 pr-3 py-2 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>

          {/* Filter tabs */}
          <div className="flex gap-1 mt-3">
            {(['all', 'verified', 'pending', 'unsubmitted'] as const).map(f => (
              <button
                key={f}
                onClick={() => { setFilter(f); setSelected(null) }}
                className={`flex-1 text-xs py-1 rounded-lg font-medium capitalize transition ${
                  filter === f
                    ? 'text-white'
                    : 'bg-gray-100 text-gray-500 hover:bg-gray-200'
                }`}
                style={filter === f ? { backgroundColor: '#8B1A1A' } : {}}
              >
                {f === 'unsubmitted' ? 'New' : f}
              </button>
            ))}
          </div>
        </div>

        {/* Car list */}
        <div className="flex-1 overflow-y-auto">
          {filtered.length === 0 ? (
            <div className="text-center py-12 text-gray-400 text-sm">No vehicles found</div>
          ) : filtered.map(driver => (
            <div
              key={driver.uid}
              onClick={() => setSelected(driver)}
              className={`p-4 border-b border-gray-50 cursor-pointer hover:bg-gray-50 transition ${
                selected?.uid === driver.uid ? 'bg-red-50 border-l-4 border-l-primary' : ''
              }`}
            >
              {/* Car photo or placeholder */}
              <div className="flex items-center gap-3 mb-2">
                <div className="w-14 h-10 rounded-lg bg-gray-100 flex items-center justify-center overflow-hidden flex-shrink-0 border border-gray-200">
                  {(driver as any).carPhotoUrl ? (
                    <img
                      src={(driver as any).carPhotoUrl}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <span className="text-xl">🚗</span>
                  )}
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-bold text-gray-900 truncate">
                    {driver.carMake || 'Unknown'} {driver.carModel || ''}
                  </p>
                  <p className="text-xs text-gray-400 font-mono">
                    {driver.plateNumber || 'No plate'}
                  </p>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs font-medium text-gray-700">{driver.name}</p>
                  <p className="text-xs text-gray-400">{driver.ridesCount} rides</p>
                </div>
                <span className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${getVerificationBadge(driver.verificationStatus)}`}>
                  {driver.verificationStatus === 'unsubmitted' ? 'new' : driver.verificationStatus}
                </span>
              </div>
            </div>
          ))}
        </div>

        {/* Stats footer */}
        <div className="p-4 border-t border-gray-100 bg-gray-50 space-y-1">
          <div className="flex justify-between text-xs">
            <span className="text-gray-400">Verified vehicles</span>
            <span className="font-semibold text-green-600">{verifiedCars}</span>
          </div>
          <div className="flex justify-between text-xs">
            <span className="text-gray-400">Pending review</span>
            <span className="font-semibold text-yellow-600">{pendingCars}</span>
          </div>
          <div className="flex justify-between text-xs">
            <span className="text-gray-400">Total vehicles</span>
            <span className="font-semibold text-gray-700">{totalCars}</span>
          </div>
        </div>
      </div>

      {/* ── Right Panel — Car Detail ── */}
      <div className="flex-1 overflow-auto p-8">
        {!selected ? (
          <div className="flex flex-col items-center justify-center h-full text-gray-400">
            <span className="text-6xl mb-4">🚗</span>
            <p className="text-lg font-medium">Select a vehicle to inspect</p>
            <p className="text-sm mt-1">Choose from the fleet list on the left</p>
          </div>
        ) : (
          <div>

            {/* Header */}
            <div className="flex items-start justify-between mb-8">
              <div>
                <p className="text-xs text-gray-400 uppercase tracking-widest mb-1">Vehicle Profile</p>
                <h1 className="text-3xl font-bold text-gray-900">
                  {selected.carMake || 'Unknown'} {selected.carModel || ''}
                </h1>
                <div className="flex items-center gap-3 mt-2">
                  <span className="font-mono text-sm bg-gray-100 px-3 py-1 rounded-lg text-gray-700 font-semibold">
                    {selected.plateNumber || 'No plate number'}
                  </span>
                  <span className={`text-xs px-3 py-1 rounded-full font-semibold capitalize ${getVerificationBadge(selected.verificationStatus)}`}>
                    {selected.verificationStatus}
                  </span>
                </div>
              </div>

              {/* Driver quick info */}
              <div className="flex items-center gap-3 bg-white border border-gray-200 rounded-xl px-4 py-3">
                <div className="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold text-sm flex-shrink-0"
                  style={{ backgroundColor: '#8B1A1A' }}>
                  {selected.name?.charAt(0).toUpperCase() || 'D'}
                </div>
                <div>
                  <p className="text-sm font-semibold text-gray-900">{selected.name}</p>
                  <p className="text-xs text-gray-400">{selected.email}</p>
                  {selected.phone && <p className="text-xs text-gray-400">📱 {selected.phone}</p>}
                </div>
              </div>
            </div>

            {/* ── Photos Section ── */}
            <div className="mb-8">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Vehicle & Documents</h2>

              {/* Car photo — large */}
              <div className="bg-white rounded-xl border border-gray-200 overflow-hidden mb-4">
                <div className="px-4 py-3 bg-gray-50 border-b border-gray-100 flex items-center justify-between">
                  <p className="text-xs font-semibold text-gray-600 uppercase tracking-wide">
                    🚗 Vehicle Photo
                  </p>
                  {(selected as any).carPhotoUrl && (
                    <button
                      onClick={() => setPreviewImg((selected as any).carPhotoUrl)}
                      className="text-xs text-primary hover:underline"
                      style={{ color: '#8B1A1A' }}
                    >
                      🔍 Zoom
                    </button>
                  )}
                </div>
                <div className="h-64 flex items-center justify-center bg-gray-50 p-4">
                  {(selected as any).carPhotoUrl ? (
                    <img
                      src={(selected as any).carPhotoUrl}
                      className="max-h-full max-w-full object-contain rounded cursor-pointer hover:opacity-90 transition"
                      onClick={() => setPreviewImg((selected as any).carPhotoUrl)}
                    />
                  ) : (
                    <div className="text-center">
                      <span className="text-6xl mb-3 block">🚗</span>
                      <p className="text-sm text-gray-400">No vehicle photo uploaded</p>
                      <p className="text-xs text-gray-300 mt-1">
                        Enable Firebase Storage to upload photos
                      </p>
                    </div>
                  )}
                </div>
              </div>

              {/* ID photos */}
              <div className="grid grid-cols-2 gap-4">
                <PhotoCard
                  label="🪪 National ID (Front)"
                  url={selected.idFrontUrl}
                  onZoom={setPreviewImg}
                  placeholder="No ID front photo"
                />
                <PhotoCard
                  label="🪪 National ID (Back)"
                  url={selected.idBackUrl}
                  onZoom={setPreviewImg}
                  placeholder="No ID back photo"
                />
              </div>
            </div>

            {/* ── Vehicle Details ── */}
            <div className="bg-white rounded-xl border border-gray-100 p-6 mb-6">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Vehicle Details</h2>
              <div className="grid grid-cols-3 gap-4">
                {[
                  { label: 'Make', value: selected.carMake || '—', icon: '🏭' },
                  { label: 'Model', value: selected.carModel || '—', icon: '🚘' },
                  { label: 'Year', value: selected.carYear || '—', icon: '📅' },
                  { label: 'Color', value: selected.carColor || '—', icon: '🎨' },
                  { label: 'Plate Number', value: selected.plateNumber || '—', icon: '🔢' },
                  { label: 'Verification', value: selected.verificationStatus, icon: '✅' },
                ].map(item => (
                  <div key={item.label} className="bg-gray-50 rounded-xl p-4">
                    <p className="text-xs text-gray-400 uppercase tracking-wide mb-1">
                      {item.icon} {item.label}
                    </p>
                    <p className={`text-sm font-semibold mt-1 capitalize ${
                      item.label === 'Plate Number'
                        ? 'font-mono text-gray-900'
                        : item.label === 'Verification'
                          ? selected.verificationStatus === 'verified'
                            ? 'text-green-600'
                            : selected.verificationStatus === 'pending'
                              ? 'text-yellow-600'
                              : 'text-red-600'
                          : 'text-gray-900'
                    }`}>
                      {item.value}
                    </p>
                  </div>
                ))}
              </div>
            </div>

            {/* ── Driver Performance ── */}
            <div className="bg-white rounded-xl border border-gray-100 p-6">
              <h2 className="text-base font-semibold text-gray-900 mb-4">Driver Performance</h2>
              <div className="grid grid-cols-3 gap-4">
                <div className="rounded-xl p-4 text-white" style={{ backgroundColor: '#8B1A1A' }}>
                  <p className="text-xs text-red-200 uppercase tracking-wide">Total Rides</p>
                  <p className="text-3xl font-bold mt-1">{selected.ridesCount}</p>
                </div>
                <div className="bg-green-50 rounded-xl p-4">
                  <p className="text-xs text-green-600 uppercase tracking-wide">Total Earnings</p>
                  <p className="text-3xl font-bold text-green-700 mt-1">
                    {selected.totalEarnings.toFixed(2)}
                    <span className="text-sm font-normal ml-1">JOD</span>
                  </p>
                </div>
                <div className="bg-blue-50 rounded-xl p-4">
                  <p className="text-xs text-blue-600 uppercase tracking-wide">Avg per Ride</p>
                  <p className="text-3xl font-bold text-blue-700 mt-1">
                    {selected.ridesCount > 0
                      ? (selected.totalEarnings / selected.ridesCount).toFixed(2)
                      : '0.00'}
                    <span className="text-sm font-normal ml-1">JOD</span>
                  </p>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-gray-100 flex items-center gap-3">
                <div className="flex-1 bg-gray-50 rounded-lg p-3">
                  <p className="text-xs text-gray-400 uppercase">Driver Name</p>
                  <p className="text-sm font-semibold text-gray-900 mt-0.5">{selected.name}</p>
                </div>
                <div className="flex-1 bg-gray-50 rounded-lg p-3">
                  <p className="text-xs text-gray-400 uppercase">Email</p>
                  <p className="text-sm font-semibold text-gray-900 mt-0.5 truncate">{selected.email}</p>
                </div>
                <div className="flex-1 bg-gray-50 rounded-lg p-3">
                  <p className="text-xs text-gray-400 uppercase">Phone</p>
                  <p className="text-sm font-semibold text-gray-900 mt-0.5">{selected.phone || '—'}</p>
                </div>
              </div>
            </div>

          </div>
        )}
      </div>
    </div>
  )
}

// ── Reusable Photo Card ────────────────────────────────────────────────────
function PhotoCard({
  label,
  url,
  onZoom,
  placeholder,
}: {
  label: string
  url?: string
  onZoom: (url: string) => void
  placeholder: string
}) {
  return (
    <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <div className="px-4 py-3 bg-gray-50 border-b border-gray-100 flex items-center justify-between">
        <p className="text-xs font-semibold text-gray-600 uppercase tracking-wide">{label}</p>
        {url && (
          <button
            onClick={() => onZoom(url)}
            className="text-xs hover:underline"
            style={{ color: '#8B1A1A' }}
          >
            🔍 Zoom
          </button>
        )}
      </div>
      <div className="p-4 h-44 flex items-center justify-center bg-gray-50">
        {url ? (
          <img
            src={url}
            className="max-h-full max-w-full object-contain rounded cursor-pointer hover:opacity-90 transition"
            onClick={() => onZoom(url)}
          />
        ) : (
          <div className="text-center">
            <span className="text-4xl mb-2 block">🪪</span>
            <p className="text-sm text-gray-400">{placeholder}</p>
            <p className="text-xs text-gray-300 mt-1">Storage not enabled</p>
          </div>
        )}
      </div>
    </div>
  )
}