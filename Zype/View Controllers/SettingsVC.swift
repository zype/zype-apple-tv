//
//  SettingsVC.swift
//  AndreySandbox
//
//  Created by Александр on 01.11.2017.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class SettingsVC: UIViewController {

    @IBOutlet var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var logoutTitle: UILabel!
    @IBOutlet weak var logoutFooter: UILabel!
    @IBOutlet var subsciptionTitle: UILabel!
    @IBOutlet var expireDateTitle: UILabel!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = self.tabBarController?.view.backgroundColor
        //self.configureView()
        self.setupText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkSubsciptionStatus()
        self.checkLoginStatus()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.checkSubsciptionStatus),
                                               name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkLoginStatus), name: NSNotification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupText() {
        let pageHeaderText = UserDefaults.standard.object(forKey: kLogoutPageHeader)
        if (pageHeaderText != nil) {
            self.logoutTitle.text = pageHeaderText as? String
        }
        let pageFooterText = UserDefaults.standard.object(forKey: kLogoutPageFooter)
        if (pageFooterText != nil) {
            self.logoutFooter.text = pageFooterText as? String
        }
    }
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: kDeviceLinkedStatus)
        ZypeAppleTVBase.sharedInstance.logOut()
        
        UserDefaults.standard.removeObject(forKey: kUserEmail)
        UserDefaults.standard.removeObject(forKey: kUserPassword)
        
        let defaults = UserDefaults.standard
        
        if let favorites = defaults.object(forKey: "favoritesViaAPI") as? Bool {
            if favorites {
                let favorites = [String]()
                defaults.set(favorites, forKey: kFavoritesKey)
                defaults.synchronize()
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        ZypeUtilities.presentLoginVC(self)
    }
    

    @IBAction func restorePurchaseClicked(_ sender: Any) {
        InAppPurchaseManager.sharedInstance.restorePurchases()
    }
    
    func checkLoginStatus() {
        if let isLoggedIn = ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn {
            self.loginButton.isHidden = isLoggedIn
            self.logoutButton.isHidden = !isLoggedIn
            self.logoutTitle.text = isLoggedIn ? "Unlink your device" : "Link your device"
        }
    }
    
    func checkSubsciptionStatus() {
        if Const.kNativeToUniversal {
            if let subscriptionCount = ZypeAppleTVBase.sharedInstance.consumer?.subscriptionCount {
                if subscriptionCount > 0 {
                    self.checkSubscription()
                    return
                } else {
                    self.expireDateTitle.text = "Not subscriptions"
                }
            }
        }
        
        if Const.kNativeSubscriptionEnabled {
            self.checkSubscription()
        }
    }
    
    func checkSubscription() {
        InAppPurchaseManager.sharedInstance.checkSubscription { (isExpired, expirationDate, error) in
            if expirationDate != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM dd, YYYY"
                self.expireDateTitle.text = "Expires on \(dateFormatter.string(from: expirationDate!))"
            } else {
                if Const.kNativeSubscriptionEnabled {
                    self.expireDateTitle.text = "Not subscriptions"
                } else if Const.kNativeToUniversal {
                    self.expireDateTitle.text = "Subscribed"
                }
            }
        }
    }
    
}
