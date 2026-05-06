export interface User {
  uid: string;
  name: string;
  email: string;
  role: 'driver' | 'passenger' | 'admin';
  phone: string;
  photoUrl: string;
  verificationStatus: 'unsubmitted' | 'pending' | 'verified' | 'rejected';
  idFrontUrl: string;
  idBackUrl: string;
  isBlocked: boolean;
  createdAt: any;
  carMake?: string;
  carModel?: string;
  carYear?: string;
  carColor?: string;
  plateNumber?: string;
}

export interface Ride {
  id: string;
  driverId: string;
  driverName: string;
  origin: string;
  destination: string;
  date: string;
  time: string;
  totalSeats: number;
  bookedSeats: number;
  pricePerSeat: number;
  status: string;
  createdAt: any;
  carMake: string;
  carModel: string;
  carColor: string;
  plateNumber: string;
}

export interface Route {
  id: string;
  fromCity: string;
  toCity: string;
  basePrice: number;
  status: 'active' | 'under_review';
}