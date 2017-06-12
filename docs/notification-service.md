# Notification Service Extension

From iOS 10 you can modifies the content of a remote notification before it is delivered to the user.

The first thing you have to do is to create a "Notification Service Extension" as a new target for your app, next you need to follow this 4 steps:

* Add an "App group" to your target app and notification service
* Set the group to your Near Manager object
* Instantiate the Near Manager in the notification service
* Get Near content from the notification request

## Add an App Group

Under the "Capabilities" section you have to add an App Group for your target app and then use the same for your notification service target, you can see [here](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW61) how to do it.

## Set the group to Near Manager

The row after you create the Near Manager instance, you can set the just created group by passing the name of the group.

```swift
// Swift
manager?.setSuiteName("<my group>")
```

```objective-c
// Objective-C
[manager setSuiteName:"<my group>"];
```

## Instantiate the Near Manager in the notification service

In the code of your notification servie you can instantiate the Near Manager with this code:

```swift
// Swift
manager = NearManager(suiteName: "<my group>")
```

```objective-c
// Objective-C
NITManager *manager = [[NITManager alloc] initWithSuiteName:@"<my group>"];
```

## Get Near content

You can get Near content with the processRecipe method, the "content" variable is what are you looking for.

```swift
// Swift
nearManager.processRecipe(request.content.userInfo) { (content, recipe, error) in
    // Put your code here
}
```

```objective-c
// Objective-C
[self processRecipeWithUserInfo:request.content.userInfo completion:^(id  _Nullable object, NITRecipe * _Nullable recipe, NSError * _Nullable error) {
    // Put your code here
}];
```
