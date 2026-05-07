import 'package:get/get.dart';

import '../modules/delivery_tracking/bindings/delivery_tracking_binding.dart';
import '../modules/delivery_tracking/views/delivery_tracking_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  AppPages._();

  static const String initial = AppRoutes.tracking;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.tracking,
      page: () => const DeliveryTrackingView(),
      binding: DeliveryTrackingBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
