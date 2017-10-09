//
//  PurchaseVC.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/19/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class PurchaseVC: UIViewController {
    
    @IBOutlet var containerView: UIView!
    var scrollView: UIScrollView!
    var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureButtons()
    }
    
    // since the duration for a SKProduct is not available
    // we need a custtom mapper function to handle that
    func getDuration(_ productID: String) -> String {
        var duration: String = "";
        
        if productID.range(of: "monthly") != nil {duration = "(monthly)"}
        if productID.range(of: " ") != nil {duration = "(yearly)"}
        
        return duration
    }
    
    func onPlanSelected(sender: UIButton) {
        if let identifier = sender.accessibilityIdentifier {
            self.purchase(identifier)
        }
        print("\n\n HELLO PURCHASE WORLD \n\n")
        print(sender.tag)
    }
    
    func purchase(_ productID: String) {
        InAppPurchaseManager.sharedInstance.purchase(productID)
    }
    
    func configureButtons() {
        
        stackView = UIStackView()
        stackView.axis = UILayoutConstraintAxis.horizontal
        stackView.distribution = UIStackViewDistribution.fill
        stackView.alignment = UIStackViewAlignment.center
        stackView.spacing = Const.kSubscribeButtonHorizontalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.clipsToBounds = false
        scrollView.addSubview(stackView)
        containerView.addSubview(scrollView)
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: .alignAllCenterX, metrics: nil, views: ["scrollView": scrollView]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: .alignAllCenterX, metrics: nil, views: ["scrollView": scrollView]))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        
        if let products = InAppPurchaseManager.sharedInstance.products {
            for product in products {
                let subscribeButton = UIButton.init(type: .system)
                subscribeButton.heightAnchor.constraint(equalToConstant: self.containerView.height).isActive = true
                subscribeButton.setTitle(String(format: localized("Subscription.ButtonFormat"), arguments: [product.value.localizedTitle, product.value.localizedPrice(), self.getDuration(product.value.productIdentifier)]), for: .normal)
                subscribeButton.accessibilityIdentifier = product.key
                subscribeButton.addTarget(self, action: #selector(self.onPlanSelected(sender:)), for: .primaryActionTriggered)
                stackView.addArrangedSubview(subscribeButton)
            }
        }
    }
}
