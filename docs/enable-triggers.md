# Enable triggers

Depending on what recipe triggers you want to use, some setup is necessary.

## Location based Triggers

When you want to start the radar for geofences and beacons call this method:

```swift
// Swift
// call this when you are given the proper permission for scanning (.Always or .InUse)
manager.start()
// to stop the radar call the method manager.stop()
```

```objective-c
// Objective-C
// call this when you are given the proper permission for scanning (.Always or .InUse)
[manager start];
// to stop the radar call the method [manager stop];
```

You must add the `NSLocationAlwaysUsageDescription` or `NSLocationWhenInUseUsageDescription` in the project Info.plist

## Push Triggers

To enable push recipes to reach the user, get a APNs certificate for your app. Export it from your keychain as .p12 and then remove the password then upload it into the appropriate NearIT CMS section.

When you get the token in the app, just give it to the SDK.

```swift
// Swift
manager.setDeviceToken(token)
```

```objective-c
// Objective-C
[manager setDeviceToken:token];
```

To learn how to deal with in-app content see this [section](handle-content.md).
