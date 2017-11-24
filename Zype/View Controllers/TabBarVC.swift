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

 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.items![0].title = localized("Home.TabTitle")
        self.tabBar.items![1].title = localized("Search.TabTitle")
        self.tabBar.items![2].title = localized("Favorites.TabTitle")
        
        setupBackgroundImage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(modifyTabs), name: NSNotification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
        self.loadDynamicData()
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
