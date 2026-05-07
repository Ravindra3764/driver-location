# Delivery Tracking — Flutter + GetX

A live delivery-tracking screen built with Flutter, GetX state management, and
`flutter_map` (no Google Maps API required). The app simulates a delivery
partner moving along a fixed route, updates every 3 seconds, gracefully
handles network loss, and shows a smooth gliding marker with the partner's
profile photo.

---

## Features

- Live driver location streamed at a 3 s cadence on a real (OpenStreetMap-
  style) map — no API key needed.
- Status progression: **Searching → Assigned → Arriving → Delivered**, driven
  by a mock backend.
- Smooth marker animation (60 fps tween between ticks with ease-in-out
  easing) so the partner glides instead of jumping.
- Dual-segment route line: traveled (grey) and remaining (primary blue),
  glued to the live marker position.
- Profile-photo marker with pulsing halo. Tap it to open a bottom sheet
  with the partner's name, vehicle, rating, trip count, and call/message
  actions.
- Offline-first behavior:
  - Mock backend keeps simulating in the background.
  - UI freezes the last known location + status snapshot the moment the
    device goes offline.
  - On reconnect, the marker snaps directly to the partner's *current*
    position (not where it stopped) and a "back online" banner appears.
- One-tap restart of the entire lifecycle without a hot restart.
- Distance and ETA always reported in 100-metre increments.

---

## How it works

```
              ┌───────────────────────────────┐
              │   DeliveryTrackingController  │  ← single source of truth
              └──────────────┬────────────────┘
                             │ Rx<...>
        ┌───────────┬────────┴────────┬───────────────┐
        ▼           ▼                 ▼               ▼
 LocationService  DeliveryService  NetworkService  Animation Timer
 (3 s ticks       (status timers   (connectivity_  (60 fps tween
  along mock      drive            plus stream)     between ticks)
  route)          searching →
                  assigned →
                  arriving)
```

1. **Bootstrap** — `DeliveryTrackingBinding` lazy-creates the three
   services and the controller. The controller subscribes to all three
   streams during `onInit`.
2. **Searching** — `DeliveryService` immediately emits the initial
   `searching` state. Location streaming is **not** started yet, so the
   route stays untouched.
3. **Assigned** — after 4 s `DeliveryService` flips to `assigned` and
   attaches a `DriverModel`. `_onDeliveryChanged` detects the
   transition out of `searching` and starts `LocationService`. The
   partner marker appears at the route's start.
4. **Arriving** — 3 s later the status moves to `arriving`. The
   partner ticks along the pre-built route every 3 s while a 60 fps
   tween glides the marker between waypoints.
5. **Delivered** — the controller checks `distance < 30 m` on every
   tick. When reached, `markDelivered()` flips the status, halts the
   ticker, cancels the in-flight tween, and pins the marker on the
   drop point.
6. **Offline** — `NetworkService` (wraps `connectivity_plus`) emits
   `offline`. The controller takes a `_offlineSnapshot` of the
   currently displayed position and status. UI getters now read from
   the snapshot. The mock backend keeps running underneath.
7. **Reconnect** — snapshot is dropped, `latestLocation.refresh()`
   forces UI getters to re-evaluate against the live (post-outage)
   position, and a 2 s "Back online" banner shows.

---

## Project structure

```
lib/
├── main.dart                              entry point
└── app/
    ├── app.dart                           GetMaterialApp shell
    │
    ├── core/
    │   ├── constants/                     theme, colors, typography,
    │   │                                  dimensions, strings
    │   ├── enums/                         delivery_status, network_status
    │   └── utils/                         GeoCalculator (haversine + formatters)
    │
    ├── data/
    │   ├── models/                        driver_model, delivery_model,
    │   │                                  location_update
    │   ├── mock/                          mock_driver_data (route + driver)
    │   └── services/                      location_service, delivery_service,
    │                                      network_service
    │
    ├── modules/delivery_tracking/
    │   ├── bindings/                      DI wiring (lazy services + controller)
    │   ├── controllers/                   DeliveryTrackingController
    │   ├── views/                         DeliveryTrackingView (map + overlays)
    │   └── widgets/                       driver_marker, destination_marker,
    │                                      status_progress, network_banner,
    │                                      delivery_info_card,
    │                                      driver_details_sheet
    │
    └── routes/                            app_pages, app_routes
```

Key principle: **UI never touches services directly.** The controller
is the only bridge. Every widget either uses `GetView<...>` or pulls
state through the controller's reactive getters.

---

## State management (GetX)

| Reactive variable                  | Purpose                                              |
|------------------------------------|------------------------------------------------------|
| `delivery: Rx<DeliveryModel>`      | Current delivery state (id, address, driver, status) |
| `latestLocation: Rxn<LocationUpdate>` | Latest tick from the location service             |
| `animatedDriverPosition: Rxn<LatLng>` | 60 fps interpolated marker position               |
| `networkStatus: Rx<NetworkStatus>` | Online/offline                                      |
| `justReconnected: RxBool`          | Flashes the "back online" banner for 2 s            |
| `isDriverDetailsOpen: RxBool`      | Bottom-sheet visibility                             |

Widgets only rebuild what they observe — the map's `_MapLayer` rebuilds
on position changes, the `StatusProgress` rebuilds on status changes,
the network banner only on connectivity changes.

---

## Running the app

```bash
flutter pub get
flutter run
```

### After Android manifest changes

If you change `AndroidManifest.xml` or add native permissions, do a
clean install:

```bash
flutter clean && flutter run
```

### Tests

```bash
flutter test
```

---

## Networking notes

- Map tiles are loaded from CartoDB Voyager (`basemaps.cartocdn.com`,
  CDN, no API key, free for non-commercial use). OSM's direct tile
  server tends to throttle Android emulators, so this is more reliable.
- Internet is required for tile downloads. Tiles already fetched in a
  session stay in flutter_map's in-memory cache. The route, marker,
  and status views render entirely from local state, so the offline
  flow does not depend on tile availability.
- `connectivity_plus` reports interface-level connectivity (Wi-Fi /
  cellular attached). It does not validate upstream reachability — for
  most demo / interview use that's fine; for production-grade
  reachability detection, layer on a periodic ping or
  `internet_connection_checker_plus`.

### Permissions

Android (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

A `network_security_config.xml` is also bundled to be permissive about
HTTPS certs and cleartext, just to avoid quirks on emulators.

iOS needs no extra Info.plist entries for HTTPS tile loading.

---

## Mock data

`lib/app/data/mock/mock_driver_data.dart` defines:

- `deliveryRoute` — a list of `LatLng` waypoints from a starting
  point in New Delhi to Connaught Place (the drop location). Each
  successive point is one 3-second tick apart.
- `sampleDriver` — a `DriverModel` with name, phone, vehicle,
  rating, trip count, and avatar URL.

To change the route or driver, edit only this file — the rest of the
app reads from these constants.

---

## Restarting the lifecycle

The ↻ button in the top bar calls
`DeliveryTrackingController.restartTracking()`, which:

1. Resets the location service back to waypoint 0.
2. Resets the delivery service back to `searching`.
3. Clears the offline snapshot, animation state, last-known cache.
4. Re-emits the initial state. Location streaming will pick back up
   automatically once status leaves `searching`.

No hot restart required.

---

## Stack

- Flutter (Dart 3.x)
- [`get`](https://pub.dev/packages/get) — state management, DI, routing
- [`flutter_map`](https://pub.dev/packages/flutter_map) — map widget
- [`latlong2`](https://pub.dev/packages/latlong2) — coordinate type
- [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) — OS-level connectivity stream

