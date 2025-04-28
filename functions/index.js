const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendReminderNotification = functions.firestore
  .document('users/{userId}/reminders/{reminderId}')
  .onCreate(async (snap, context) => {
    const reminder = snap.data();
    const userId = context.params.userId;
    const reminderId = context.params.reminderId;

    const fcmToken = reminder.fcmToken;

    if (!fcmToken) {
      console.log("❌ No FCM token found in reminder for user:", userId);
      return;
    }

    const medicineName = reminder.medicineName || "Medication";
    const dose = reminder.dose || 1;
    const unit = reminder.unit || "";
    const time = reminder.times?.[0] || "Scheduled time";

    const message = {
      token: fcmToken,
      notification: {
        title: `💊 Time to take ${medicineName}`,
        body: `${dose} ${unit} at ${time}`,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "fcm_channel", // Must match your AndroidManifest
          sound: "default",
          clickAction: "FLUTTER_NOTIFICATION_CLICK", // Required for flutter_local_notifications
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
      data: {
        screen: 'medication-overview',
        payload: reminderId,
      },
    };

    try {
      await admin.messaging().send(message);
      console.log("✅ Push sent to", fcmToken);
    } catch (err) {
      console.error("❌ Error sending push notification:", err);
    }
  });
