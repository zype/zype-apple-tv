## Zype Apple TV Recipe

## Creating New App with the SDK

1. In order to create an Apple TV app using the SDK, you will need to create a Apple TV app on the Zype platform. If you have not done this you can do that on the Zype platform in the Dashboard in the __Manage Apps__ tab under __Publish__. You will see a button to create a new app; just follow the instructions there.

2. Once you have your Apple TV app created on the platform, click on get bundle and the bundle will be emailed to you. Another option is to reload the page and click on Download bundle button.

<a href="https://drive.google.com/uc?export=view&id=0B9aYmGA7O0ZYMS1UM0s1YXQ1UDA"><img src="https://drive.google.com/uc?export=view&id=0B9aYmGA7O0ZYMS1UM0s1YXQ1UDA" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

3. Inside the source folder, open Terminal and type pod install. You need to have Cocoapods installed in order to do this step. To install them on your Mac follow [this guide](https://guides.cocoapods.org/using/getting-started.html).

4. Open project in XCode by clicking on [Your_app_name].xcworkspace  

5. You can now take a look at your app by running it in tvOS Simulator.

6. __(Optional)__ You can update the app's theme color by setting the _theme_ inside _Zype/Info.plist_. The theme can be set to: "dark" or "light". 

## Requirements and Prerequisites

Enhanced Playlists
1. To set up enhanced playlists, there needs to be a root playlist set up on the platform. To set the root playlist, you can go to your Apple TV app settings under __Manage Apps__ and set the __Featured Playlist__ to your root playlist's id.

Monetization
1. In order to use Native SVOD in the apps, some settings need to be updated on the Zype platform to enable Ownership validation and Consumer Entitlements. Please contact Zype support to configure settings in order for your app to function normally when using Native SVOD.