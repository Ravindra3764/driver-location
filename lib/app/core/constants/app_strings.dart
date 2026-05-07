class AppStrings {
  AppStrings._();

  static const String appName = 'Live Tracking';
  static const String trackingTitle = 'Track your delivery';

  static const String statusSearching = 'Searching';
  static const String statusAssigned = 'Assigned';
  static const String statusArriving = 'Arriving';
  static const String statusDelivered = 'Delivered';

  static const String statusSearchingHint = 'Looking for a nearby delivery partner...';
  static const String statusAssignedHint = 'Partner is preparing your order.';
  static const String statusArrivingHint = 'Your order is on the way.';
  static const String statusDeliveredHint = 'Your order has arrived. Enjoy!';

  static const String offlineTitle = 'You are offline';
  static const String offlineMessage = 'Showing last known location and status.';
  static const String reconnectingMessage = 'Back online. Resuming live updates...';

  static const String driverDetailsTitle = 'Delivery Partner';
  static const String callDriver = 'Call';
  static const String messageDriver = 'Message';
  static const String vehicleLabel = 'Vehicle';
  static const String ratingLabel = 'Rating';
  static const String tripsLabel = 'Trips';
  static const String etaLabel = 'ETA';
  static const String distanceLabel = 'Distance';
  static const String tapMarkerHint = 'Tap the partner marker for details';
}
