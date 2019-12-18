//
//  SplashScreenVC.swift
//  Svetliy
//
//  Created by Andrey Kasatkin on 1/20/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class SplashScreenVC: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var autoPlayed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ZypeUtilities.loginUser() { (result: String) in
            self.loadAppInfo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.autoPlayed {
            self.transitionToTabBar()
        }
    }
    
    
    func loadAppInfo() {
        // Feature flag - Confirm terms of service on sign up
        UserDefaults.standard.set(Const.kTosValidation, forKey: Const.kValidateTos)

        ZypeAppleTVBase.sharedInstance.getAppInfo(QueryBaseModel(), completion: {(backgroundUrl, featuredPlaylistId, appId, siteId, error) in
            if featuredPlaylistId != nil {
                UserDefaults.standard.set(featuredPlaylistId, forKey: Const.kDefaultsRootPlaylistId)
                UserDefaults.standard.synchronize()
            }
            
            if (backgroundUrl != nil) {
                UserDefaults.standard.set(backgroundUrl, forKey: Const.kDefaultsBackgroundUrl)
                UserDefaults.standard.synchronize()
            }
            
            if (appId != nil) {
                UserDefaults.standard.set(appId, forKey: Const.kAppId)
                UserDefaults.standard.synchronize()
            }

            if (siteId != nil) {
                UserDefaults.standard.set(siteId, forKey: Const.kSiteId)
                UserDefaults.standard.synchronize()
            }

            self.loadAppSettings() // load app settings will be exectuded on the background
            self.checkAutoPlayVideo()
        })
    }
    
    func checkAutoPlayVideo() {
        let type = QueryZobjectsModel()
        type.zobjectType = "autoplay_hero"
        type.anyQueryString = "&sort=priority&order=desc"
        ZypeAppleTVBase.sharedInstance.getZobjects(type, completion: {(objects: Array<ZobjectModel>?, error: NSError?) in
            if let objects = objects, objects.count > 0 {
                for object in objects {
                    if object.getBoolValue("active") == true {
                        let queryModel = QueryVideosModel(categoryValue: nil, exceptCategoryValue: nil, playlistId: "", searchString: "", page: 0, perPage: 1)
                        queryModel.videoID = object.getStringValue("videoid")
                        ZypeAppleTVBase.sharedInstance.getVideos(queryModel) { (videos, error) in
                            if error == nil, let videos = videos, videos.count > 0 {
                                self.autoPlayed = true
                                self.playVideo(videos.first!, playlist: nil, isResuming: false, startTime: nil, endTime: nil, isAutoPlay: true)
                            } else {
                                self.transitionToTabBar()
                            }
                        }
                        return
                    }
                }
            }
            self.transitionToTabBar()
        })
    }
    
    func transitionToTabBar() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.performSegue(withIdentifier: Const.kShowTabBarSegueId, sender: nil)
        }
    }
    
    func loadAppSettings() {
        let type = QueryZobjectsModel()
        type.zobjectType = "tvos_settings"
        ZypeAppleTVBase.sharedInstance.getZobjects(type, completion: {(objects: Array<ZobjectModel>?, error: NSError?) in
            if let tvOSSettings = objects?.first {
                self.parseResponse(tvOSSettings: tvOSSettings)
            }
        })
        
        ZypeAppleTVBase.sharedInstance.getSubscriptionPlan(Const.subscriptionIdentifiers) { (data, error) in
            if error == nil, let data = data, let response = data["response"] as? [Any] {
                
                var subscriptions = [String: Any]()
                for plan in response {
                    if let plan = plan as? [String: Any],
                        let planId = plan["_id"] as? String,
                        let marketplace = plan["marketplace_ids"] as? [String: Any],
                        let itunes = marketplace["apple_tv"] as? String {
                        
                        if (Const.subscriptionIdentifiers.keys.contains(planId)) {
                            subscriptions[itunes] = planId
                        }
                    }
                }
                UserDefaults.standard.set(subscriptions, forKey: Const.kSubscriptionSettings)
                UserDefaults.standard.synchronize()
            }
        }
        
        if Const.kLimitLivestreamEnabled {
            ZypeUtilities.loadLimitLivestreamZObject()
        }
        
        let defaults = UserDefaults.standard
        defaults.setValue(Const.kFavoritesViaAPI, forKey: "favoritesViaAPI")
    }
    
    func parseResponse(tvOSSettings: ZobjectModel) {
        do {
            let aboutText = try SSUtils.stringFromDictionary(tvOSSettings.json, key: "about")
            let aboutTitle = try SSUtils.stringFromDictionary(tvOSSettings.json, key: "about_title")
            
            if (!aboutText.isEmpty) {
                //  self.addAboutScreen(aboutTitle, text: aboutText)
                //TODO: add about notification for about screen
            }
        }
        catch _ {
            ZypeLog.error("Exception: ZobjectModel - tvOS Settings About Screen")
        }
        do {
            let pageHeaderText = try SSUtils.stringFromDictionary(tvOSSettings.json, key: kLoginPageHeader)
            if (!pageHeaderText.isEmpty) {
                UserDefaults.standard.set(pageHeaderText, forKey: kLoginPageHeader)
            }
            let pageFooterText = try SSUtils.stringFromDictionary(tvOSSettings.json, key: kLoginPageFooter)
            if (!pageFooterText.isEmpty) {
                UserDefaults.standard.set(pageFooterText, forKey: kLoginPageFooter)
            }
        }
        catch _ {
            ZypeLog.error("Exception: ZobjectModel - tvOS Settings Header and Footer for Login")
        }
        do {
            let pageHeaderText = try SSUtils.stringFromDictionary(tvOSSettings.json, key: kLogoutPageHeader)
            if (!pageHeaderText.isEmpty) {
                UserDefaults.standard.set(pageHeaderText, forKey: kLogoutPageHeader)
            }
            let pageFooterText = try SSUtils.stringFromDictionary(tvOSSettings.json, key: kLogoutPageFooter)
            if (!pageFooterText.isEmpty) {
                UserDefaults.standard.set(pageFooterText, forKey: kLogoutPageFooter)
            }
        }
        catch _ {
            ZypeLog.error("Exception: ZobjectModel - tvOS Settings Header and Footer for Logout")
        }
        
        do {
            let favoritesText = try SSUtils.stringFromDictionary(tvOSSettings.json, key: kFavoritesMessage)
            if (!favoritesText.isEmpty) {
                UserDefaults.standard.set(favoritesText, forKey: kFavoritesMessage)
            }
        }                catch _ {
            ZypeLog.error("Exception: ZobjectModel - Favorites")
        }
        
        UserDefaults.standard.synchronize()
    }
    
}
