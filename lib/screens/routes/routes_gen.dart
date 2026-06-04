import 'package:warehouse_amf/screens/home/home_screen.dart';
import 'package:warehouse_amf/screens/login/login_screen.dart';
import 'package:warehouse_amf/screens/order_details/order_details_page.dart';
import 'package:warehouse_amf/screens/scan/scan_screen_wrapper.dart';
import 'package:warehouse_amf/utils/consts/routes.dart';

generateRoutes() {
  return {
    kRouteLogIn: (context) => const LogInScreen(),
    kRouteHome: (context) => const HomeScreen(),
    kRouteScan: (context) => const ScanScreenWrapper(),
    kRouteOrderDetail: (context) => const OrderDetailsPage()
  };
}
