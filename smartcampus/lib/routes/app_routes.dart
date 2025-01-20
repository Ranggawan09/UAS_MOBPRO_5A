import 'package:get/get.dart';
import 'package:smartcampus/views/register_view.dart';
import '../views/login_view.dart';
import '../views/profile_view.dart';
import '../views/notification_view.dart';
import '../views/home_view.dart';

class AppRoutes {
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const PROFILE = '/profile';
  static const NOTIFICATIONS = '/notifications';
  static const HOME = '/home';

  static final pages = [
    GetPage(
      name: REGISTER,
      page: () => RegisterView(),
    ),
    GetPage(
      name: LOGIN,
      page: () => LoginView(),
    ),
    GetPage(
      name: PROFILE,
      page: () => ProfileView(),
    ),
    GetPage(
      name: NOTIFICATIONS,
      page: () => NotificationView(),
    ),
    GetPage(
      name: HOME,
      page: () => HomeView(),
    ),
  ];
}