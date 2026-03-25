import 'package:citytrace/pages/journey/list_page.dart';
import 'package:get/get.dart';

import '../../pages/auth/login_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/journey/journey_detail_page.dart';
import '../../pages/journey/note_page.dart';
import '../../pages/about/about_view.dart';

class AppPages {
  static const INITIAL = '/';

  static final routes = [
    GetPage(name: '/', page: () => const HomePage()),
    GetPage(name: '/home', page: () => const HomePage()),
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/journey', page: () => const JourneyDetailPage()),
    GetPage(name: '/note', page: () => const NotePage()),
    GetPage(name: '/list', page: () => const ListPage()),
    GetPage(name: '/about', page: () => const AboutView()),
  ];
}
