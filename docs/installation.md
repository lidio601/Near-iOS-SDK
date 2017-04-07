# Installation #

Minimum Requirements:

- Deployment target: iOS 9

<!-- To start using the SDK, include this in your app *Podfile*  // TODO: -

```ruby
pod 'NMSDK'
```
-->
In the `application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool` method of your AppDelegate class, set the API token to the SDK a String


```swift
// Swift
import NearITSDKSwift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
	...

	let manager = NearManager(apiKey: "<your API token here>")
   
	...
}
```

```objective-c
// Objective-C
#import <NearITSDK/NearITSDK.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...

    NITManager *manager = [NITManager initWithApiKey:"<your API token here>"];

    ...
}
```

You can find the API key on [NearIT web interface](https://go.nearit.com/), under the "SDK Integration" section.

Whenever you want you can sync the recipes with our servers by calling this method:

```swift
// Swift
manager.refreshConfig(completionHandler: { (error) in
    ...
})
```

```objective-c
// Objective-C
[manager refreshConfigWithCompletionHandler:^(NSError* error) {
    ...
}];
```

If the refreshConfig has succeeded, 'error' is nil.
