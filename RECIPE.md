# Zype Apple TV Recipe

This document outlines step-by-step instructions for creating and publishing an Apple TV app powered by Zype's Endpoint API service and app production software and SDK template.

## Requirements and Prerequisites

#### Technical Contact
IT or developer support strongly recommended. Completing app submission and publishing requires working with app bundles and IDE.

#### Zype Apple TV Endpoint License
To create a Zype Apple TV app you need a paid and current Zype account that includes purchase of a valid license for the Zype Apple TV endpoint API. Learn more about [Zype's Endpoint API Service](http://www.zype.com/services/endpoint-api/).

#### Mac with XCode installed
In order to compile, run, and package an app you need the latest version of XCode to be installed on your Mac computer. XCode can be downloaded from the [App Store](https://developer.apple.com/xcode/). 

#### Enrollment in the Apple Developer Program
The Apple Developer Program can be enrolled in via [Apple's website](https://developer.apple.com/programs/).

## Creating a New App with the SDK Template

#### Generating your bundle

1. In order to generate an Apple TV app bundle using this SDK, you will need to first create an Apple TV app on the Zype platform. If you have not done this yet, log in to your Zype account [here](https://admin.zype.com/users/sign_in), and click on the __Manage Apps__ link under the __Publish__ menu in the left navigation. You will see a button to create a new app. Continue following the instructions provided within the app production software.

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oLXNxN0U4N1cwTUE"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oLXNxN0U4N1cwTUE" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

2. Once you have your Apple TV app created in the Zype platform, click on __Get New Bundle__ and the configured app bundle will be emailed to you. You may also reload the page and click the __Download Bundle__ button.

<a href="https://drive.google.com/uc?export=view&id=0B9aYmGA7O0ZYMS1UM0s1YXQ1UDA"><img src="https://drive.google.com/uc?export=view&id=0B9aYmGA7O0ZYMS1UM0s1YXQ1UDA" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

#### Installing and testing your new app

3. After you've received your app bundle, you'll need to install and test your new app. You'll need to have Cocoapods installed in order to perform this step. To install them on your Mac, follow the [Cocoapods guide](https://guides.cocoapods.org/using/getting-started.html). Navigate to your project folder. Open the Podfile, and change the `ZypeAppName` to your App name. Make sure to save your changes before/upon closing this file.

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oN21DckNfZTN2cEE"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oN21DckNfZTN2cEE" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

4. With Cocoapods installed, start by opening the Terminal program (You can find the Terminal program in Finder -> Applications or CMD + SpaceBar -> type in _terminal_ and hit return). Navigate to your project folder with your terminal and type _pod install_. 

##### Helpful command line tips for Terminal

```
ls  ---> shows folders in current directory
cd downloads  ---> goes into downloads if available (see ls)
cd downloads/myproject  ---> goes into downloads/myproject if available (see ls)
cd ..  ---> goes back one directory level up 
```

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oTHRxNVRTa0plb2c"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oTHRxNVRTa0plb2c" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

5. Open your new project in XCode by clicking on [Your_app_name].xcworkspace - (NOT .xcodeproj). 

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oaG83Z19LM2R1OWM"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oaG83Z19LM2R1OWM" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

6. You can now view your new app by running it in the tvOS Simulator!

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oa0tvM3hGMGVaT0k"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oa0tvM3hGMGVaT0k" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

7. __(Optional)__ You can update the app's theme color by modifying the _theme_ inside _Zype/Info.plist_. The theme can be set to a value of either: "Dark" or "Light". 

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oMjRoVG9rRlpYU2s"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oMjRoVG9rRlpYU2s" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

8. __(Optional)__ In order to add Native Subscription (Native SVOD) follow this [guide](https://github.com/zype/zype-apple-tv/blob/master/NATIVE.md).

#### Submitting to the Apple App Store

9. Once you like the look of your app you can archive and export the app into iTunesConnect. Helpful documentation about archiving and exporting your app can be found in [Apple's distribution documentation](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/TestingYouriOSApp/TestingYouriOSApp.html).

10. Submit the app to Apple's App Store by following [Apple submission documentation](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/SubmittingYourApp/SubmittingYourApp.html).

11. Once submitted, Apple will review your app against their submission guidelines. If your app is approved, they will update the app status and iTunes Connect users are notified of the status change. 
