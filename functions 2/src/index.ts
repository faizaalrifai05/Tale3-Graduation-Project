/*/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

//import {setGlobalOptions} from "firebase-functions";
//import {onRequest} from "firebase-functions/https";
//import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
//setGlobalOptions({ maxInstances: 10 });

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
import { onDocumentCreated, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

initializeApp();

const db = getFirestore();

async function getToken(userId: string): Promise<string | null> {
  const doc = await db.collection('users').doc(userId).get();
  return doc.data()?.fcmToken ?? null;
}

async function send(token: string, title: string, body: string) {
  try {
    await getMessaging().send({
      token,
      notification: {title, body},
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
  } catch (_) {}
}

// New booking → notify driver
export const onBookingCreated = onDocumentCreated('bookings/{id}', async (event) => {
  const d = event.data?.data();
  if (!d) return;
  const token = await getToken(d.driverId);
  if (!token) return;
  await send(token, 'New Booking!',
    `${d.passengerName} booked ${d.seatsBooked} seat(s) on your ride from ${d.origin} to ${d.destination}.`);
});

// Booking cancelled by passenger → notify driver
export const onBookingCancelled = onDocumentUpdated('bookings/{id}', async (event) => {
  const before = event.data?.before.data();
  const after  = event.data?.after.data();
  if (!before || !after) return;
  if (before.status === after.status || after.status !== 'cancelled') return;

  const token = await getToken(after.driverId);
  if (!token) return;
  await send(token, 'Booking Cancelled',
    `${after.passengerName} cancelled their booking on your ride from ${after.origin} to ${after.destination}.`);
});

// Ride cancelled by driver → notify all passengers
export const onRideCancelled = onDocumentUpdated('rides/{rideId}', async (event) => {
  const before = event.data?.before.data();
  const after  = event.data?.after.data();
  if (!before || !after) return;
  if (before.status === after.status || after.status !== 'cancelled') return;

  const snap = await db.collection('bookings')
    .where('rideId', '==', event.params.rideId)
    .get();

  await Promise.all(snap.docs.map(async (doc) => {
    const b = doc.data();
    const token = await getToken(b.passengerId);
    if (!token) return;
    await send(token, 'Ride Cancelled',
      `Your ride from ${b.origin} to ${b.destination} on ${b.date} was cancelled by the driver.`);
  }));
});

// Driver arrived at pickup → notify all confirmed passengers
export const onDriverArrived = onDocumentUpdated('rides/{rideId}', async (event) => {
  const before = event.data?.before.data();
  const after  = event.data?.after.data();
  if (!before || !after) return;
  if (before.driverArrived === true || after.driverArrived !== true) return;

  const snap = await db.collection('bookings')
    .where('rideId', '==', event.params.rideId)
    .where('status', '==', 'confirmed')
    .get();

  await Promise.all(snap.docs.map(async (doc) => {
    const b = doc.data();
    const token = await getToken(b.passengerId);
    if (!token) return;
    await send(token, 'Your Driver Has Arrived!',
      `${after.driverName} is waiting at ${after.origin}. Please head to the pickup point.`);
  }));
});

// Driver submitted ID verification → notify all admins
export const onIdVerificationSubmitted = onDocumentUpdated('users/{userId}', async (event) => {
  const before = event.data?.before.data();
  const after  = event.data?.after.data();
  if (!before || !after) return;
  if (before.verificationStatus === after.verificationStatus) return;
  if (after.verificationStatus !== 'pending') return;
  if (after.role !== 'driver') return;

  const adminsSnap = await db.collection('users').where('role', '==', 'admin').get();
  await Promise.all(adminsSnap.docs.map(async (doc) => {
    const token = doc.data().fcmToken;
    if (!token) return;
    await send(token, 'New ID Verification Request',
      `${after.name} submitted their ID for verification. Please review it in the admin panel.`);
  }));
});

// New chat message → notify recipient
export const onNewMessage = onDocumentCreated('chats/{chatId}/messages/{msgId}', async (event) => {
  const d = event.data?.data();
  if (!d) return;

  const chatDoc = await db.collection('chats').doc(event.params.chatId).get();
  const participants: string[] = chatDoc.data()?.participants ?? [];
  const recipientId = participants.find((id) => id !== d.senderId);
  if (!recipientId) return;

  const token = await getToken(recipientId);
  if (!token) return;

  const senderDoc = await db.collection('users').doc(d.senderId).get();
  const senderName = senderDoc.data()?.name ?? 'Someone';

  await send(token, senderName, d.text);
});
