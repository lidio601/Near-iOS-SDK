# Local background notification

By default the SDK (from version 0.9.33) gives you local iOS notification when your app is in background.

When the user tap the notification you need to react and handle the local notification to show the right content for the user.

Rememeber to ask for the notification permissions.

## Handle local notification from iOS 10

First you need to set the delegate for the `UNUserNotificationCenter`, with the code below you can react to a notification tap.

```swift
// Swift
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let isNear = manager.handleLocalNotificationResponse(response) { (content, recipe, error) in
        if let content = content as? NITContent {
            // Do something
        }
        // Code for other content types
    }
    print("Is a Near local notification: \(isNear)");
    completionHandler()
}
```

```objective-c
// Objective-C
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    BOOL isNear = [self handleLocalNotificationResponse:response completionHandler:^(id  _Nullable content, NITRecipe * _Nullable recipe, NSError * _Nullable error) {
        if ([content isKindOfClass:[NITContent class]]) {
            // Do something
        }
        // Code for other content types
    }];
    NSLog(@"Is a Near local notification: %d", isNear);
    completionHandler();
}
```

## Handle local notification for iOS 9

## How to disable local background notification

You need to set "false" the property `showBackgroundNotification` in the Near Manager instance.
