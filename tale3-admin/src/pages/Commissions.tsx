import { useEffect, useState } from 'react'
import { collection, getDocs, doc, updateDoc } from 'firebase/firestore'
import { db } from '../firebase/config'
import { User, Ride } from '../types'

const COMMISSION_RATE = 0.15 // 15%

interface DriverStats {
  driver: User
  rides: Ride[]
  totalEarnings: number
  commissionOwed: number
  rideCount: number
}

export default function Commissions() {
  const [drivers, setDrivers] = useState<User[]>([])
  const [rides, setRides] = useState<Ride[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedMonth, setSelectedMonth] = useState(() => {
    const now = new Date()
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
  })
  const [processingId, setProcessingId] = useState<string | null>(null)
  const [processedIds, setProcessedIds] = useState<Set<string>>(new Set())
  const [selectedDriver, setSelectedDriver] = useState<DriverStats | null>(null)
  const [showCardModal, setShowCardModal] = useState(false)

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    setLoading(true)
    const [usersSnap, ridesSnap] = await Promise.all([
      getDocs(collection(db, 'users')),
      getDocs(collection(db, 'rides')),
    ])
    const allUsers = usersSnap.docs.map(d => ({ uid: d.id, ...d.data() } as User))
    setDrivers(allUsers.filter(u => u.role === 'driver' && u.verificationStatus === 'verified'))
    setRides(ridesSnap.docs.map(d => ({ id: d.id, ...d.data() } as Ride)))
    setLoading(false)
  }

  // Filter rides by selected month
  const ridesInMonth = rides.filter(r => r.date?.startsWith(selectedMonth))

  // Build per-driver stats
  const driverStats: DriverStats[] = drivers.map(driver => {
    const driverRides = ridesInMonth.filter(r => r.driverId === driver.uid)
    const totalEarnings = driverRides.reduce((sum, r) => sum + (r.pricePerSeat * r.bookedSeats), 0)
    const commissionOwed = totalEarnings * COMMISSION_RATE
    return {
      driver,
      rides: driverRides,
      totalEarnings,
      commissionOwed,
      rideCount: driverRides.length,
    }
  }).sort((a, b) => b.commissionOwed - a.commissionOwed)

  const totalCommissionThisMonth = driverStats.reduce((sum, d) => sum + d.commissionOwed, 0)
  const totalEarningsThisMonth = driverStats.reduce((sum, d) => sum + d.totalEarnings, 0)
  const activeDriversThisMonth = driverStats.filter(d => d.rideCount > 0).length

  // Generate month options (last 12 months)
  const monthOptions = Array.from({ length: 12 }, (_, i) => {
    const d = new Date()
    d.setMonth(d.getMonth() - i)
    const value = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
    const label = d.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })
    return { value, label }
  })

  const handleProcessPayment = async (stats: DriverStats) => {
    setProcessingId(stats.driver.uid)
    // Simulate processing delay — in production this would call a payment API
    await new Promise(resolve => setTimeout(resolve, 1500))
    setProcessedIds(prev => new Set([...prev, `${stats.driver.uid}-${selectedMonth}`]))
    setProcessingId(null)
    setShowCardModal(false)
    setSelectedDriver(null)
  }

  const isProcessed = (uid: string) => processedIds.has(`${uid}-${selectedMonth}`)

  if (loading) return (
    <div className="flex items-center justify-center h-full">
      <div className="text-primary font-semibold">Loading commissions...</div>
    </div>
  )

  return (
    <div className="p-8">

      {/* Card Charge Modal */}
      {showCardModal && selectedDriver && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-2xl shadow-2xl p-8 w-full max-w-md">
            <h2 className="text-xl font-bold text-gray-900 mb-1">Process Commission</h2>
            <p className="text-sm text-gray-500 mb-6">
              Charging commission from {selectedDriver.driver.name}'s card
            </p>

            {/* Fake credit card display */}
            <div className="rounded-xl p-5 mb-6 text-white"
              style={{ background: 'linear-gradient(135deg, #5C0A1A, #8B1A1A)' }}>
              <div className="flex justify-between items-start mb-6">
                <div>
                  <p className="text-xs text-red-200 uppercase tracking-widest">Tale3 Driver Card</p>
                  <p className="text-sm font-semibold mt-1">{selectedDriver.driver.name}</p>
                </div>
                <span className="text-2xl">💳</span>
              </div>
              <p className="text-lg font-mono tracking-widest mb-4">
                {selectedDriver.driver.cardNumber
                  ? `**** **** **** ${selectedDriver.driver.cardNumber.slice(-4)}`
                  : '**** **** **** 0000'}
              </p>
              <div className="flex justify-between text-xs text-red-200">
                <span>CARDHOLDER</span>
                <span>EXPIRES</span>
              </div>
              <div className="flex justify-between text-sm font-medium">
                <span>{selectedDriver.driver.name.toUpperCase()}</span>
                <span>{selectedDriver.driver.cardExpiry || '••/••'}</span>
              </div>
            </div>

            {/* Charge summary */}
            <div className="bg-gray-50 rounded-xl p-4 mb-6 space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Driver Earnings ({selectedMonth})</span>
                <span className="font-semibold">{selectedDriver.totalEarnings.toFixed(3)} JOD</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Commission Rate</span>
                <span className="font-semibold">{(COMMISSION_RATE * 100).toFixed(0)}%</span>
              </div>
              <div className="border-t border-gray-200 pt-2 flex justify-between">
                <span className="text-sm font-bold text-gray-900">Amount to Charge</span>
                <span className="text-lg font-bold text-primary" style={{ color: '#8B1A1A' }}>
                  {selectedDriver.commissionOwed.toFixed(3)} JOD
                </span>
              </div>
            </div>

            <div className="flex gap-3">
              <button
                onClick={() => { setShowCardModal(false); setSelectedDriver(null) }}
                className="flex-1 py-3 border border-gray-200 rounded-xl text-sm font-medium text-gray-600 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={() => handleProcessPayment(selectedDriver)}
                disabled={processingId === selectedDriver.driver.uid}
                className="flex-1 py-3 rounded-xl text-sm font-semibold text-white disabled:opacity-50"
                style={{ backgroundColor: '#8B1A1A' }}
              >
                {processingId === selectedDriver.driver.uid
                  ? 'Processing...'
                  : `Charge ${selectedDriver.commissionOwed.toFixed(3)} JOD`}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Header */}
      <div className="flex items-start justify-between mb-8">
        <div>
          <p className="text-xs text-gray-400 uppercase tracking-widest mb-1">Financial Operations</p>
          <h1 className="text-3xl font-bold text-gray-900">Driver Commissions</h1>
          
        </div>

        {/* Month selector */}
        <select
          value={selectedMonth}
          onChange={e => setSelectedMonth(e.target.value)}
          className="border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2"
          style={{ '--tw-ring-color': '#8B1A1A' } as any}
        >
          {monthOptions.map(m => (
            <option key={m.value} value={m.value}>{m.label}</option>
          ))}
        </select>
      </div>

      {/* Stats cards */}
      <div className="grid grid-cols-4 gap-5 mb-8">
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
          <p className="text-xs text-gray-400 uppercase tracking-wide">Total Driver Earnings</p>
          <p className="text-2xl font-bold text-gray-900 mt-1">{totalEarningsThisMonth.toFixed(3)} JOD</p>
          <p className="text-xs text-gray-400 mt-1">Combined this month</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6"
          style={{ backgroundColor: '#8B1A1A' }}>
          <p className="text-xs text-red-200 uppercase tracking-wide">Tale3 Revenue (15%)</p>
          <p className="text-2xl font-bold text-white mt-1">{totalCommissionThisMonth.toFixed(3)} JOD</p>
          <p className="text-xs text-red-200 mt-1">Platform cut this month</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
          <p className="text-xs text-gray-400 uppercase tracking-wide">Active Drivers</p>
          <p className="text-2xl font-bold text-gray-900 mt-1">{activeDriversThisMonth}</p>
          <p className="text-xs text-gray-400 mt-1">Had rides this month</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
          <p className="text-xs text-gray-400 uppercase tracking-wide">Avg Commission / Driver</p>
          <p className="text-2xl font-bold text-gray-900 mt-1">
            {activeDriversThisMonth > 0
              ? (totalCommissionThisMonth / activeDriversThisMonth).toFixed(3)
              : '0.000'} JOD
          </p>
          <p className="text-xs text-gray-400 mt-1">Per active driver</p>
        </div>
      </div>

     

      {/* Drivers Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="px-6 py-5 border-b border-gray-100 flex items-center justify-between">
          <h2 className="text-base font-semibold text-gray-900">
            Driver Earnings — {monthOptions.find(m => m.value === selectedMonth)?.label}
          </h2>
          <span className="text-xs text-gray-400">{driverStats.length} verified drivers</span>
        </div>

        <table className="w-full">
          <thead className="bg-gray-50">
            <tr className="text-xs text-gray-400 uppercase tracking-wide">
              <th className="text-left px-6 py-4">Driver</th>
              <th className="text-left px-6 py-4">Rides</th>
              <th className="text-left px-6 py-4">Total Earnings</th>
              <th className="text-left px-6 py-4">Driver Keeps (85%)</th>
              <th className="text-left px-6 py-4">Tale3 Commission (15%)</th>
              <th className="text-left px-6 py-4">Card</th>
              <th className="text-left px-6 py-4">Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-50">
            {driverStats.length === 0 ? (
              <tr>
                <td colSpan={7} className="text-center py-12 text-gray-400">
                  No verified drivers yet
                </td>
              </tr>
            ) : driverStats.map(stats => (
              <tr key={stats.driver.uid} className="hover:bg-gray-50">
                <td className="px-6 py-4">
                  <div className="flex items-center gap-3">
                    {stats.driver.photoUrl ? (
                      <img src={stats.driver.photoUrl} className="w-9 h-9 rounded-full object-cover" />
                    ) : (
                      <div className="w-9 h-9 rounded-full flex items-center justify-center text-white text-sm font-bold"
                        style={{ backgroundColor: '#8B1A1A' }}>
                        {stats.driver.name?.charAt(0).toUpperCase() || 'D'}
                      </div>
                    )}
                    <div>
                      <p className="text-sm font-semibold text-gray-900">{stats.driver.name}</p>
                      <p className="text-xs text-gray-400">{stats.driver.email}</p>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4">
                  <span className={`text-sm font-semibold ${stats.rideCount === 0 ? 'text-gray-300' : 'text-gray-900'}`}>
                    {stats.rideCount}
                  </span>
                </td>
                <td className="px-6 py-4 text-sm font-semibold text-gray-900">
                  {stats.totalEarnings.toFixed(3)} JOD
                </td>
                <td className="px-6 py-4 text-sm text-green-700 font-semibold">
                  {(stats.totalEarnings * (1 - COMMISSION_RATE)).toFixed(3)} JOD
                </td>
                <td className="px-6 py-4">
                  <span className="text-sm font-bold" style={{ color: '#8B1A1A' }}>
                    {stats.commissionOwed.toFixed(3)} JOD
                  </span>
                </td>
                <td className="px-6 py-4 text-sm text-gray-500 font-mono">
                  {stats.driver.cardNumber
                    ? `**** ${stats.driver.cardNumber.slice(-4)}`
                    : <span className="text-gray-300 font-sans">No card</span>}
                </td>
                <td className="px-6 py-4">
                  {stats.rideCount === 0 ? (
                    <span className="text-xs text-gray-300">No rides</span>
                  ) : isProcessed(stats.driver.uid) ? (
                    <span className="text-xs px-3 py-1.5 rounded-lg bg-green-100 text-green-700 font-semibold">
                      ✓ Charged
                    </span>
                  ) : (
                    <button
                      onClick={() => { setSelectedDriver(stats); setShowCardModal(true) }}
                      disabled={processingId === stats.driver.uid}
                      className="text-xs px-3 py-1.5 rounded-lg font-semibold text-white disabled:opacity-50 transition hover:opacity-90"
                      style={{ backgroundColor: '#8B1A1A' }}
                    >
                      Charge {stats.commissionOwed.toFixed(3)} JOD
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>

          {/* Totals row */}
          {driverStats.length > 0 && (
            <tfoot className="border-t-2 border-gray-200 bg-gray-50">
              <tr>
                <td className="px-6 py-4 text-sm font-bold text-gray-900">TOTAL</td>
                <td className="px-6 py-4 text-sm font-bold text-gray-900">
                  {driverStats.reduce((s, d) => s + d.rideCount, 0)} rides
                </td>
                <td className="px-6 py-4 text-sm font-bold text-gray-900">
                  {totalEarningsThisMonth.toFixed(3)} JOD
                </td>
                <td className="px-6 py-4 text-sm font-bold text-green-700">
                  {(totalEarningsThisMonth * (1 - COMMISSION_RATE)).toFixed(3)} JOD
                </td>
                <td className="px-6 py-4 text-sm font-bold" style={{ color: '#8B1A1A' }}>
                  {totalCommissionThisMonth.toFixed(3)} JOD
                </td>
                <td colSpan={2} />
              </tr>
            </tfoot>
          )}
        </table>
      </div>

  
    </div>
  )
}