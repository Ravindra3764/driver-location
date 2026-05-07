import '../constants/app_strings.dart';

enum DeliveryStatus {
  searching,
  assigned,
  arriving,
  delivered;

  String get label {
    switch (this) {
      case DeliveryStatus.searching:
        return AppStrings.statusSearching;
      case DeliveryStatus.assigned:
        return AppStrings.statusAssigned;
      case DeliveryStatus.arriving:
        return AppStrings.statusArriving;
      case DeliveryStatus.delivered:
        return AppStrings.statusDelivered;
    }
  }

  String get hint {
    switch (this) {
      case DeliveryStatus.searching:
        return AppStrings.statusSearchingHint;
      case DeliveryStatus.assigned:
        return AppStrings.statusAssignedHint;
      case DeliveryStatus.arriving:
        return AppStrings.statusArrivingHint;
      case DeliveryStatus.delivered:
        return AppStrings.statusDeliveredHint;
    }
  }

  int get step => index;

  bool get isTerminal => this == DeliveryStatus.delivered;

  DeliveryStatus? get next {
    if (isTerminal) return null;
    return DeliveryStatus.values[index + 1];
  }
}
