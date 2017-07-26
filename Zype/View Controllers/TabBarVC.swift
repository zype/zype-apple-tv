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
