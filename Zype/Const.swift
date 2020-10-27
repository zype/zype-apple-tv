//
//  Const.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/9/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//
// GIT DESCRIPTION: <GIT_DESCRIPTION>

import UIKit
import ZypeAppleTVBase

class Const: NSObject {
    
    //left side is product identifiers from InApp purchase items
    static let monthlySubscription = "monthly_subscription"
    static let yearlySubscription = "yearly_subscription"
    
    // consumable IAPs - for tvod
    static let videoProduct1 = "product1"

    static let subscriptionIdentifiers: [String: String] = [   monthlySubscription: monthlySubscription,
                                                               yearlySubscription: yearlySubscription];
    static let consumableIdentifiers: [String: String] = [:];
    static var productIdentifiers: [String: String] = subscriptionIdentifiers.merging(consumableIdentifiers) { (current, _) in current }
    
    static var appstorePassword = ""
    
        static let sdkSettings = SettingsModel(clientID: "<CLIENT_ID>",
                                           secret: "<CLIENT_SECRET>",
                                           appKey: "<APP_KEY>",
                                           apiDomain:"https://api.zype.com",
                                           tokenDomain: "https://login.zype.com",
                                           userAgent: "zype tvos")
    
    static let kStoreURL = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
    //static let kStoreURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")! // for testing only
    
    // MARK: - Feature Flags
    
    static let kNativeSubscriptionEnabled = false
    static let kMarketplaceConnectSVODEnabled = false
    static let kLimitLivestreamEnabled = false
    static let kFavoritesViaAPI = false
    static let kLockIcons = false
    static let kUnlockTransparentEnabled = false
    static let kSubscribeToWatchAdFree = false
    static let kEPGEnabled = false
    static let kInlineTitleTextDisplay = false
    static let kLiveItemEnabled = false
    static let kLiveVideoID = "5c8faa021d1f4314dd006203"
    static let kEpisodeNumberDisplay = false
    static let kSegmentAnalytics = false // if enabled, make sure kSegmentAccountID has a value entered
    static let kSegmentAnalyticsWriteKey = "enter_write_key_here" // must have some value if kSegmentAnalytics is enabled
    static let kSegmentAccountID = "" // must have some value if kSegmentAnalytics is enabled

	static let Advanced_Analytics_Enabled = true
    static let Advanced_Analytics_CustomerID = "<customer_id_mediamelon>"

    // NOTE: This is a deprecated feature. DO NOT ENABLE
    static let kNativeToUniversal = false

    static let kParentalGuidanceProtection = false
    static let kUniversalTvod = false

    // NOTE: This is a gated feature that REQUIRES Zype to configure. Please reach out to Zype Support for help on setting up this feature.
    static let kNativeTvod = false
    static let kTosValidation = false // enable for Terms of Service checkbox on signup
    
    // MARK: - UI Constants
    
    static let kBaseSectionInsets: UIEdgeInsets = UIEdgeInsets(top: 50, left: 90, bottom: 50, right: 90)
    static let kCollectionCellSize: CGSize = CGSize(width: 308, height: 220)
    static let kCollectionCellPosterSize: CGSize = CGSize(width: 286, height: 446)
    static let kCollectionCellMiniPosterSize: CGSize = CGSize(width: 185, height: 300)
    static let kShowCellHeight: CGFloat = 310
    static let kCollectionHorizontalSpacing: CGFloat = 50.0
    static let kCollectionVerticalSpacing: CGFloat = 50.0
    static let kCollectionSectionHeaderHeight: CGFloat = 45.0
    static let kSubscribeButtonHorizontalSpacing: CGFloat = 70.0
    static let kCollectionPagerCellSize: CGSize = CGSize(width: 1920, height: 700) //1450 x 630 or 1740 x 490
    
    static let kCollectionPagerVCBottomMargin: CGFloat = 70.0
    static let kCollectionSectionHeaderBottomMargin: CGFloat = 25.0
    static let kCollectionPagerHorizontalSpacing: CGFloat = 20.0
    static let kScrollableTextVCMaskInsets: UIEdgeInsets = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
    
    static let kEPGHighlightColor: UIColor = UIColor(red: 238/255.0, green: 150/255.0, blue: 45/255.0, alpha: 1.0)
    static let kEPGAiringColor: UIColor = UIColor(red: 12/255.0, green: 60/255.0, blue: 78/255.0, alpha: 1.0)
    
    static let kLockColor = "#FF0000"
    static let kUnlockColor = "#0000FF"
    
    // MARK: - String Constants
    
    static let kSubscriptionSettings = "SubscriptionPlans"
    static let kFavoritesKey = "Favorites"
    static let kDefaultsRootPlaylistId = "root_playlist_id"
    static let kDefaultsBackgroundUrl = "background_url"
    static let kAppId = "app_id"
    static let kSiteId = "site_id"
    static let kAppVersion = "1.5.7"
    static let kValidateTos = "validate_tos" // key for feature flag
    
    // MARK: - Segues
    
    static let kShowTabBarSegueId = "ShowTabBar"
    
}
