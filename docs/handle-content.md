# Handle recipe content

NearIT takes care of delivering content at the right time, you will just need to handle content presentation. 

## Foreground vs Background

Recipes either deliver content in background or in foreground depending on the technology. Check this table to see how you will be notified.

| Type of trigger                  | Delivery           |
|----------------------------------|--------------------|
| Push (immediate or scheduled)    | Background         |
| Enter and Exit on geofences      | Background         |
| Enter and Exit on beacon regions | Background         |
| Enter in a specific beacon range | Foreground         |

## Handling content

To receive the contents you should appropriately set NearSDK's delegate first.
```swift
// Swift
{
    ...
    manager.delegate = <NearManagerDelegate>
    ...
}

class NearSDKManager : NearManagerDelegate {
    func manager(_ manager: NearManager, eventWithContent content: Any, recipe: NITRecipe) {
        // handle the content
    }

    func manager(_ manager: NearManager, eventFailureWithError error: Error, recipe: NITRecipe) {
        // handle errors (only for information purpose)
    }
}
```

```objective-c
// Objective-C
{
    ...
    manager.delegate = <NearManagerDelegate>
    ...
}

class NearSDKManager<NITManagerDelegate> {
    - (void)manager:(NITManager*)manager eventWithContent:(id)content recipe:(NITRecipe*)recipe {
        // handle the content
    }

    - (void)manager:(NITManager* _Nonnull)manager eventFailureWithError:(NSError* _Nonnull)error recipe:(NITRecipe* _Nonnull)recipe {
        // handle errors (only for information purpose)
    }
}
```

## Push Notifications

Once you have properly setted up push notifications ([learn more](enable-triggers.md)) you will start receiving push notifications from NearIT, to get the recive you must do the following:

```swift
// Swift
class AppDelegate {
...

  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    manager.processRecipe(userInfo)
  }
...
}
```

```objective-c
// Objective-C
class AppDelegate {
...

    - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
        [manager processRecipeWithUserInfo: userInfo];
    }
...
}
```

After the process the `eventWithContent` method will be called with the actual recipe, otherwise `eventFailureWithError` will.

## Trackings // TODO: -

NearIT analytics on recipes are built from trackings describing the status of user engagement with a recipe. The two recipe states are "Notified" and "Engaged" to represent a recipe delivered to the user and a recipe that the user responded to.

Push notifications recipes track themselves as notified, but you should track it yourself for any other case.
You should be able to catch the event when `eventWithContent` is called, there you decide to display or not a notification to the user:
```swift
recipe.notified()
```

After `eventWithContent` is called and you decided to show a notification and then the user is engaged you can track the event calling:
```swift
recipe.engaged()
```

## Recipe objects

When `nearSDKDidEvaluate` gets called you will obtain all the recipe info by the passed argument. This is how a recipe is composed:

- `notificationTitle` returns the notification title if any
- `notificationText` returns the notificaiton text if any

- `reactions` has the accessors to the different WHATs of the recipes with the following getters:

The recipe reactions contains the actual content, it has different accessors and at most one should be a concrete instance. There is an accessor for each kind of **what**:

- `content` returns a `Content` instance representing the rich content if any
- `customObject` returns a `CustomObject` instance representing the custom object if any
- `poll` returns a `Poll` instance representing the poll if any
- `coupon` returns a `Coupon` instance representig the coupon if any
- `feedback` returns a `Feedback` instance representing the feedback request if any

## Recipe Reaction classes

- `Content` for the notification with content, with the following attributes:
    - `text` returns the text content, without processing the html
    - `attributedText` accessor to an already processed text 
    - `videoURL` returns the video link
    - `images` returns a list of *Image* object containing the source links for the images
    - `upload` returns an *Upload* object containing a link to a file uploaded on NearIT if any
    - `audio` returns an *Audio* object containing a link to an audio file uploaded on NearIT if any
    
- `Feedback` with the following getters:
    - `id` returns the feedback request id
    - `question` returns the feedback request string
To give a feedback call this method:
```swift
// Swift
// rating must be an integer between 0 and 5, and you can set a comment string.
manager.sendEvent(feedbackEvent, completionHandler: { (error) in
    ...
})
```

```objective-c
// Objective-C
// rating must be an integer between 0 and 5, and you can set a comment string.
[manager sendEventWithEvent:event completionHandler:^(NSError * _Nullable error) {
    ...
}];
```
    
- `Coupon` with the following getters:
    - `name` returns the coupon name
    - `details` returns the coupon details
    - `value` returns the value string
    - `expiresAt` returns the expiring date
    - `icon` returns an *Image* object containing the source links for the icon
    - `claims` returns a list of *Claim* which are the actual instances for the current profile
    - `claim` utility that returns the first *Claim* available for the profile.
    - a `Claim` is composed by:
        - `profileId` the profile id who owns the coupon instance
        - `serialNumber` the unique number assigned to the coupon instance
        - `claimedAt` a date representing when the coupon has been claimed
        - `redeemedAt` a date representing when the coupon has ben used

    
- `CustomObject` with the following getters:
    - `content` returns the json content as a *[String: AnyObject]*




