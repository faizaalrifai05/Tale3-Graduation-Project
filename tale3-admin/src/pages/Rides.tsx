import { useEffect, useState } from 'react'
import { collection, getDocs, deleteDoc, doc, updateDoc } from 'firebase/firestore'
import { db } from '../firebase/config'
import { Ride } from '../types'

export default function Rides() {
  const [rides, setRides] = useState<Ride[]>([])
  const [filtered, setFiltered] = useState<Ride[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [actionLoading, setActionLoading] = useState<string | null>(null)
  const [selectedRide, setSelectedRide] = useState<Ride | null>(null)

  useEffect(() => {
    fetchRides()
  }, [])

  useEffect(() => {
    let result = rides
    if (statusFilter !== 'all') result = result.filter(r => r.status === statusFilter)
    if (search) result = result.filter(r =>
      r.driverName?.toLowerCase().includes(search.toLowerCase()) ||
      r.origin?.toLowerCase().includes(search.toLowerCase()) ||
      r.destination?.toLowerCase().includes(search.toLowerCase())
    )
    setFiltered(result)
  }, [rides, statusFilter, search])

  const fetchRides = async () => {
    setLoading(true)
    const snap = await getDocs(collection(db, 'rides'))
    const data = snap.docs.map(d => ({ id: d.id, ...d.data() } as Ride))
    setRides(data)
    setLoading(false)
  }

  const handleDelete = async (rideId: string) => {
    if (!confirm('Are you sure you want to delete this ride?')) return
    setActionLoading(rideId)
    await deleteDoc(doc(db, 'rides', rideId))
    setRides(prev => prev.filter(r => r.id !== rideId))
    if (selectedRide?.id === rideId) setSelectedRide(null)
    setActionLoading(null)
  }

  const handleStatusChange = async (ride: Ride, newStatus: string) => {
    setActionLoading(ride.id)
    await updateDoc(doc(db, 'rides', ride.id), { status: newStatus })
    setRides(prev => prev.map(r => r.id === ride.id ? { ...r, status: newStatus } : r))
    if (selectedRide?.id === ride.id) setSelectedRide({ ...selectedRide, status: newStatus })
    setActionLoading(null)
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-700'
      case 'completed': return 'bg-blue-100 text-blue-700'
      case 'cancelled': return 'bg-red-100 text-red-700'
      default: return 'bg-gray-100 text-gray-600'
    }
  }

  const totalRevenue = rides.reduce((sum, r) => sum + (r.pricePerSeat * r.bookedSeats), 0)
  const activeRides = rides.filter(r => r.status === 'active').length
  const completedRides = rides.filter(r => r.status === 'completed').length
  const avgOccupancy = rides.length > 0
    ? Math.round(rides.reduce((sum, r) => sum + (r.totalSeats > 0 ? (r.bookedSeats / r.totalSeats) * 100 : 0), 0) / rides.length)
    : 0

  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <div className="text-primary font-semibold">Loading rides...</div>
    </div>
  )

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-start justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Intercity Rides</h1>
          <p className="text-gray-500 mt-1">Manage and monitor active intercity routes and driver status.</p>
        </div>
        <button
          onClick={fetchRides}
          className="px-4 py-2 border border-gray-200 rounded-lg text-sm text-gray-600 hover:bg-gray-50 transition"
        >
          🔄 Refresh
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4 mb-8">
        <div className="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
          <p className="text-xs text-gray-400 uppercase tracking-wide">Ongoing Rides</p>
          <p className="text-3xl font-bold text-gray-900 mt-1">{activeRides}</p>
        </div>
        <div className="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
          <p className="text-xs text-gray-400 uppercase tracking-wide">Avg Occupancy</p>
          <p className="text-3xl font-bold text-gray-900 mt-1">{avgOccupancy}%</p>
        </div>
        <div className="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
          <p className="text-xs text-gray-400 uppercase tracking-wide">Completed</p>
          <p className="text-3xl font-bold text-gray-900 mt-1">{completedRides}</p>
        </div>
        <div className="bg-white rounded-xl border border-gray-100 p-5 shadow-sm">
          <p className="text-xs text-gray-400 uppercase tracking-wide">Revenue (Total)</p>
          <p className="text-3xl font-bold text-gray-900 mt-1">{totalRevenue} JOD</p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 mb-6">
        <div className="flex items-center gap-4">
          <div className="flex-1 relative">
            <span className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">🔍</span>
            <input
              type="text"
              placeholder="Search rides, drivers, or routes..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
          <select
            value={statusFilter}
            onChange={e => setStatusFilter(e.target.value)}
            className="border border-gray-200 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="all">All Statuses</option>
            <option value="active">Active</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>
        <p className="text-xs text-gray-400 mt-3">Showing {filtered.length} of {rides.length} rides</p>
      </div>

      <div className="flex gap-6">
        {/* Rides Table */}
        <div className="flex-1 bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr className="text-xs text-gray-400 uppercase tracking-wide">
                <th className="text-left px-6 py-4">Driver</th>
                <th className="text-left px-6 py-4">Route</th>
                <th className="text-left px-6 py-4">Date & Time</th>
                <th className="text-left px-6 py-4">Seats</th>
                <th className="text-left px-6 py-4">Price</th>
                <th className="text-left px-6 py-4">Status</th>
                <th className="text-left px-6 py-4">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-12 text-gray-400">No rides found</td>
                </tr>
              ) : filtered.map(ride => (
                <tr
                  key={ride.id}
                  className={`hover:bg-gray-50 transition cursor-pointer ${selectedRide?.id === ride.id ? 'bg-primary-light' : ''}`}
                  onClick={() => setSelectedRide(ride)}
                >
                  <td className="px-6 py-4 text-sm font-medium text-gray-900">{ride.driverName}</td>
                  <td className="px-6 py-4 text-sm text-gray-600">
                    {ride.origin} → {ride.destination}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-600">
                    <p>{ride.date}</p>
                    <p className="text-xs text-gray-400">{ride.time}</p>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <div className="w-16 h-1.5 bg-gray-200 rounded-full overflow-hidden">
                        <div
                          className="h-full bg-primary rounded-full"
                          style={{ width: `${ride.totalSeats > 0 ? (ride.bookedSeats / ride.totalSeats) * 100 : 0}%` }}
                        />
                      </div>
                      <span className="text-xs text-gray-500">{ride.bookedSeats}/{ride.totalSeats}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm font-medium text-gray-900">{ride.pricePerSeat} JOD</td>
                  <td className="px-6 py-4">
                    <span className={`text-xs px-3 py-1 rounded-full font-medium capitalize ${getStatusColor(ride.status)}`}>
                      {ride.status}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <button
                      onClick={e => { e.stopPropagation(); handleDelete(ride.id) }}
                      disabled={actionLoading === ride.id}
                      className="text-xs text-red-500 hover:text-red-700 px-2 py-1 rounded hover:bg-red-50 transition disabled:opacity-40"
                    >
                      {actionLoading === ride.id ? '...' : 'Delete'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Ride Detail Panel */}
        {selectedRide && (
          <div className="w-72 bg-white rounded-2xl border border-gray-100 shadow-sm p-6 flex-shrink-0">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-bold text-gray-900">Ride Details</h3>
              <button onClick={() => setSelectedRide(null)} className="text-gray-400 hover:text-gray-600 text-lg">✕</button>
            </div>

            <div className="space-y-3">
              {[
                { label: 'Driver', value: selectedRide.driverName },
                { label: 'Route', value: `${selectedRide.origin} → ${selectedRide.destination}` },
                { label: 'Date', value: selectedRide.date },
                { label: 'Time', value: selectedRide.time },
                { label: 'Car', value: `${selectedRide.carMake} ${selectedRide.carModel}` },
                { label: 'Color', value: selectedRide.carColor },
                { label: 'Plate', value: selectedRide.plateNumber },
                { label: 'Seats', value: `${selectedRide.bookedSeats} booked / ${selectedRide.totalSeats} total` },
                { label: 'Price/Seat', value: `${selectedRide.pricePerSeat} JOD` },
                { label: 'Revenue', value: `${selectedRide.pricePerSeat * selectedRide.bookedSeats} JOD` },
              ].map(item => (
                <div key={item.label} className="flex justify-between text-sm">
                  <span className="text-gray-400">{item.label}</span>
                  <span className="font-medium text-gray-900 text-right max-w-36">{item.value}</span>
                </div>
              ))}
            </div>

            <div className="mt-4 pt-4 border-t border-gray-100">
              <p className="text-xs text-gray-400 mb-2 uppercase tracking-wide">Change Status</p>
              <div className="flex flex-col gap-2">
                {['active', 'completed', 'cancelled'].map(status => (
                  <button
                    key={status}
                    onClick={() => handleStatusChange(selectedRide, status)}
                    disabled={selectedRide.status === status || actionLoading === selectedRide.id}
                    className={`text-xs py-2 rounded-lg font-medium capitalize transition disabled:opacity-40 ${
                      selectedRide.status === status
                        ? getStatusColor(status) + ' opacity-60'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    {selectedRide.status === status ? `● ${status}` : `Set ${status}`}
                  </button>
                ))}
              </div>
            </div>

            <button
              onClick={() => handleDelete(selectedRide.id)}
              disabled={actionLoading === selectedRide.id}
              className="mt-4 w-full py-2 bg-red-50 text-red-600 rounded-lg text-xs font-medium hover:bg-red-100 transition disabled:opacity-40"
            >
              Delete Ride
            </button>
          </div>
        )}
      </div>
    </div>
  )
}