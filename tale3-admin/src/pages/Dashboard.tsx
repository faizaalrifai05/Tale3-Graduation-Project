import { useEffect, useState } from 'react'
import { collection, getDocs, query, orderBy, limit } from 'firebase/firestore'
import { db } from '../firebase/config'
import { User, Ride } from '../types'
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend
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
      setUsers(usersSnap.docs.map(d => ({ uid: d.id, ...d.data() } as User)))
      setRides(ridesSnap.docs.map(d => ({ id: d.id, ...d.data() } as Ride)))
      setRecentRides(recentSnap.docs.map(d => ({ id: d.id, ...d.data() } as Ride)))
      setLoading(false)
    }
    fetchData()
  }, [])

  // ── Core Stats ─────────────────────────────────────────────────────────────
  const totalRides = rides.length
  const activeRides = rides.filter(r => r.status === 'active').length
  const completedRides = rides.filter(r => r.status === 'completed').length
  const cancelledRides = rides.filter(r => r.status === 'cancelled').length
  const totalDrivers = users.filter(u => u.role === 'driver').length
  const totalPassengers = users.filter(u => u.role === 'passenger').length
  const blockedUsers = users.filter(u => u.isBlocked).length
  const pendingVerifications = users.filter(u => u.verificationStatus === 'pending').length
  const totalRevenue = rides.reduce((sum, r) => sum + (r.pricePerSeat * r.bookedSeats), 0)

  // ── Occupancy Rate ─────────────────────────────────────────────────────────
  const avgOccupancy = rides.length > 0
    ? Math.round(rides.reduce((sum, r) => sum + (r.totalSeats > 0 ? (r.bookedSeats / r.totalSeats) * 100 : 0), 0) / rides.length)
    : 0

  // ── Cancellation Rate ──────────────────────────────────────────────────────
  const cancellationRate = totalRides > 0
    ? Math.round((cancelledRides / totalRides) * 100)
    : 0

  // ── Rides by Status (pie chart) ────────────────────────────────────────────
  const rideStatusData = [
    { name: 'Active', value: activeRides, color: '#22c55e' },
    { name: 'Completed', value: completedRides, color: '#3b82f6' },
    { name: 'Cancelled', value: cancelledRides, color: '#ef4444' },
  ].filter(d => d.value > 0)

  // ── Driver Verification Status (pie chart) ─────────────────────────────────
  const driverVerificationData = [
    { name: 'Verified', value: users.filter(u => u.role === 'driver' && u.verificationStatus === 'verified').length, color: '#22c55e' },
    { name: 'Pending', value: users.filter(u => u.role === 'driver' && u.verificationStatus === 'pending').length, color: '#f59e0b' },
    { name: 'Rejected', value: users.filter(u => u.role === 'driver' && u.verificationStatus === 'rejected').length, color: '#ef4444' },
    { name: 'Unsubmitted', value: users.filter(u => u.role === 'driver' && u.verificationStatus === 'unsubmitted').length, color: '#9ca3af' },
  ].filter(d => d.value > 0)

  // ── Top Routes ─────────────────────────────────────────────────────────────
  const topRoutes = (() => {
    const counts: Record<string, { rides: number; revenue: number }> = {}
    rides.forEach(r => {
      const key = `${r.origin} → ${r.destination}`
      if (!counts[key]) counts[key] = { rides: 0, revenue: 0 }
      counts[key].rides++
      counts[key].revenue += r.pricePerSeat * r.bookedSeats
    })
    return Object.entries(counts)
      .sort((a, b) => b[1].rides - a[1].rides)
      .slice(0, 5)
      .map(([route, data]) => ({ route, ...data }))
  })()

  // ── Rides by Date (bar chart) ──────────────────────────────────────────────
  const ridesByDate = (() => {
    const counts: Record<string, number> = {}
    rides.forEach(r => {
      const date = r.date || 'Unknown'
      counts[date] = (counts[date] || 0) + 1
    })
    return Object.entries(counts)
      .sort((a, b) => a[0].localeCompare(b[0]))
      .slice(-7)
      .map(([date, count]) => ({ date, rides: count }))
  })()

  // ── User Growth (drivers vs passengers) ───────────────────────────────────
  const userTypeData = [
    { name: 'Passengers', value: totalPassengers, color: '#8B1A1A' },
    { name: 'Drivers', value: totalDrivers, color: '#5C0A1A' },
  ]

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
    <div className="p-8 space-y-8">

      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 mt-1">Platform overview and analytics.</p>
      </div>

      {/* ── Alert Banner for urgent items ── */}
      {(pendingVerifications > 0 || blockedUsers > 0) && (
        <div className="grid grid-cols-2 gap-4">
          {pendingVerifications > 0 && (
            <div className="bg-yellow-50 border border-yellow-200 rounded-xl px-5 py-4 flex items-center gap-3">
              <span className="text-2xl">⏳</span>
              <div>
                <p className="text-sm font-bold text-yellow-800">
                  {pendingVerifications} Driver{pendingVerifications > 1 ? 's' : ''} Awaiting Verification
                </p>
                <p className="text-xs text-yellow-600 mt-0.5">
                  Review pending applications in the Verification tab
                </p>
              </div>
            </div>
          )}
          {blockedUsers > 0 && (
            <div className="bg-red-50 border border-red-200 rounded-xl px-5 py-4 flex items-center gap-3">
              <span className="text-2xl">🚫</span>
              <div>
                <p className="text-sm font-bold text-red-800">
                  {blockedUsers} Blocked User{blockedUsers > 1 ? 's' : ''}
                </p>
                <p className="text-xs text-red-600 mt-0.5">
                  Manage blocked accounts in User Management
                </p>
              </div>
            </div>
          )}
        </div>
      )}

      {/* ── Top Stats Row ── */}
      <div className="grid grid-cols-4 gap-5">
        <StatCard icon="🚗" label="Total Rides" value={totalRides.toString()} />
        <StatCard icon="👥" label="Total Users" value={users.length.toString()} sub={`${totalDrivers} drivers · ${totalPassengers} passengers`} />
        <StatCard icon="📊" label="Avg Occupancy" value={`${avgOccupancy}%`} sub="seats filled per ride" />
        <StatCard icon="💰" label="Total Revenue" value={`${totalRevenue.toFixed(2)} JOD`} dark />
      </div>

      {/* ── Second Stats Row ── */}
      <div className="grid grid-cols-4 gap-5">
        <StatCard icon="✅" label="Completed Rides" value={completedRides.toString()} />
        <StatCard icon="🚀" label="Active Rides" value={activeRides.toString()} />
        <StatCard icon="❌" label="Cancellation Rate" value={`${cancellationRate}%`} sub={`${cancelledRides} cancelled`} warn={cancellationRate > 20} />
        <StatCard icon="⏳" label="Pending Verifications" value={pendingVerifications.toString()} warn={pendingVerifications > 0} />
      </div>

      {/* ── Charts Row 1 ── */}
      <div className="grid grid-cols-3 gap-6">

        {/* Rides Trend */}
        <div className="col-span-2 bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-base font-semibold text-gray-900 mb-5">📅 Rides by Date</h2>
          {ridesByDate.length === 0 ? (
            <div className="flex items-center justify-center h-48 text-gray-400 text-sm">No ride data yet</div>
          ) : (
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={ridesByDate}>
                <XAxis dataKey="date" tick={{ fontSize: 10 }} />
                <YAxis tick={{ fontSize: 10 }} allowDecimals={false} />
                <Tooltip />
                <Bar dataKey="rides" fill="#8B1A1A" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Ride Status Pie */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-base font-semibold text-gray-900 mb-5">🔄 Ride Status</h2>
          {rideStatusData.length === 0 ? (
            <div className="flex items-center justify-center h-48 text-gray-400 text-sm">No rides yet</div>
          ) : (
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie
                  data={rideStatusData}
                  cx="50%"
                  cy="50%"
                  innerRadius={55}
                  outerRadius={85}
                  paddingAngle={3}
                  dataKey="value"
                >
                  {rideStatusData.map((entry, index) => (
                    <Cell key={index} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend iconType="circle" iconSize={8} />
              </PieChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>

      {/* ── Charts Row 2 ── */}
      <div className="grid grid-cols-3 gap-6">

        {/* Driver Verification Status */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-base font-semibold text-gray-900 mb-5">🛡️ Driver Verifications</h2>
          {driverVerificationData.length === 0 ? (
            <div className="flex items-center justify-center h-48 text-gray-400 text-sm">No drivers yet</div>
          ) : (
            <ResponsiveContainer width="100%" height={200}>
              <PieChart>
                <Pie
                  data={driverVerificationData}
                  cx="50%"
                  cy="50%"
                  innerRadius={50}
                  outerRadius={80}
                  paddingAngle={3}
                  dataKey="value"
                >
                  {driverVerificationData.map((entry, index) => (
                    <Cell key={index} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend iconType="circle" iconSize={8} />
              </PieChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* User Type Split */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-base font-semibold text-gray-900 mb-5">👤 User Breakdown</h2>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={userTypeData} layout="vertical">
              <XAxis type="number" tick={{ fontSize: 10 }} allowDecimals={false} />
              <YAxis dataKey="name" type="category" tick={{ fontSize: 12 }} width={80} />
              <Tooltip />
              <Bar dataKey="value" radius={[0, 6, 6, 0]}>
                {userTypeData.map((entry, index) => (
                  <Cell key={index} fill={entry.color} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
          <div className="mt-4 pt-4 border-t border-gray-100 space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">Blocked Users</span>
              <span className={`font-semibold ${blockedUsers > 0 ? 'text-red-600' : 'text-gray-900'}`}>
                {blockedUsers}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">Avg Revenue / Ride</span>
              <span className="font-semibold text-gray-900">
                {totalRides > 0 ? (totalRevenue / totalRides).toFixed(2) : '0.00'} JOD
              </span>
            </div>
          </div>
        </div>

        {/* Top Routes */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <h2 className="text-base font-semibold text-gray-900 mb-5">🗺️ Top Routes</h2>
          {topRoutes.length === 0 ? (
            <div className="flex items-center justify-center h-48 text-gray-400 text-sm">No rides yet</div>
          ) : (
            <div className="space-y-3">
              {topRoutes.map((route, i) => (
                <div key={i} className="flex items-center gap-3">
                  <span className="text-xs font-bold text-gray-400 w-4">{i + 1}</span>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-gray-800 truncate">{route.route}</p>
                    <div className="mt-1 h-1.5 bg-gray-100 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-primary rounded-full"
                        style={{
                          width: `${topRoutes[0].rides > 0 ? (route.rides / topRoutes[0].rides) * 100 : 0}%`,
                          backgroundColor: '#8B1A1A'
                        }}
                      />
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-xs font-bold text-gray-900">{route.rides} rides</p>
                    <p className="text-xs text-gray-400">{route.revenue.toFixed(0)} JOD</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* ── Recent Rides Table ── */}
      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
        <h2 className="text-base font-semibold text-gray-900 mb-5">🕐 Recent Rides</h2>
        <table className="w-full">
          <thead>
            <tr className="text-xs text-gray-400 uppercase tracking-wide border-b border-gray-100">
              <th className="text-left pb-3">Driver</th>
              <th className="text-left pb-3">Route</th>
              <th className="text-left pb-3">Date</th>
              <th className="text-left pb-3">Seats</th>
              <th className="text-left pb-3">Price</th>
              <th className="text-left pb-3">Revenue</th>
              <th className="text-left pb-3">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-50">
            {recentRides.length === 0 ? (
              <tr>
                <td colSpan={7} className="text-center py-8 text-gray-400">No rides yet</td>
              </tr>
            ) : recentRides.map((ride) => (
              <tr key={ride.id} className="hover:bg-gray-50">
                <td className="py-4 text-sm font-medium text-gray-900">{ride.driverName}</td>
                <td className="py-4 text-sm text-gray-600">{ride.origin} → {ride.destination}</td>
                <td className="py-4 text-sm text-gray-600">{ride.date}</td>
                <td className="py-4 text-sm text-gray-600">{ride.bookedSeats}/{ride.totalSeats}</td>
                <td className="py-4 text-sm text-gray-600">{ride.pricePerSeat} JOD</td>
                <td className="py-4 text-sm font-semibold text-gray-900">
                  {(ride.pricePerSeat * ride.bookedSeats).toFixed(2)} JOD
                </td>
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

    </div>
  )
}

// ── Reusable Stat Card ─────────────────────────────────────────────────────
function StatCard({
  icon, label, value, sub, dark, warn
}: {
  icon: string
  label: string
  value: string
  sub?: string
  dark?: boolean
  warn?: boolean
}) {
  return (
    <div className={`rounded-2xl p-6 shadow-sm border ${
      dark
        ? 'border-0 text-white'
        : warn
          ? 'bg-yellow-50 border-yellow-200'
          : 'bg-white border-gray-100'
    }`}
    style={dark ? { backgroundColor: '#8B1A1A' } : {}}
    >
      <span className="text-2xl">{icon}</span>
      <p className={`text-xs uppercase tracking-wide mt-3 ${
        dark ? 'text-red-200' : warn ? 'text-yellow-600' : 'text-gray-500'
      }`}>
        {label}
      </p>
      <p className={`text-3xl font-bold mt-1 ${
        dark ? 'text-white' : warn ? 'text-yellow-800' : 'text-gray-900'
      }`}>
        {value}
      </p>
      {sub && (
        <p className={`text-xs mt-1 ${
          dark ? 'text-red-200' : warn ? 'text-yellow-600' : 'text-gray-400'
        }`}>
          {sub}
        </p>
      )}
    </div>
  )
}