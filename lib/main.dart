import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'models/reminder_model.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/landing_page.dart';
import 'screens/register_screen.dart';
import 'screens/full_register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/medication_form_screen.dart';
import 'screens/intake_advice_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/medvault_screen.dart';
import 'screens/family_access_screen.dart';
import 'screens/invite_carebuddy_screen.dart';
import 'screens/invite_pending_screen.dart';
import 'screens/connect_carebuddy_screen.dart';
import 'screens/share_link_screen.dart';
import 'screens/account_screen.dart';
import 'screens/security_and_data_screen.dart';
import 'screens/set_password_screen.dart';
import 'screens/update_password_screen.dart';
import 'screens/account_info_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/upload_documents_screen.dart';
import 'screens/file_upload_screen.dart';
import 'screens/gallery_upload_screen.dart';
import 'screens/camera_upload_screen.dart';
import 'screens/drive_upload_screen.dart';
import 'screens/more_options_reminder_screen.dart';
import 'screens/interval_reminder_screen.dart';
import 'screens/multiple_times_daily_screen.dart';
import 'screens/specific_days_reminder_screen.dart';
import 'screens/cyclic_mode_screen.dart';
import 'screens/inventory_reminder_screen.dart';
import 'screens/treatment_duration_screen.dart';
import 'screens/medication_frequency_screen.dart';
import 'screens/medication_details_screen.dart';
import 'screens/medication_overview_screen.dart';
import 'screens/view_documents_screen.dart';
import 'screens/carebuddy_profile_screen.dart';
import 'screens/app_lock_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔥 [BG] FCM received: ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // 🔐 Request FCM permission
    final settings = await FirebaseMessaging.instance.requestPermission();
    debugPrint("🔐 FCM Permission: ${settings.authorizationStatus}");

    // 🧠 Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 🔔 Foreground Notification Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 [FG] FCM received: ${message.notification?.title}");
      NotificationService.showNotification(
        title: message.notification?.title ?? 'Medease Alert',
        body: message.notification?.body ?? '',
        payload: message.data['payload'],
        screen: message.data['screen'],
      );
    });

    // 📱 Log FCM Token
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint("📱 Device FCM Token: $token");

    NotificationService.navigatorKey = navigatorKey;
    await NotificationService.init();
  } catch (e) {
    debugPrint("❌ Firebase initialization failed: $e");
  }

  runApp(const MedeaseApp());
}

class MedeaseApp extends StatelessWidget {
  const MedeaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medease',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Manrope',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/landing': (context) => const LandingScreen(),
        '/register': (context) => const RegisterScreen(),
        '/full-register': (context) => const FullRegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/reminder': (context) => const ReminderScreen(),
        '/medication-form': (context) => const MedicationFormScreen(),
        '/intake-advice': (context) => const IntakeAdviceScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/medvault': (context) => const MedVaultScreen(),
        '/family-access': (context) => const FamilyAccessScreen(),
        '/invite-carebuddy': (context) => const InviteCareBuddyScreen(),
        '/invite-carebuddy-pending': (context) => const InvitePendingScreen(),
        '/connect-carebuddy': (context) => const ConnectCareBuddyScreen(),
        '/share-link': (context) => const ShareLinkScreen(),
        '/account': (context) => const AccountScreen(),
        '/account-info': (context) => const AccountInfoScreen(),
        '/personal-info': (context) => const PersonalInfoScreen(),
        '/security-data': (context) => const SecurityAndDataScreen(),
        '/set-password': (context) => const SetPasswordScreen(),
        '/update-password': (context) => const UpdatePasswordScreen(),
        '/notification-settings': (context) => const NotificationSettingsScreen(),
        '/medication-overview': (context) => const MedicationOverviewScreen(),
        '/carebuddy-profile': (context) => const CareBuddyProfileScreen(),
        '/app-lock': (context) => const AppLockScreen(),
      },
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        if (args is ReminderModel) {
          switch (settings.name) {
            case '/treatment-duration':
              return MaterialPageRoute(builder: (_) => TreatmentDurationScreen(reminder: args));
            case '/more-options-reminder':
              return MaterialPageRoute(builder: (_) => MoreOptionsReminderScreen(reminder: args));
            case '/interval-reminder':
              return MaterialPageRoute(builder: (_) => IntervalReminderScreen(reminder: args));
            case '/multiple-times-daily':
              return MaterialPageRoute(builder: (_) => MultipleTimesDailyScreen(reminder: args));
            case '/specific-days-reminder':
              return MaterialPageRoute(builder: (_) => SpecificDaysReminderScreen(reminder: args));
            case '/cyclic-mode':
              return MaterialPageRoute(builder: (_) => CyclicModeScreen(reminder: args));
            case '/inventory-reminder':
              return MaterialPageRoute(builder: (_) => InventoryReminderScreen(reminder: args));
            case '/medication-frequency':
              return MaterialPageRoute(builder: (_) => MedicationFrequencyScreen(reminder: args));
            case '/medication-details':
              return MaterialPageRoute(builder: (_) => MedicationDetailsScreen(reminder: args));
          }
        }

        if (args is String) {
          switch (settings.name) {
            case '/upload-documents':
              return MaterialPageRoute(builder: (_) => UploadDocumentsScreen(docType: args));
            case '/upload-file':
              return MaterialPageRoute(builder: (_) => FileUploadScreen(docType: args));
            case '/upload-gallery':
              return MaterialPageRoute(builder: (_) => GalleryUploadScreen(docType: args));
            case '/upload-camera':
              return MaterialPageRoute(builder: (_) => CameraUploadScreen(docType: args));
            case '/upload-drive':
              return MaterialPageRoute(builder: (_) => DriveUploadScreen(docType: args));
          }
        }

        if (args is Map<String, dynamic>) {
          if (settings.name == '/view-documents') {
            return MaterialPageRoute(
              builder: (_) => ViewDocumentsScreen(
                docType: args['docType'],
                userId: args['userId'],
              ),
            );
          }
        }

        return MaterialPageRoute(builder: (_) => const SplashScreen());
      },
    );
  }
}
