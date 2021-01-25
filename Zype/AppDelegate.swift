//
//  AppDelegate.swift
//  UITest
//
//  Created by Eugene Lizhnyk on 10/8/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import Analytics
import ZypeAppleTVBase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ZypeAppleTVBase.sharedInstance.initialize(Const.sdkSettings, loadCategories: false, loadPlaylists: false, completion: {_ in})
    
        UIButton.appearance().setTitleColor(StyledLabel.kBaseColor, for: UIControl.State())
        UIButton.appearance().setBackgroundImage(UIImage(named: "white"), for: UIControl.State())
    
    // setup analytics
    if Const.kSegmentAnalytics && Const.kSegmentAccountID.count > 0 {
        let configuration = AnalyticsConfiguration.init(writeKey: Const.kSegmentAnalyticsWriteKey)
        configuration.trackApplicationLifecycleEvents = true // Enable this to record certain application events automatically!
        configuration.recordScreenViews = true // Enable this to record screen views automatically!
        Analytics.setup(with: configuration)
        
        // setup identity
        Analytics.shared().identify(Const.kSegmentAccountID)
    }
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NotificationCenter.default.post(name: Notification.Name(rawValue: "zype_reload_guide_notification"), object: nil)
    NotificationCenter.default.post(name: Notification.Name(rawValue: "zype_app_reopened"), object: nil)
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    AnalyticsManager.sharedInstance.reset()
  }


}

