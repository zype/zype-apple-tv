Don't know what Zype is? Check this [overview](http://www.zype.com/).

# Zype Apple TV SDK

This SDK allows you to set up an eye-catching, easy to use Apple TV video streaming app integrated with the Zype platform with minimal coding and configuration. The app is built with Swift 3.0 and Zype API. With minimal setup you can have your Apple TV up and running.

## Supported Features

- Populates your app with content from enhanced playlists
- Video Search
- Live Streaming videos
- Video Favorites 
- Dynamic theme colors

## Unsupported Features

- Midroll ads
- Closed Caption Support
- Resume watch functionality

## Monetizations Supported

- Pre-roll Ads (VAST)
- Native SVOD via In App Purchases
- Universal SVOD via login

## Creating New App with the SDK

1. In order to create an Apple TV app using the SDK, you will need to create a Apple TV app on the Zype platform. If you have not done this you can do that on the Zype platform in the Dashboard in the __Manage Apps__ tab under __Publish__. You will see a button to create a new app; just follow the instructions there.

2. Once you have your Apple TV app created on the platform, click on get bundle and the bundle will be emailed to you.

3. Inside the source folder, type pod install. You need to have Cocoapods installed in order to do this step. To install them on your Mac follow [this guide](https://guides.cocoapods.org/using/getting-started.html). 

4. The SDK comes with default assets. Some assets will need be swapped out for your app: icon focus (fhd, hd, sd), icon side (hd, sd), splash screen (fhd, hd, sd) and the overhang logo. The dimensions of the overhang logo are up to you, but the other assets have specific sizes that [you can see here](https://sdkdocs.roku.com/display/sdkdoc/Manifest+File).

5. You can now take a look at your app by running it in tvOS Simulator.

6. Update the _title_ in _manifest_ to the title of your Roku app. This is the title that the users will see once the app is installed.

7. __(Optional)__ You can update the app's theme color by setting the _theme_ inside _Zype/Info.plist_. The theme can be set to: "dark" or "light". 

## Requirements and Prerequisites

Enhanced Playlists
1. To set up enhanced playlists, there needs to be a root playlist set up on the platform. To set the root playlist, you can go to your Apple TV app settings under __Manage Apps__ and set the __Featured Playlist__ to your root playlist's id.

Monetization
1. In order to use Native SVOD in the apps, some settings need to be updated on the Zype platform to enable Ownership validation and Consumer Entitlements. Please contact Zype support to configure settings in order for your app to function normally when using Native SVOD.

## Device Endpoint Notes

Supports Apple TV 4th generation with tvOS10+

## Contributing to the repo

We welcome contributions to Apple TV SDK. If you have any suggestions or notice any bugs you can raise an issue. If you have any changes to the code base that you want to see added, you can fork the repository, then submit a pull request with your changes explaining what you changed, why you believe it should be added, and how one would test these changes. Thank you to the community!

## Support

If you need more information on how Zype API works, you can read the [documentation here](http://dev.zype.com/api_docs/intro/). If you have any other questions, feel free to contact us at [support@zype.com](mailto:support@zype.com).

## Versioning

For the versions available, see the [tags on this repository](https://github.com/zype/zype-ios/tags). 

## Authors

* **Andrey Kasatkin** - *Initial work* - [Svetliy](https://github.com/svetdev)
* **Khurshid Fayzullaev** - *Native In-App subscription* - [khfayzullaev](https://github.com/khfayzullaev)
* **Jeremy Kay** - *Zype platform integrateion* - [jeremykay](https://github.com/jeremykay)

See also the list of [contributors](https://github.com/zype/zype-ios/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
