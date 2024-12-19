import 'package:hedieaty/services/global_notifications.dart';

class UserManager {

  static FCMService? fcmService;

  static void updateFCMService(FCMService fcms) {
    fcmService = fcms;
  }
}