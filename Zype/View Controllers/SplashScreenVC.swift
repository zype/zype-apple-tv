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
    
    override func viewDidLoad() {
        super.viewDidLoad()
         loadAppInfo()
    }
    
    
    func loadAppInfo() {
        ZypeAppleTVBase.sharedInstance.getAppInfo(QueryBaseModel(), completion: {(backgroundUrl, featuredPlaylistId, error) in
            if (featuredPlaylistId != nil) {
                UserDefaults.standard.set(featuredPlaylistId, forKey: Const.kDefaultsRootPlaylistId)
                UserDefaults.standard.synchronize()
            }
            
            if (backgroundUrl != nil) {
                UserDefaults.standard.set(backgroundUrl, forKey: Const.kDefaultsBackgroundUrl)
                UserDefaults.standard.synchronize()
            }
          
            self.loadAppSettings() // load app settings will be exectuded on the background
            self.transitionToTabBar()
        })
    }
    
    func transitionToTabBar() {
        DispatchQueue.main.sync {
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
        
        ZypeUtilities.loginUser() {
            (result: String) in
            NotificationCenter.default.post(name: Notification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
        }

        if Const.kLimitLivestreamEnabled {
            ZypeUtilities.loadLimitLivestreamZObject()
        }
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
