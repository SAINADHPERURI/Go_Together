const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Triggered when a new join request is created.
 * Sends FCM push notification to the Host.
 */
exports.onJoinRequestCreated = functions.firestore
  .document("joinRequests/{requestId}")
  .onCreate(async (snapshot, context) => {
    const requestData = snapshot.data();
    if (!requestData) return null;

    const hostId = requestData.hostId;
    const requesterName = requestData.userName || "A traveler";
    const destination = requestData.tripDestination || "your trip";

    try {
      const hostDoc = await db.collection("users").doc(hostId).get();
      if (!hostDoc.exists) return null;

      const fcmToken = hostDoc.data().fcmToken;
      if (!fcmToken) return null;

      const payload = {
        notification: {
          title: "New Join Request! 🎒",
          body: `${requesterName} requested to join your trip to ${destination}.`,
        },
        data: {
          tripId: requestData.tripId || "",
          type: "join_request",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      };

      await messaging.sendToDevice(fcmToken, payload);
    } catch (err) {
      functions.logger.error("Error sending join request notification:", err);
    }
    return null;
  });

/**
 * Triggered when a join request status changes (Accepted or Rejected).
 */
exports.onJoinRequestUpdated = functions.firestore
  .document("joinRequests/{requestId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (!before || !after || before.status === after.status) return null;

    const userId = after.userId;
    const destination = after.tripDestination || "the trip";
    const isAccepted = after.status === "accepted";
    const isRejected = after.status === "rejected";

    if (!isAccepted && !isRejected) return null;

    try {
      // 1. Post system greeting in trip chat if accepted
      if (isAccepted && after.tripId) {
        await db
          .collection("trips")
          .doc(after.tripId)
          .collection("messages")
          .add({
            tripId: after.tripId,
            senderId: "system",
            senderName: "GoTogether",
            text: `${after.userName || "A new traveler"} has joined the group! Welcome aboard 🎉`,
            type: "system",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
      }

      // 2. Send push notification to requester
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) return null;

      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) return null;

      const payload = {
        notification: {
          title: isAccepted ? "Join Request Accepted! 🎉" : "Trip Request Update",
          body: isAccepted
            ? `Your request to join the trip to ${destination} was accepted! You can now access the group chat.`
            : `Your request to join the trip to ${destination} was not accepted by the host.`,
        },
        data: {
          tripId: after.tripId || "",
          type: isAccepted ? "request_accepted" : "request_rejected",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      };

      await messaging.sendToDevice(fcmToken, payload);
    } catch (err) {
      functions.logger.error("Error processing join request response:", err);
    }
    return null;
  });

/**
 * Triggered when a new message is posted in a trip group chat.
 * Sends push notifications to all other group members.
 */
exports.onNewChatMessage = functions.firestore
  .document("trips/{tripId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const message = snapshot.data();
    if (!message || message.type === "system") return null;

    const tripId = context.params.tripId;
    const senderId = message.senderId;
    const senderName = message.senderName || "Fellow Traveler";
    const textSnippet = (message.text || "").substring(0, 100);

    try {
      const tripDoc = await db.collection("trips").doc(tripId).get();
      if (!tripDoc.exists) return null;

      const memberIds = tripDoc.data().memberIds || [];
      const recipientIds = memberIds.filter((id) => id !== senderId);

      if (recipientIds.length === 0) return null;

      const recipientDocs = await Promise.all(
        recipientIds.map((id) => db.collection("users").doc(id).get())
      );

      const tokens = recipientDocs
        .filter((doc) => doc.exists && doc.data().fcmToken)
        .map((doc) => doc.data().fcmToken);

      if (tokens.length === 0) return null;

      const payload = {
        notification: {
          title: `${senderName} in ${tripDoc.data().destination || "Trip Group"}`,
          body: textSnippet,
        },
        data: {
          tripId: tripId,
          type: "new_group_message",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      };

      await messaging.sendToDevice(tokens, payload);
    } catch (err) {
      functions.logger.error("Error broadcasting chat push notification:", err);
    }
    return null;
  });
