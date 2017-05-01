# Zype Apple TV Recipe

## Requirements and Prerequisites

#### Zype Apple TV Endpoint
To have a Zype Apple TV app you need to hold a valid license for Zype Apple TV API endpoint. Learn more about it [Zype website](http://www.zype.com/services/endpoint-api/).

#### Mac with XCode installed
In order to build, run, and package an app you need the latest version of XCode to be installed on your Mac computer. Xcode can be downloaded from the [App Store](https://developer.apple.com/xcode/). 

#### Apple Developer Program
Apple Developer program can be purchased via [Apple](https://developer.apple.com/programs/).

## Creating a New App with the SDK

#### Generating your bundle

1. In order to create an Apple TV app using the SDK, you will need to create an Apple TV app on the Zype platform. If you have not done this you can do that on the Zype platform in the Dashboard in the __Manage Apps__ tab under __Publish__. You will see a button to create a new app; just follow the instructions there.

2. Once you have your Apple TV app created on the platform, click on 'get bundle' and the bundle will be emailed to you. Another option is to reload the page and click the 'Download bundle' button.

<a href="https://drive.google.com/uc?export=view&id=0B9aYmGA7O0ZYMS1UM0s1YXQ1UDA"><img src="https://drive.google.com/uc?export=view&id=0B9aYmGA7O0ZYMS1UM0s1YXQ1UDA" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

#### Installing and testing your new app

3. Inside the source folder, open Terminal and type pod install. You need to have Cocoapods installed in order to do this step. To install them on your Mac follow [Cocoapods guide](https://guides.cocoapods.org/using/getting-started.html).

4. Open project in XCode by clicking on [Your_app_name].xcworkspace  

5. You can now take a look at your app by running it in tvOS Simulator.

6. __(Optional)__ You can update the app's theme color by setting the _theme_ inside _Zype/Info.plist_. The theme can be set to: "dark" or "light". 

#### Submitting to the app store

7. Once you like the look of your app you can archive and export the app into iTunesConnect. Helpful documentation can be found in [Apple distribution documentation](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/TestingYouriOSApp/TestingYouriOSApp.html).

8. Submit app to App Store by following [Apple submission documentation](https://guides.cocoapods.org/using/getting-started.html).
https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/SubmittingYourApp/SubmittingYourApp.html

