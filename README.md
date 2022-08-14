Want to learn more about Zype’s solutions for OTT apps, video streaming and playout? Visit our [website](http://www.zype.com/).

# Zype's Apple TV SDK

This legacy open source app template is no longer supported by Zype. If you are looking to build streaming applications for OTT, we recommend using [Zype Apps Creator](https://www.zype.com/product/apps-creator) for the latest app building features and functionality. 


## Creating a New Applcation with the SDK

1. In order to create an Apple TV app using the SDK, you will need to create a Apple TV app on the Zype platform. If you have not done this you can do that on the Zype platform in the Dashboard in the __Manage Apps__ tab under __Publish__. You will see a button to create a new app; just follow the instructions there.

2. Once you have your Apple TV app created on the platform, click on get bundle and the bundle will be emailed to you.

3. Inside the source folder, type pod install. You need to have Cocoapods installed in order to do this step. To install them on your Mac follow [this guide](https://guides.cocoapods.org/using/getting-started.html). 

4. The SDK comes with default assets. Some assets will need be swapped out for your app: icon focus (fhd, hd, sd), icon side (hd, sd), splash screen (fhd, hd, sd) and the overhang logo. The dimensions of the overhang logo are up to you, but the other assets have specific sizes that [you can see here](https://support.zype.com/hc/en-us/articles/221132148-Branding-your-Apple-TV-App-Images-and-Specs).

5. You can now take a look at your app by running it in tvOS Simulator.

6. __(Optional)__ You can update the app's theme color by setting the _theme_ inside _Zype/Info.plist_. The theme can be set to: "dark" or "light". 


## Contributing to the Repository

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
