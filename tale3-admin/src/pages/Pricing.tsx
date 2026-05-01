import { useEffect, useState } from 'react'
import { collection, getDocs, addDoc, updateDoc, doc, serverTimestamp } from 'firebase/firestore'
import { db } from '../firebase/config'
import { Route } from '../types'

const JORDAN_CITIES = [
  'Amman', 'Zarqa', 'Irbid', 'Aqaba', 'Salt',
  'Madaba', 'Jerash', 'Ajloun', 'Karak', 'Mafraq'
]

export default function Pricing() {
  const [routes, setRoutes] = useState<Route[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [selectedFrom, setSelectedFrom] = useState('Amman')
  const [selectedTo, setSelectedTo] = useState('Zarqa')
  const [basePrice, setBasePrice] = useState('')
  const [editingId, setEditingId] = useState<string | null>(null)
  const [editPrice, setEditPrice] = useState('')
  const [success, setSuccess] = useState('')
  const [error, setError] = useState('')

  useEffect(() => {
    fetchRoutes()
  }, [])

  const fetchRoutes = async () => {
    setLoading(true)
    const snap = await getDocs(collection(db, 'routes'))
    const data = snap.docs.map(d => ({ id: d.id, ...d.data() } as Route))
    setRoutes(data)
    setLoading(false)
  }

  const effectivePrice = basePrice ? parseFloat(basePrice) : 0

  const handleCreateRoute = async () => {
    if (!basePrice || parseFloat(basePrice) <= 0) {
      setError('Please enter a valid base price.')
      return
    }
    if (selectedFrom === selectedTo) {
      setError('Origin and destination cannot be the same.')
      return
    }
    const exists = routes.find(
      r => r.fromCity === selectedFrom && r.toCity === selectedTo
    )
    if (exists) {
      setError('This route already exists.')
      return
    }

    setSaving(true)
    setError('')
    try {
      const newRoute = {
        fromCity: selectedFrom,
        toCity: selectedTo,
        basePrice: parseFloat(basePrice),
        status: 'active',
        createdAt: serverTimestamp(),
      }
      const ref = await addDoc(collection(db, 'routes'), newRoute)
      setRoutes(prev => [...prev, { id: ref.id, ...newRoute, status: 'active' as const }])
      setBasePrice('')
      setSuccess('Route created successfully!')
      setTimeout(() => setSuccess(''), 3000)
    } catch {
      setError('Failed to create route.')
    }
    setSaving(false)
  }

  const handleUpdatePrice = async (routeId: string) => {
    if (!editPrice || parseFloat(editPrice) <= 0) return
    setSaving(true)
    await updateDoc(doc(db, 'routes', routeId), {
      basePrice: parseFloat(editPrice)
    })
    setRoutes(prev => prev.map(r =>
      r.id === routeId ? { ...r, basePrice: parseFloat(editPrice) } : r
    ))
    setEditingId(null)
    setEditPrice('')
    setSuccess('Price updated!')
    setTimeout(() => setSuccess(''), 3000)
    setSaving(false)
  }

  const toggleStatus = async (route: Route) => {
    const newStatus = route.status === 'active' ? 'under_review' : 'active'
    await updateDoc(doc(db, 'routes', route.id), { status: newStatus })
    setRoutes(prev => prev.map(r =>
      r.id === route.id ? { ...r, status: newStatus } : r
    ))
  }

  const handleDeleteRoute = async (routeId: string) => {
    if (!confirm('Are you sure you want to delete this route?')) return
    const { deleteDoc } = await import('firebase/firestore')
    await deleteDoc(doc(db, 'routes', routeId))
    setRoutes(prev => prev.filter(r => r.id !== routeId))
    setSuccess('Route deleted.')
    setTimeout(() => setSuccess(''), 3000)
  }

  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <div className="text-primary font-semibold">Loading pricing...</div>
    </div>
  )

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-start justify-between mb-8">
        <div>
          <p className="text-xs text-gray-400 uppercase tracking-widest mb-1">
            Financial Operations
          </p>
          <h1 className="text-3xl font-bold text-gray-900">Seat Pricing Console</h1>
          <p className="text-gray-500 mt-1">
            Set fixed prices per route. Drivers cannot change these prices.
          </p>
        </div>
      </div>

      {/* Success/Error messages */}
      {success && (
        <div className="mb-6 bg-green-50 text-green-700 px-4 py-3 rounded-lg text-sm">
          ✅ {success}
        </div>
      )}
      {error && (
        <div className="mb-6 bg-red-50 text-red-600 px-4 py-3 rounded-lg text-sm">
          ❌ {error}
        </div>
      )}

      <div className="grid grid-cols-3 gap-6">
        {/* Create Route Form */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-base font-semibold text-primary mb-5 flex items-center gap-2">
            🛣️ Configure Route Pricing
          </h2>

          <div className="space-y-4">
            <div>
              <label className="text-xs text-gray-500 uppercase tracking-wide mb-1 block">
                From City
              </label>
              <select
                value={selectedFrom}
                onChange={e => { setSelectedFrom(e.target.value); setError('') }}
                className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
              >
                {JORDAN_CITIES.map(c => <option key={c}>{c}</option>)}
              </select>
            </div>

            <div>
              <label className="text-xs text-gray-500 uppercase tracking-wide mb-1 block">
                To City
              </label>
              <select
                value={selectedTo}
                onChange={e => { setSelectedTo(e.target.value); setError('') }}
                className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
              >
                {JORDAN_CITIES.map(c => <option key={c}>{c}</option>)}
              </select>
            </div>

            <div>
              <label className="text-xs text-gray-500 uppercase tracking-wide mb-1 block">
                Base Price (JOD)
              </label>
              <input
                type="number"
                value={basePrice}
                onChange={e => { setBasePrice(e.target.value); setError('') }}
                placeholder="0.00"
                min="0"
                step="0.25"
                className="w-full border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>

            {effectivePrice > 0 && (
              <div className="bg-red-50 rounded-lg p-3 border border-red-100">
                <p className="text-xs text-gray-500">Effective Seat Price</p>
                <p className="text-xl font-bold text-primary mt-1">
                  {effectivePrice.toFixed(3)} JOD
                </p>
                <p className="text-xs text-gray-400 mt-1">
                  {selectedFrom} → {selectedTo}
                </p>
                <p className="text-xs text-gray-400 mt-1">
                  Drivers cannot modify this price
                </p>
              </div>
            )}

            <button
              onClick={handleCreateRoute}
              disabled={saving}
              className="w-full bg-primary text-white py-3 rounded-lg font-semibold text-sm hover:bg-opacity-90 transition disabled:opacity-50"
            >
              {saving ? 'Saving...' : '+ Create Route'}
            </button>
          </div>
        </div>

        {/* Active Routes Table */}
        <div className="col-span-2 bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <div className="flex items-center justify-between mb-5">
            <h2 className="text-base font-semibold text-primary">
              Active Route Matrix
            </h2>
            <button
              onClick={fetchRoutes}
              className="text-xs text-gray-400 hover:text-gray-600 flex items-center gap-1"
            >
              🔄 Refresh
            </button>
          </div>

          <table className="w-full">
            <thead className="border-b border-gray-100">
              <tr className="text-xs text-gray-400 uppercase tracking-wide">
                <th className="text-left pb-3">Route Path</th>
                <th className="text-left pb-3">Base Price</th>
                <th className="text-left pb-3">Status</th>
                <th className="text-left pb-3">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {routes.length === 0 ? (
                <tr>
                  <td colSpan={4} className="text-center py-12 text-gray-400">
                    No routes yet. Create your first route!
                  </td>
                </tr>
              ) : routes.map(route => (
                <tr key={route.id} className="hover:bg-gray-50">
                  <td className="py-4 text-sm font-medium text-gray-900">
                    <div className="flex items-center gap-2">
                      <span>{route.fromCity}</span>
                      <span className="text-gray-400">→</span>
                      <span>{route.toCity}</span>
                    </div>
                  </td>
                  <td className="py-4">
                    {editingId === route.id ? (
                      <div className="flex items-center gap-2">
                        <input
                          type="number"
                          value={editPrice}
                          onChange={e => setEditPrice(e.target.value)}
                          className="w-20 border border-gray-200 rounded px-2 py-1 text-sm focus:outline-none focus:ring-1 focus:ring-primary"
                          autoFocus
                        />
                        <button
                          onClick={() => handleUpdatePrice(route.id)}
                          disabled={saving}
                          className="text-xs bg-primary text-white px-2 py-1 rounded disabled:opacity-50"
                        >
                          Save
                        </button>
                        <button
                          onClick={() => { setEditingId(null); setEditPrice('') }}
                          className="text-xs text-gray-400 hover:text-gray-600"
                        >
                          Cancel
                        </button>
                      </div>
                    ) : (
                      <span className="text-sm font-semibold text-gray-900">
                        {route.basePrice?.toFixed(3)} JOD
                      </span>
                    )}
                  </td>
                  <td className="py-4">
                    <span className={`text-xs px-3 py-1 rounded-full font-medium ${
                      route.status === 'active'
                        ? 'bg-green-100 text-green-700'
                        : 'bg-yellow-100 text-yellow-700'
                    }`}>
                      {route.status === 'active' ? '● Active' : '● Under Review'}
                    </span>
                  </td>
                  <td className="py-4">
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => {
                          setEditingId(route.id)
                          setEditPrice(String(route.basePrice))
                        }}
                        className="text-xs text-blue-600 hover:text-blue-800 px-2 py-1 rounded hover:bg-blue-50"
                      >
                        Edit
                      </button>
                      <button
                        onClick={() => toggleStatus(route)}
                        className="text-xs text-gray-500 hover:text-gray-700 px-2 py-1 rounded hover:bg-gray-100"
                      >
                        {route.status === 'active' ? 'Suspend' : 'Activate'}
                      </button>
                      <button
                        onClick={() => handleDeleteRoute(route.id)}
                        className="text-xs text-red-500 hover:text-red-700 px-2 py-1 rounded hover:bg-red-50"
                      >
                        Delete
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          <p className="text-xs text-gray-400 mt-4">
            Showing {routes.length} route{routes.length !== 1 ? 's' : ''}
          </p>

          {/* Info box */}
          <div className="mt-6 bg-blue-50 border border-blue-100 rounded-xl p-4">
            <p className="text-xs text-blue-700 font-semibold mb-1">
              ℹ️ How pricing works
            </p>
            <p className="text-xs text-blue-600">
              When a driver creates a ride, the price is automatically fetched
              from this table based on their origin and destination. Drivers
              cannot change the price — it is fixed by the admin. Passengers
              will see this exact price when browsing rides.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}