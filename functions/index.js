const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.onNewMessage = onDocumentCreated(
  'chats/{chatId}/messages/{messageId}',
  async (event) => {
    const message = event.data.data();
    const { chatId } = event.params;

    const senderId = message.senderId;
    const text = message.text;

    // Get the chat document to find the recipient
    const chatDoc = await getFirestore().collection('chats').doc(chatId).get();
    if (!chatDoc.exists) return;

    const chatData = chatDoc.data();
    const participants = chatData.participants || [];
    const participantNames = chatData.participantNames || {};

    // Recipient is the participant who is NOT the sender
    const recipientId = participants.find((uid) => uid !== senderId);
    if (!recipientId) return;

    // Get recipient's FCM token
    const recipientDoc = await getFirestore().collection('users').doc(recipientId).get();
    if (!recipientDoc.exists) return;

    const fcmToken = recipientDoc.data().fcmToken;
    if (!fcmToken) return;

    const senderName = participantNames[senderId] || 'Someone';

    // Send the push notification
    await getMessaging().send({
      token: fcmToken,
      notification: {
        title: senderName,
        body: text.length > 100 ? text.substring(0, 100) + '...' : text,
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'chat_messages',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      },
      apns: {
        payload: {
          aps: { sound: 'default' },
        },
      },
      data: {
        chatId: chatId,
        senderId: senderId,
        type: 'chat_message',
      },
    });
  }
);
