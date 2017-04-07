# Testing

## Manual recipe trigger

To help with testing, you can manually trigger a recipe.
The `NearSDK` object has a getter for the `cached` recipe list. 
You can get the list of recipes with the method:

```swift
// Swift
manager.recipes()
```

```objective-c
// Objective-C
[manager recipes];
```
Once you pick the recipe you want to test, use this method to trigger it:

```swift
// Swift
let id = recipe.ID
manager.processRecipe(id)
```

```objective-C
// Objective-C
NSString *ID = recipe.ID
[manager processRecipeWithId:ID];
```
## Creating a tester audience (TODO: -)

If you need to test some content, but just with some testers, you can use the profiling features and create actual recipes, selecting the proper segment.
Profile some selected users with a specific user data. For example, set a custom "testing" field to "true" for the test users, then create the proper field mapping in the settings. Now you can target test user by creating a segment in the "WHO" section of a recipe using this field.
