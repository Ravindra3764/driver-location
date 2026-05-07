import 'package:get/get.dart';

import '../../../data/services/delivery_service.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/network_service.dart';
import '../controllers/delivery_tracking_controller.dart';

class DeliveryTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NetworkService>(() => NetworkService(), fenix: true);
    Get.lazyPut<LocationService>(() => LocationService(), fenix: true);
    Get.lazyPut<DeliveryService>(() => DeliveryService(), fenix: true);
    Get.lazyPut<DeliveryTrackingController>(
      () => DeliveryTrackingController(
        locationService: Get.find<LocationService>(),
        networkService: Get.find<NetworkService>(),
        deliveryService: Get.find<DeliveryService>(),
      ),
    );
  }
}
