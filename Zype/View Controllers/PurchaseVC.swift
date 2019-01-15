//
//  PurchaseVC.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/19/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import StoreKit
import ZypeAppleTVBase

class PurchaseVC: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var attemptView: UIView!
    @IBOutlet var attemptInputView: UITextField!
    @IBOutlet var attemptDecriptionLabel: UILabel!
    
    var result: Int = 0
    var productIDSelected: String!
    var associatedVideo: VideoModel! // video clicked to show PurchaseVC
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var accountLabel: UILabel!
    @IBOutlet var loginButton: UIButton!

    var scrollView: UIScrollView!
    var stackView: UIStackView!
    
    @IBOutlet weak var signInView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Const.kNativeSubscriptionEnabled) {
            signInView.isHidden = true
        }
        
        self.configureButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(spinForPurchase),
                                               name: NSNotification.Name(rawValue: "kSpinForPurchase"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(unspinForPurchase),
                                               name: NSNotification.Name(rawValue: "kUnspinForPurchase"),
                                               object: nil)
        self.unspinForPurchase()
        self.setupUserLogin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // since the duration for a SKProduct is not available
    // we need a custtom mapper function to handle that
    func getDuration(_ productID: String) -> String {
        var duration: String = "";
        
        if productID.range(of: "monthly") != nil {duration = "(monthly)"}
        if productID.range(of: " ") != nil {duration = "(yearly)"}
        
        return duration
    }
    
    fileprivate func setupUserLogin() {
        if ZypeUtilities.isDeviceLinked() {
            setupLoggedInUser()
        }
        else {
            setupLoggedOutUser()
        }
    }
    
    fileprivate func setupLoggedInUser() {
        let defaults = UserDefaults.standard
        let kEmail = defaults.object(forKey: kUserEmail)
        guard let email = kEmail else { return }
        
        let loggedInString = NSMutableAttributedString(string: "Logged in as: \(String(describing: email))", attributes: nil)
        let buttonRange = (loggedInString.string as NSString).range(of: "\(String(describing: email))")
        loggedInString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 38.0), range: buttonRange)
        
        accountLabel.attributedText = loggedInString
        accountLabel.textAlignment = .center
        
        loginButton.isHidden = true
    }
    
    fileprivate func setupLoggedOutUser() {
        accountLabel.attributedText = NSMutableAttributedString(string: "Already have an account?")
        loginButton.isHidden = false
    }
    
    // set video that required entitlement
    func setupAssociatedVideo(video: VideoModel) {
        associatedVideo = video
    }

    func onPlanSelected(sender: UIButton) {
        if !ZypeUtilities.isDeviceLinked() {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(onPurchased),
                                                   name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted),
                                                   object: nil)
            ZypeUtilities.presentRegisterVC(self)
        }
        else {
            if let identifier = sender.accessibilityIdentifier {
                if let videoId = associatedVideo.ID as? String {
                    UserDefaults.standard.set(videoId, forKey: "kPurchaseVideoId")
                }

                self.purchase(identifier)
            }
        }
        
        print("\n\n HELLO PURCHASE WORLD \n\n")
        print(sender.tag)
    }
    
    @IBAction func onAttemptCancelSelected(_ sender: Any) {
        self.hideAttemptView()
    }
    
    @IBAction func onAttemptCompleteSelected(_ sender: Any) {
        if "\(self.result)" == self.attemptInputView.text {
            self.attemptCorrectSelected()
        } else {
            self.attemptWrongSelected()
        }
    }
    
    func purchase(_ productID: String) {
        InAppPurchaseManager.sharedInstance.purchase(productID)
    }
    
    func configureButtons() {
        
        stackView = UIStackView()
        stackView.axis = UILayoutConstraintAxis.horizontal
        stackView.distribution = UIStackViewDistribution.fillEqually
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
            var subscriptionProducts: Array<SKProduct> = []
            var consumableProducts: Array<SKProduct> = []

            for product in products {
                let sku = product.productIdentifier
                let productIsSubscription = Const.subscriptionIdentifiers.keys.contains(sku)

                if productIsSubscription {
                    // swaf or subscription required
                    if Const.kSubscribeToWatchAdFree ||
                        (associatedVideo.subscriptionRequired && (Const.kNativeSubscriptionEnabled || Const.kNativeToUniversal)) {
                        subscriptionProducts.append(product)
                    }
                } else {
                    // TODO: add extra check for proper consumable sku when platform supports it
                    if associatedVideo.purchaseRequired && Const.kNativeTvod {
                        consumableProducts.append(product)
                    }
                }
            }

            let productCount: Int = subscriptionProducts.count + consumableProducts.count
            if productCount <= 2 { // if 2 or less, move buttons closer to middle (better UX)
                let leadingConst = (containerView.width * 0.60) - (containerView.width * 0.225 * CGFloat(productCount))
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leadingConst).isActive = true
            }

            for product in subscriptionProducts {
                addProductButton(product)
            }
            for product in consumableProducts {
                addProductButton(product)
            }
        }
    }
    
    func addProductButton(_ product: SKProduct) {
        let productButton = UIButton.init(type: .system)
        productButton.heightAnchor.constraint(equalToConstant: self.containerView.height).isActive = true

        if Const.subscriptionIdentifiers.keys.contains(product.productIdentifier) { // subscription
            productButton.setTitle(String(format: localized("Iap.ButtonFormat"), arguments: [product.localizedTitle, product.localizedPrice()]), for: .normal)
        } else { // regular purchase
            productButton.setTitle(String(format: localized("Iap.ButtonFormat"), arguments: ["Purchase Video", product.localizedPrice()]), for: .normal)
        }

        productButton.accessibilityIdentifier = product.productIdentifier
        productButton.addTarget(self, action: #selector(self.onPlanSelected(sender:)), for: .primaryActionTriggered)
        stackView.addArrangedSubview(productButton)
    }

    @IBAction func onSignIn(_ sender: Any) {
        ZypeUtilities.presentLoginVC(self)
    }
    
    func onPurchased() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK - Attempt View
    
    func calculateRandomNumbers() -> String {
        let firstNumber = Int(arc4random_uniform(9)) + 1
        let secondNumber = Int(arc4random_uniform(9)) + 1
        self.result = firstNumber + secondNumber
        return "How much is \(firstNumber) + \(secondNumber)?"
    }
    
    func showAttemptView(identifier: String) {
        self.attemptInputView.text = ""
        self.attemptInputView.setNeedsFocusUpdate()
        self.productIDSelected = identifier
        self.attemptDecriptionLabel.text = self.calculateRandomNumbers()
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.alpha = 0
            self.attemptView.alpha = 1
        }) { (complete) in
            self.containerView.isHidden = true
            self.attemptView.isHidden = false
            self.containerView.alpha = 1
            self.attemptView.alpha = 1
        }
    }
    
    func hideAttemptView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.alpha = 1
            self.attemptView.alpha = 0
        }) { (complete) in
            self.containerView.isHidden = false
            self.attemptView.isHidden = true
            self.containerView.alpha = 1
            self.attemptView.alpha = 1
        }
    }
    
    func attemptWrongSelected() {
        self.attemptInputView.text = ""
        self.attemptInputView.shake()
    }
    
    func attemptCorrectSelected() {
        self.attemptInputView.text = ""
        self.hideAttemptView()
        if self.productIDSelected != nil {
            self.purchase(self.productIDSelected)
        }
    }
    
    func spinForPurchase() {
        DispatchQueue.main.async {
            self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
            for view in self.view.subviews {
                view.isUserInteractionEnabled = false
            }
        }
    }
    
    func unspinForPurchase() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            for view in self.view.subviews {
                view.isUserInteractionEnabled = true
            }
        }
    }
    
}
