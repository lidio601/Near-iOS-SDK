0.9.15 Release notes (2017-05-12)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* None.

### Bugfixes

* Bug fix for the location timer in Geopolis.

0.9.14 Release notes (2017-05-10)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* None.

### Bugfixes

* Various locations fixes.

0.9.13 Release notes (2017-05-09)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* None.

### Bugfixes

* Coupons request fix, profileId was missing.
* "title" for SimpleNotification now isn't mandatory.

0.9.12 Release notes (2017-05-08)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* More logs available for analysis.
* Added "redeemable" date for coupons

### Bugfixes

* "expires" date fix in NITCoupon.
* Fix for feedback reaction cache.

0.9.11 Release notes (2017-05-02)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* Geopolis region trigger improvements.

### Bugfixes

* None.

0.9.10 Release notes (2017-04-28)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* Removed message "Turn on Bluetooth to allow app to connect to accessories".

### Bugfixes

* None.

0.9.9 Release notes (2017-04-28)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* Thread safety and performance improvements for trackings manager.
* Removed "Reachability" logs.

### Bugfixes

* None.

0.9.8 Release notes (2017-04-27)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* None.

### Bugfixes

* Fix an important issue where you could have sevaral different profiles for the same device.
* Fix an issue about too many trackings logs.
* Fixes push notification tracking (notified, engaged).

0.9.7 Release notes (2017-04-27)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* The SDK trackings now have a retry system.

### Bugfixes

* Fix an issue for manager delegate where it was on a background thread, therefore the UI was locked.

0.9.6 Release notes (2017-04-21)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* None.

### Bugfixes

* Fix an issue for Geofence events: the SDK couldn't dispatch events.

0.9.5 Release notes (2017-04-20)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* Enable/Disable logging method (NITLog).

### Bugfixes

* Fix an issue for beacons ranging where you could have several notifications for the same beacon.

0.9.4 Release notes (2017-04-19)
=============================================================

### API Breaking Changes

* None.

### Enhancements

* Trigger log available for Geopolis: you can find a useful log in the console starting with "triggerWithEvent".

### Bugfixes

* Fix an issue for Geopolis event trackings, now the NearIT services have the right trackings.
* Fixed installation sdk_version.

0.9.3 Release notes (2017-04-18)
=============================================================

New NearITSDKSwift pod (CocoaPods).

### API Breaking Changes

* None.

### Enhancements

* None.

### Bugfixes

* None.
