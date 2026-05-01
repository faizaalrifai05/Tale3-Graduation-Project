import { useEffect, useState } from 'react'
import { collection, getDocs, query, orderBy, limit } from 'firebase/firestore'
import { db } from '../firebase/config'
import { User, Ride } from '../types'
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer
} from 'recharts'

export default function Dashboard() {
  const [users, setUsers] = useState<User[]>([])
  const [rides, setRides] = useState<Ride[]>([])
  const [recentRides, setRecentRides] = useState<Ride[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchData = async () => {
      const [usersSnap, ridesSnap, recentSnap] = await Promise.all([
        getDocs(collection(db, 'users')),
        getDocs(collection(db, 'rides')),
        getDocs(query(collection(db, 'rides'), orderBy('createdAt', 'desc'), limit(5))),
      ])

      const usersData = usersSnap.docs.map(d => ({ uid: d.id, ...d.data() } as User))
      const ridesData = ridesSnap.docs.map(d => ({ id: d.id, ...d.data() } as Ride))
      const recentData = recentSnap.docs.map(d => ({ id: d.id, ...d.data() } as Ride))

      setUsers(usersData)
      setRides(ridesData)
      setRecentRides(recentData)
      setLoading(false)
    }
    fetchData()
  }, [])

  const totalRides = rides.length
  const activeRides = rides.filter(r => r.status === 'active').length
  const newDrivers = users.filter(u => u.role === 'driver').length
  const activePassengers = users.filter(u => u.role === 'passenger').length
  const totalRevenue = rides.reduce((sum, r) => sum + (r.pricePerSeat * r.bookedSeats), 0)

  // Group rides by date for chart
  const chartData = (() => {
    const counts: Record<string, number> = {}
    rides.forEach(r => {
      const date = r.date || 'Unknown'
      counts[date] = (counts[date] || 0) + 1
    })
    return Object.entries(counts).slice(-7).map(([date, count]) => ({ date, rides: count }))
  })()

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-700'
      case 'completed': return 'bg-blue-100 text-blue-700'
      case 'cancelled': return 'bg-red-100 text-red-700'
      default: return 'bg-gray-100 text-gray-700'
    }
  }

  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <div className="text-primary font-semibold">Loading dashboard...</div>
    </div>
  )

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 mt-1">Here's what's happening across the platform today.</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <div className="flex items-center justify-between mb-3">
            <span className="text-2xl">🚗</span>
          </div>
          <p className="text-sm text-gray-500 uppercase tracking-wide">Total Rides</p>
          <p className="text-3xl font-bold text-gray-900 mt-1">{totalRides}</p>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <div className="flex items-center justify-between mb-3">
            <span className="text-2xl">🚀</span>
          </div>
          <p className="text-sm text-gray-500 uppercase tracking-wide">Active Rides</p>
          <p className="text-3xl font-bold text-gray-900 mt-1">{activeRides}</p>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
          <div className="flex items-center justify-between mb-3">
            <span className="text-2xl">👥</span>
          </div>
          <p className="text-sm text-gray-500 uppercase tracking-wide">Total Drivers</p>
          <p className="text-3xl font-bold text-gray-900 mt-1">{newDrivers}</p>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 bg-primary text-white" style={{backgroundColor: '#8B1A1A'}}>
          <div className="flex items-center justify-between mb-3">
            <span className="text-2xl">💰</span>
          </div>
          <p className="text-sm uppercase tracking-wide text-red-200">Total Revenue</p>
          <p className="text-3xl font-bold mt-1">{totalRevenue} JOD</p>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-6">
        {/* Recent Rides Table */}
        <div className="col-span-2 bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-lg font-semibold text-gray-900">Recent Rides</h2>
          </div>
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-400 uppercase tracking-wide border-b border-gray-100">
                <th className="text-left pb-3">Driver</th>
                <th className="text-left pb-3">Route</th>
                <th className="text-left pb-3">Seats</th>
                <th className="text-left pb-3">Price</th>
                <th className="text-left pb-3">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {recentRides.length === 0 ? (
                <tr>
                  <td colSpan={5} className="text-center py-8 text-gray-400">No rides yet</td>
                </tr>
              ) : recentRides.map((ride) => (
                <tr key={ride.id} className="hover:bg-gray-50">
                  <td className="py-4 text-sm font-medium text-gray-900">{ride.driverName}</td>
                  <td className="py-4 text-sm text-gray-600">{ride.origin} → {ride.destination}</td>
                  <td className="py-4 text-sm text-gray-600">{ride.bookedSeats}/{ride.totalSeats}</td>
                  <td className="py-4 text-sm text-gray-600">{ride.pricePerSeat} JOD</td>
                  <td className="py-4">
                    <span className={`text-xs px-3 py-1 rounded-full font-medium capitalize ${getStatusColor(ride.status)}`}>
                      {ride.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Revenue Chart */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-6">Rides Trend</h2>
          {chartData.length === 0 ? (
            <div className="flex items-center justify-center h-40 text-gray-400 text-sm">No data yet</div>
          ) : (
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={chartData}>
                <XAxis dataKey="date" tick={{ fontSize: 10 }} />
                <YAxis tick={{ fontSize: 10 }} />
                <Tooltip />
                <Bar dataKey="rides" fill="#8B1A1A" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}

          {/* Quick Stats */}
          <div className="mt-6 space-y-3">
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">Total Users</span>
              <span className="font-semibold text-gray-900">{users.length}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">Active Passengers</span>
              <span className="font-semibold text-gray-900">{activePassengers}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">Pending Verifications</span>
              <span className="font-semibold text-primary">
                {users.filter(u => u.verificationStatus === 'pending').length}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}