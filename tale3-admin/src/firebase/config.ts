import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: 'AIzaSyCLYu_MXd9zf7GbppQoUjeK6eg8cLtQED8',
  authDomain: 'tale3-971c9.firebaseapp.com',
  projectId: 'tale3-971c9',
  storageBucket: 'tale3-971c9.firebasestorage.app',
  messagingSenderId: '290962167334',
  appId: '1:290962167334:android:a4c4b8afbc4719e4cd38e7',
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);