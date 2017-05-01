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

2. Once you have your Apple TV app created on the platform, click on __Get New Bundle__ and the bundle will be emailed to you. Another option is to reload the page and click the __Download Bundle__ button.

<a href="https://drive.google.com/uc?export=view&id=0B9aYmGA7O0ZYMS1UM0s1YXQ1UDA"><img src="https://drive.google.com/uc?export=view&id=0B9aYmGA7O0ZYMS1UM0s1YXQ1UDA" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

#### Installing and testing your new app

3. Open Terminal, navigate to your project folder, and type _pod install_. You'll need to have Cocoapods installed in order to do this step. To install them on your Mac follow [Cocoapods guide](https://guides.cocoapods.org/using/getting-started.html). You can find your Terminal in Finder -> Applications or CMD + SpaceBar -> type in _terminal_ and hit enter.

Terminal Commands:
  
  ls => shows folders in current directory
  
  cd downloads => goes into downloads if available (see ls)
  
  cd downloads/myproject => goes into downloads/myproject if available (see ls)
  
  cd .. => goes back one directory level up
  
<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oZUFDbjZzVGx1RlE"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oZUFDbjZzVGx1RlE" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

4. Open your new project in XCode by clicking on [Your_app_name].xcworkspace - (NOT .xcodeproj). If this is not available, something went wrong in step 3 :( Copy the error in your terminal and paste it into [Stack Overflow](http://stackoverflow.com/) to find a solution.

5. You can now take a look at your app by running it in tvOS Simulator!

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oWFNRbkUzdkxIVm8"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oWFNRbkUzdkxIVm8" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

6. __(Optional)__ You can update the app's theme color by setting the _theme_ inside _Zype/Info.plist_. The theme can be set to: "Dark" or "Light". 

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oZFZOTjdCRFpxZms"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oZFZOTjdCRFpxZms" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

#### Submitting to the app store

7. Once you like the look of your app you can archive and export the app into iTunesConnect. Helpful documentation can be found in [Apple distribution documentation](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/TestingYouriOSApp/TestingYouriOSApp.html).

8. Submit app to App Store by following [Apple submission documentation](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/SubmittingYourApp/SubmittingYourApp.html).

