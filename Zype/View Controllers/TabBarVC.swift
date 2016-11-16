//
//  TabBarVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/29/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tabBar.items![0].title = localized("Home.TabTitle")
    self.tabBar.items![1].title = localized("Search.TabTitle")
    self.tabBar.items![2].title = localized("Favorites.TabTitle")
    let background = UIImageView(frame: self.view.bounds)
    background.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    background.image = UIImage(named: "background")
    self.view.insertSubview(background, atIndex: 0)

     self.loadDynamicData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(modifyTabs), name: kZypeReloadScreenNotification, object: nil)
  }
  
 func loadDynamicData() {
        //ZypeUtilities.checkDeviceLinkingWithServer()
        ZypeUtilities.loadLimitLivestreamZObject()
        loadAppSettings()
        ZypeUtilities.loginUser() {
            (result: String) in
            print("got back: \(result)")
            self.addLogoutScreen()
        }
    }
    
    func loadAppSettings() {
        let type = QueryZobjectsModel()
        type.zobjectType = "tvos_settings"
        ZypeAppleTVBase.sharedInstance.getZobjects(type, completion: {(objects: Array<ZobjectModel>?, error: NSError?) in
            if let _ = objects where objects!.count > 0 {
                let tvOSSettings = objects?.first
                do {
                    let aboutText = try SSUtils.stringFromDictionary(tvOSSettings?.json, key: "about")
                    let aboutTitle = try SSUtils.stringFromDictionary(tvOSSettings?.json, key: "about_title")
                    
                    if (!aboutText.isEmpty) {
                        self.addAboutScreen(aboutTitle, text: aboutText)
                    }
                }
                catch _ {
                    ZypeLog.error("Exception: ZobjectModel - tvOS Settings About Screen")
                }
                do {
                    let pageHeaderText = try SSUtils.stringFromDictionary(tvOSSettings?.json, key: kLoginPageHeader)
                    if (!pageHeaderText.isEmpty) {
                        NSUserDefaults.standardUserDefaults().setObject(pageHeaderText, forKey: kLoginPageHeader)
                    }
                    let pageFooterText = try SSUtils.stringFromDictionary(tvOSSettings?.json, key: kLoginPageFooter)
                    if (!pageFooterText.isEmpty) {
                        NSUserDefaults.standardUserDefaults().setObject(pageFooterText, forKey: kLoginPageFooter)
                    }
                }
                catch _ {
                    ZypeLog.error("Exception: ZobjectModel - tvOS Settings Header and Footer for Login")
                }
                do {
                    let pageHeaderText = try SSUtils.stringFromDictionary(tvOSSettings?.json, key: kLogoutPageHeader)
                    if (!pageHeaderText.isEmpty) {
                        NSUserDefaults.standardUserDefaults().setObject(pageHeaderText, forKey: kLogoutPageHeader)
                    }
                    let pageFooterText = try SSUtils.stringFromDictionary(tvOSSettings?.json, key: kLogoutPageFooter)
                    if (!pageFooterText.isEmpty) {
                        NSUserDefaults.standardUserDefaults().setObject(pageFooterText, forKey: kLogoutPageFooter)
                    }
                }
                catch _ {
                    ZypeLog.error("Exception: ZobjectModel - tvOS Settings Header and Footer for Logout")
                }
                
                do {
                    let favoritesText = try SSUtils.stringFromDictionary(tvOSSettings?.json, key: kFavoritesMessage)
                    if (!favoritesText.isEmpty) {
                        NSUserDefaults.standardUserDefaults().setObject(favoritesText, forKey: kFavoritesMessage)
                    }
                }                catch _ {
                    ZypeLog.error("Exception: ZobjectModel - Favorites")
                }
                
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        })
    }
    
    func addAboutScreen(title : String, text : String) {
        let aboutViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ScrollableTextAlertVC") as! ScrollableTextAlertVC
        aboutViewController.configWithText(text, header: title, title: "")
        self.viewControllers?.append(aboutViewController)
        self.tabBar.items![3].title = "About"
        
    }
    
    func modifyTabs() {
        if (ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn == true){
            self.addLogoutScreen()
        } else {
            self.removeLogoutScreen()
        }
    }
    
    func addLogoutScreen() {
        if (ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn == true){
            let logoutVC = ZypeUtilities.getLogoutVC()
            if (logoutVC != nil) {
                self.viewControllers?.append(logoutVC!)
                let position = (self.tabBar.items?.count)! - 1
                self.tabBar.items![position].title = "Settings"
            }
        }
    }
    
    func removeLogoutScreen() {
        var needToBeRemoved = false
        for vc in self.viewControllers! {
            if (vc is LogoutVC){
                needToBeRemoved = true
            }
        }
        
        if (needToBeRemoved) {
            // self.tabBar.selectedItem = self.tabBar.items![0]
            self.selectedIndex = 0
            self.viewControllers?.removeLast()
        }
    }

  
}
