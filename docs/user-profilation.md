# User profiling (TODO: -)

NearIT creates an anonymous profile for every user of your app. You can choose to add data to user profile. This data will be available inside recipes to allow the creation of user targets.

## Send user-data to NearIT

We automatically create an anonymous profile for every installation of the app. You can check that a profile was created by checking the existence of a profile ID.
```swift
let profileId = NearSDK.Profile.current
```

To explicitly register a new user in our platform call the method:
```swift
NearSDK.Profile.requestNew() { (success) in
    // see the success boolean to know if the profile was created 
}
```
Calling this method multiple times *will create* multiple profiles.

After the profile is created set user data:
```swift
let datapoint = NearAPI.Segmentation.DataPoint(key: "gender", value: "M")
NearSDK.Profile.add(dataPoints: [datapoint]) { (success) in
    // callback on operation finish
}
```

The methods accepts an array of DataPoint, so you can insert the datapoints all together.

## Link external data to a NearIT profile

You might want to keep a reference between the data hosted on your system and NearIT data.
You can do it by setting the user ID explicitly. 
```swift
NearSDK.Profile.current = <your profile id>
```
You can then set the relevant user-data to this profile with the aforementioned methods.

This way you can allow the user to share its profile along different installations of the app.
Please keep in mind that you will be responsible of storing our profile identifier in your system.
