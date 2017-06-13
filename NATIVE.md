# Native Subscription

This document outlines step-by-step instructions for setting up native subscription for your Apple TV app powered by Zype's Endpoint API service and app production software and SDK template.

## Requirements and Prerequisites

#### Technical Contact
IT or developer support strongly recommended. Completing app submission and publishing requires working with iTunes Connect, app bundles and IDE.

#### iTunes Connect
An [iTunes Connect](https://itunesconnect.apple.com/login?targetUrl=%2FWebObjects%2FiTunesConnect.woa%2Fra%2Fng%2Fusers_roles%2Fsandbox_users&authResult=FAILED) account will be needed.

## Setting up iTunes Connect

#### Create Your App
1. Log in to your iTunes Connect and either select your app, or create one. You can follow this simple [Apple documentation](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/CreatingiTunesConnectRecord.html) if you need to create one.

2. Make sure your bundleID matches on both iTunes Connect and Xcode. You should be able to check `Automatically manage signing` now. Double check your `In-App Purchase` is turned on.

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8odDE4XzFON2hiUmM"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8odDE4XzFON2hiUmM" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8ocTdMMWFZZXprVnM"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8ocTdMMWFZZXprVnM" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

#### Subscription Options
3. After you hit create, look towards the top and go to `Features`. Then click the `+` button.

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oY0pqSTQxYXBjQU0"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oY0pqSTQxYXBjQU0" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

4. Choose Auto-Renewable Subscription, and fill in the 2 forms - preferably something simple like "AppName Monthly Subscription" & "appName_monthly_subscription". Choose a subscription group or enter a new one, again, should be simple like "App Auto-Renew Subscription".

`
Note: If you don’t see an option for Auto-Renewable Subscription, you probably need to complete some contracts for your account.
Press Cancel and select My Apps from the top-left part of the screen. Then pick Agreements, Tax, and Banking from the options.
Make sure all the contracts are complete, especially the Paid Applications contract.
When you’re done, the status may show as “Processing”. Even so, you should be able to return to the In-App Purchases page and create a new Auto-Renewable Subscription.
`

5. Check the `Cleared for Sale` box, and fill in the rest of the forms which should be self-explanitory. The Review section is  for `Additional information about your in-app purchase that could help us with our review` when they review your app for submission. Don't forget to save!

6. Repeat the process for any other subscription options you would like to offer - yearly, weekly, etc.

7. Click into your Subscription Group and add a `Localization`

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oX1B1anhYajZhSzg"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oX1B1anhYajZhSzg" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

8. Open your Const.swift file in your project directory

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8ocVhWa1Q5LU5xNTg"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8ocVhWa1Q5LU5xNTg" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

9. We don't need to mind any of the code below except for those blue arrows. 
- First, we'll change those `productIdentifiers` to what we entered in iTunes Connect. See blue arrows marked with a red mushroom. Your identifiers should live within the square brackets [ ] and each be wrapped in quotes " ". So that line should look something like this `static var productIdentifiers = ["monthly_subscription", "yearly_subscription"]`.
- Second, We need our appPassword which is marked by the cow. See the second image below to get your `Shared Secret`. Copy it, and paste it between the quotes. So that line should look something like this `static var appPassword = "89d7f87sd678vx786x8v6"`
- Third, find the blue arrow marked with a tree. We simply are changing that `false` to `true`. So that line should look exactly like this `static let kNativeSubscriptionEnabled = true`.
- Lastly, just take note of the blue arrow marked with the rainbow and clouds if you want to do some testing - which we'll  cover just under these helpful images!

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oOUExSjlXUkFCdms"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oOUExSjlXUkFCdms" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oWm1iZHBkSVI3ZDg"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oWm1iZHBkSVI3ZDg" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

## Testing
If you are testing, please do not skip Step 12!

#### The Setup
10. Follow the arrows to create a sandbox testing account. This way you can see if subscriptions work without paying. And don't worry about waiting a week between each subscription! These sandbox subscriptions should only lasts for about five minutes.

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oa3Vzckp6Z2lNcm8"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oa3Vzckp6Z2lNcm8" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

11. And finally, remember that blue arrow marked with a rainbow (See step 9)? We're going back into our lovely Const.swift file. We want the line with `"https://sandbox.itunes.apple.com/verifyReceipt"` not commented out, and the line on top of it commented out. It should look like this: 

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oblBPZmJyM0UwbDg"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oblBPZmJyM0UwbDg" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

#### Complete Testing
12. After you are done with testing, it is crucial to change the storeURL back to the live one. Congratulations, you have completed a full implementation of native subscription on your app! Remember, it must look like this:

<a href="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oTDIzamFOdGEwRUE"><img src="https://drive.google.com/uc?export=view&id=0B2QpIBNNKw8oTDIzamFOdGEwRUE" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>
