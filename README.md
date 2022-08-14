Want to learn more about Zype’s solutions for OTT apps, video streaming and playout? Visit our [website](http://www.zype.com/).

# Zype's Apple TV SDK

This legacy open source app template is no longer supported by Zype. If you are looking to build streaming applications for OTT, we recommend using [Zype Apps Creator](https://www.zype.com/product/apps-creator) for the latest app building features and functionality. 

## Supported Features

- Populates your app with content from enhanced playlists
- Video Search
- Live Streaming videos
- Video Favorites 
- Dynamic theme colors
- Resume watch functionality

## Unsupported Features

- Closed Caption Support 

## Monetizations Supported

- Pre-roll Ads (VAST)
- Midroll ads (VAST)
- Native SVOD via In App Purchases
- Universal SVOD via login

## Creating a New Applcation with the SDK

1. In order to create an Apple TV app using the SDK, you will need to create a Apple TV app on the Zype platform. If you have not done this you can do that on the Zype platform in the Dashboard in the __Manage Apps__ tab under __Publish__. You will see a button to create a new app; just follow the instructions there.

2. Once you have your Apple TV app created on the platform, click on get bundle and the bundle will be emailed to you.

3. Inside the source folder, type pod install. You need to have Cocoapods installed in order to do this step. To install them on your Mac follow [this guide](https://guides.cocoapods.org/using/getting-started.html). 

4. The SDK comes with default assets. Some assets will need be swapped out for your app: icon focus (fhd, hd, sd), icon side (hd, sd), splash screen (fhd, hd, sd) and the overhang logo. The dimensions of the overhang logo are up to you, but the other assets have specific sizes that [you can see here](https://support.zype.com/hc/en-us/articles/221132148-Branding-your-Apple-TV-App-Images-and-Specs).

5. You can now take a look at your app by running it in tvOS Simulator.

6. __(Optional)__ You can update the app's theme color by setting the _theme_ inside _Zype/Info.plist_. The theme can be set to: "dark" or "light". 

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

For the versions available, see the [tags on this repository](https://github.com/zype/zype-apple-tv/tags). 

## Authors

* **Andrey Kasatkin** - *Initial work* - [Svetliy](https://github.com/svetdev)
* **Khurshid Fayzullaev** - *Native In-App subscription* - [khfayzullaev](https://github.com/khfayzullaev)
* **Jeremy Kay** - *Zype platform integration* - [jeremykay](https://github.com/jeremykay)
* **Eric Chang** - *Native to Universal subscription, midroll ads* - [Promulgate](https://github.com/Promulgate)

See also the list of [contributors](https://github.com/zype/zype-ios/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
