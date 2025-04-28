import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class CareBuddyService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Invite a CareBuddy (adds to /carebuddy_users/<carebuddy_uid>/connections/<user_uid>)
  static Future<void> inviteCareBuddy({
    required String carebuddyEmail,
    required String name,
    required String phone,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("❌ No authenticated user.");
      return;
    }

    final userId = currentUser.uid;
    print("🔍 Current user ID: $userId");

    // 1. Get CareBuddy UID from their email
    final carebuddyUid = await _getCareBuddyUidFromEmail(carebuddyEmail);
    if (carebuddyUid == null) {
      print('❌ CareBuddy not found for $carebuddyEmail');
      throw Exception("CareBuddy not registered");
    }
    print("✅ Found CareBuddy UID: $carebuddyUid");

    // 2. Generate dynamic invite link
    final inviteLink = await _createDynamicLink(userId, carebuddyUid);
    print("🔗 Generated invite link: $inviteLink");

    // 3. Save invitation under CareBuddy
    final connectionRef = _firestore
        .collection('carebuddy_users')
        .doc(carebuddyUid)
        .collection('connections')
        .doc(userId);

    await connectionRef.set({
      'name': name,
      'phone': phone,
      'inviteLink': inviteLink,
      'inviteStatus': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('✅ CareBuddy invite saved to Firestore!');
  }

  /// Get latest pending invite where current user is the sender
  static Future<Map<String, dynamic>?> getPendingInvite() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final snapshot = await _firestore
        .collectionGroup('connections')
        .where(FieldPath.documentId, isEqualTo: userId)
        .where('inviteStatus', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      print("📥 Found pending invite for user: $userId");
      return {
        'data': snapshot.docs.first.data(),
        'docId': snapshot.docs.first.id,
        'parentId': snapshot.docs.first.reference.parent.parent?.id,
      };
    }

    print("📭 No pending invite found for user: $userId");
    return null;
  }

  /// Delete invite by sender
  static Future<void> deleteInvite(String carebuddyUid) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('carebuddy_users')
        .doc(carebuddyUid)
        .collection('connections')
        .doc(userId)
        .delete();

    print("🗑️ Invite deleted by user $userId for carebuddy $carebuddyUid");
  }

  /// 🔐 Private method to create Firebase Dynamic Link
  static Future<String> _createDynamicLink(String userId, String carebuddyUid) async {
    final link = Uri.parse(
      'https://medeaseapp.page.link/carebuddy?userId=$userId&carebuddyId=$carebuddyUid',
    );

    final dynamicLinkParams = DynamicLinkParameters(
      uriPrefix: 'https://medeaseapp.page.link',
      link: link,
      androidParameters: AndroidParameters(
        packageName: 'com.example.medease',
      ),
      iosParameters: IOSParameters(
        bundleId: 'com.example.medease',
        appStoreId: '123456789', // ✅ Update this if your iOS version exists
      ),
    );

    final shortLink = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    return shortLink.shortUrl.toString();
  }

  /// 🔍 Secure lookup to map CareBuddy Email → UID
  static Future<String?> _getCareBuddyUidFromEmail(String email) async {
    final result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      final uid = result.docs.first.id;
      print("📧 Found user with email $email → UID: $uid");
      return uid;
    }

    print("❌ No user found with email $email");
    return null;
  }
}
