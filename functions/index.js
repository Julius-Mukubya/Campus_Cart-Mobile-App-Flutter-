/**
 * Campus Cart — Firebase Cloud Functions
 * 
 * Sends FCM push notifications when:
 * 1. A new notification document is created in users/{userId}/notifications/
 * 2. A new chat message is created in chats/{chatId}/messages/
 * 
 * Deploy: firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// ─────────────────────────────────────────────────────────────────────────
// 1. Notification trigger — sends push when a notification is created
// ─────────────────────────────────────────────────────────────────────────
exports.sendNotificationPush = functions.firestore
  .document('users/{userId}/notifications/{notifId}')
  .onCreate(async (snap, context) => {
    const { userId, notifId } = context.params;
    const data = snap.data();

    if (!data) {
      console.log(`No data for notification ${notifId}`);
      return null;
    }

    const title = data.title || 'Campus Cart';
    const message = data.message || data.body || '';
    const type = data.type || 'notification';
    const referenceId = data.referenceId || data.data?.orderId || data.data?.chatId || '';

    try {
      // Get the recipient's FCM token
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token for user ${userId}`);
        return null;
      }

      const payload = {
        notification: {
          title: title,
          body: message,
        },
        data: {
          type: type,
          referenceId: referenceId,
          title: title,
          message: message,
          notificationId: notifId,
        },
        token: fcmToken,
      };

      const response = await admin.messaging().send(payload);
      console.log(`Notification push sent to ${userId}: ${response}`);
      return response;
    } catch (error) {
      console.error(`Error sending notification push to ${userId}:`, error);
      return null;
    }
  });

// ─────────────────────────────────────────────────────────────────────────
// 2. Chat message trigger — sends push when a new chat message is sent
// ─────────────────────────────────────────────────────────────────────────
exports.sendChatPush = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const { chatId, messageId } = context.params;
    const messageData = snap.data();

    if (!messageData) {
      console.log(`No data for message ${messageId}`);
      return null;
    }

    const senderId = messageData.senderId || '';
    const text = messageData.text || messageData.message || '';
    const senderName = messageData.senderName || 'Someone';

    if (!senderId || !text) {
      console.log(`Chat message ${messageId} missing senderId or text`);
      return null;
    }

    try {
      // Determine recipient: find the other participant in the chat
      const chatDoc = await admin.firestore().collection('chats').doc(chatId).get();
      const chatData = chatDoc.data();

      if (!chatData) {
        console.log(`Chat document ${chatId} not found`);
        return null;
      }

      const participants = chatData.participants || [];
      const recipientId = participants.find(p => p !== senderId);

      if (!recipientId) {
        console.log(`No recipient found for chat ${chatId}`);
        return null;
      }

      // Get recipient's FCM token
      const userDoc = await admin.firestore().collection('users').doc(recipientId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token for user ${recipientId}`);
        return null;
      }

      const payload = {
        notification: {
          title: senderName,
          body: text,
        },
        data: {
          type: 'chat',
          referenceId: chatId,
          title: senderName,
          message: text,
          chatId: chatId,
          senderId: senderId,
        },
        token: fcmToken,
      };

      const response = await admin.messaging().send(payload);
      console.log(`Chat push sent to ${recipientId}: ${response}`);
      return response;
    } catch (error) {
      console.error(`Error sending chat push:`, error);
      return null;
    }
  });