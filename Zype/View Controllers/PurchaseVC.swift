//
//  PurchaseVC.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/19/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class PurchaseVC: UIViewController {
    
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for button in buttons {
            let productID = Const.productIdentifiers[button.tag]
            if let product = InAppPurchaseManager.sharedInstance.products?[productID] {
                button.setTitle(String(format: localized("Subscription.ButtonFormat"), arguments: [product.localizedTitle, product.localizedPrice(), self.getDuration(productID)]), for: .normal)
            }
        }
    }
    
    // since the duration for a SKProduct is not available
    // we need a custtom mapper function to handle that
    func getDuration(_ productID: String) -> String {
        var duration: String = "";
        
        if productID.range(of: "monthly") != nil {duration = "(monthly)"}
        if productID.range(of: " ") != nil {duration = "(yearly)"}
        
        return duration
    }
    
    @IBAction func onPlanSelected(_ sender: UIButton) {
        self.purchase(Const.productIdentifiers[sender.tag])
        print("\n\n HELLO PURCHASE WORLD \n\n")
        print(sender.tag)
    }
    
    func purchase(_ productID: String) {
        InAppPurchaseManager.sharedInstance.purchase(productID)
    }
}
