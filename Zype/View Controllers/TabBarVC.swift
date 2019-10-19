//
//  TabBarVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/29/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase


class TabBarVC: UITabBarController {

    var prevTabItem: UITabBarItem? = nil
    public static var openingApp: Bool = false
    
    // MARK: - View Lifecycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.items![0].title = localized("Home.TabTitle")
        self.tabBar.items![1].title = localized("Search.TabTitle")
        self.tabBar.items![2].title = localized("Favorites.TabTitle")
        
        setupBackgroundImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(modifyTabs), name: NSNotification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideTabBar), name: NSNotification.Name(rawValue: "zype_app_reopened"), object: nil)
        self.loadDynamicData()
        
        self.tabBar.alpha = 0
    }
    
    override var preferredFocusedView: UIView? {
        get {
            if !TabBarVC.openingApp {
                return self.selectedViewController?.preferredFocusedView
            }
            self.tabBar.alpha = 1
            return super.preferredFocusedView
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if prevTabItem != item, item.title?.lowercased() == "guide" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "zype_reload_guide_notification"), object: nil)
        }
        
        prevTabItem = item
    }
    
    func hideTabBar() {
        self.tabBar.alpha = 0
        TabBarVC.openingApp = false
        
        self.selectedIndex = 0
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.5)
            DispatchQueue.main.async {
                TabBarVC.openingApp = true
            }
        }
    }
    
    func setupBackgroundImage() {
        let background = URLImageView(frame: self.view.bounds)
        background.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        if let backgroundUrl = UserDefaults.standard.object(forKey: Const.kDefaultsBackgroundUrl) as? String {
            background.configWithURL(URL(string: backgroundUrl), nil)

        } else {
            background.image = UIImage(named: "background_dark")
        }
        self.view.insertSubview(background, at: 0)
    }
        
    func addAboutScreen(_ title : String, text : String) {
        let aboutViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScrollableTextAlertVC") as! ScrollableTextAlertVC
        aboutViewController.configWithText(text, header: title, title: "")
        self.viewControllers?.append(aboutViewController)
        self.tabBar.items![3].title = "About"
        
    }
    
    func isSettingItemEnabled() -> Bool {
        if let items = self.tabBar.items {
            for item in items {
                if item.title == "Settings" {
                    return true
                }
            }
        }
        
        return false
    }
    
    func loadDynamicData() {
        if Const.kUniversalTvod == true {
            self.addMyLibraryScreen()
        }
        self.modifyTabs()
    }
    
    func modifyTabs() {
        if ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn == true ||
            Const.kNativeSubscriptionEnabled == true ||
            Const.kNativeToUniversal == true ||
            Const.kFavoritesViaAPI == true  {
            if self.isSettingItemEnabled() == false {
                self.addSettingsScreen()
            }
        }
        else {
            if self.isSettingItemEnabled() == true {
                self.removeSettingsScreen()
            }
        }
        
        if Const.kEPGEnabled == true {
            self.addGuideScreen()
        } else {
            self.removeGuideScreen()
        }
    }
    
    func addSettingsScreen() {
        if ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn == true ||
            Const.kNativeSubscriptionEnabled == true ||
            Const.kNativeToUniversal == true ||
            Const.kFavoritesViaAPI == true {
            let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC
            if (settingsVC != nil) {
                let navController = UINavigationController.init(rootViewController: settingsVC!)
                self.viewControllers?.append(navController)
                let position = (self.tabBar.items?.count)! - 1
                self.tabBar.items![position].title = "Settings"
            }
        }
    }
    
    func removeSettingsScreen() {
        var needToBeRemoved = false
        for vc in self.viewControllers! {
            if (vc is SettingsVC){
                needToBeRemoved = true
            }
        }
        
        if needToBeRemoved {
            // self.tabBar.selectedItem = self.tabBar.items![0]
            self.selectedIndex = 0
            self.viewControllers?.removeLast()
        }
    }
    
    func addGuideScreen() {
        let guideVC = self.storyboard?.instantiateViewController(withIdentifier: "GuideVC") as? GuideVC
        if (guideVC != nil) {
            let navController = UINavigationController.init(rootViewController: guideVC!)
            self.viewControllers?.insert(navController, at: 1)
            self.tabBar.items![1].title = localized("Guide.TabTitle")
        }
    }
    
    func removeGuideScreen() {
        var needToBeRemoved = false
        for vc in self.viewControllers! {
            if (vc is GuideVC){
                needToBeRemoved = true
            }
        }
        
        if needToBeRemoved {
            self.selectedIndex = 0
            self.viewControllers?.remove(at: 1)
        }
    }
    
    func addMyLibraryScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let myLibraryVC = storyboard.instantiateViewController(withIdentifier: "MyLibraryVC") as? MyLibraryVC {
            if let position = self.tabBar.items?.count {
                //let navigationController = UINavigationController.init(rootViewController: myLibraryVC)
                self.viewControllers?.append(myLibraryVC)
                self.tabBar.items![position].title = "MyLibrary"
            }
        }
    }
}
