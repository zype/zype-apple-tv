//
//  InAppPurchaseManager.swift
//  AndreySandbox
//
//  Created by Eric Chang on 5/19/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import StoreKit

extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
}


class RequestDelegate: NSObject, SKRequestDelegate {
    var callback: (_ data: AnyObject?, _ error: NSError?)->()
    
    init(callback: @escaping (_ data: AnyObject?, _ error: NSError?)->()) {
        self.callback = callback
        super.init()
    }
    
    func requestDidFinish(_ request: SKRequest){
        self.callback(nil, nil)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.callback(nil, error as NSError)
    }
}


class ProductsRequestDelegate: RequestDelegate, SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid Identifier \(invalidIdentifier)")
        }
        self.callback(response.products as AnyObject, nil)
    }
    
    override func requestDidFinish(_ request: SKRequest) {
        
    }
    
    override func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("Subscription Options Failed Loading: \(error.localizedDescription)")
        }
    }
}

class InAppPurchaseManager: NSObject, SKPaymentTransactionObserver {
    
    // MARK: - Properties
    
    static let sharedInstance = InAppPurchaseManager()
    static let kPurchaseErrorDomain = "InAppPurchase"
    static let kPurchaseCompleted = "kPurchaseCompleted"
    
    var lastSubscribeStatus: Bool = false
    fileprivate(set) var products: Dictionary<String, SKProduct>?
    fileprivate var productID: NSSet?
    fileprivate var productsRequestDelegate: ProductsRequestDelegate?
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var receiptRenewRequest: SKReceiptRefreshRequest?
    fileprivate var requestDelegate: RequestDelegate?
    fileprivate var commonError = NSError(domain: InAppPurchaseManager.kPurchaseErrorDomain, code: 999, userInfo: nil)
    fileprivate var restoringCallback: ((Bool, NSError?)->()) = { _ in }
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - Get Subscription Options
    
    func requestProducts(_ callback: @escaping (NSError?)->()) {
        if(self.products != nil) {
            callback(nil)
            return
        }
        let productIdentifiers: NSSet = NSSet(array: Const.productIdentifiers)
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        self.productsRequestDelegate = ProductsRequestDelegate(callback: {(data: AnyObject?, error: NSError?) in
            if(error != nil || data == nil) {
                callback(error ?? self.commonError)
                return
            }
            if let products = data as? Array<SKProduct> {
                self.products = [String : SKProduct]()
                for product in products {
                    self.products![product.productIdentifier] = product
                }
                callback(nil)
            } else {
                callback(self.commonError)
            }
        });
        self.productsRequest = productsRequest
        productsRequest.delegate = self.productsRequestDelegate
        productsRequest.start()
    }
    
    // MARK: - Get Subscription Status
    
    func checkSubscription(_ callback: @escaping (_ isSubscripted: Bool, _ expirationDate: Date?, _ error: NSError?)->()) {
        self.checkReceipt({ (error: NSError?) in
            if(error == nil) {
                self.sendExpirationRequest(callback)
            } else {
                self.lastSubscribeStatus = false
                callback(false, nil, error)
            }
        })
    }
    
    func checkReceipt(_ callback: @escaping (_ error: NSError?)->()) {
        if let _ = self.receiptURL() {
            callback(nil)
        } else {
            let renewRequest = SKReceiptRefreshRequest()
            self.requestDelegate = RequestDelegate(callback: {(data: AnyObject?, error: NSError?) in
                if let _ = data {
                    callback(nil)
                } else {
                    callback(error ?? self.commonError)
                }
            })
            self.receiptRenewRequest = renewRequest
            renewRequest.delegate = self.requestDelegate
            renewRequest.start()
        }
    }
    
    func receiptURL() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        }
        catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
    
    func refreshSubscriptionStatus() {
        self.checkSubscription({ (isSubscripted: Bool, expirationDate: Date?, error: NSError?) in
            self.setSubscriptionStatus(isSubscribed: isSubscripted)
        })
    }
    
    func setSubscriptionStatus(isSubscribed: Bool) {
        self.lastSubscribeStatus = isSubscribed
    }
    
    // MARK: - Subscription Status Helpers
    
    func sendExpirationRequest(_ callback: @escaping (_ isNotExpired: Bool, _ date: Date?, _ error: NSError?)->()) {
        if let receiptData = self.receiptURL() {
            let receiptDictionary = ["receipt-data" : receiptData.base64EncodedString(),
                                     "password" : Const.appstorePassword]
            let requestData = try! JSONSerialization.data(withJSONObject: receiptDictionary, options: [])
            var storeRequest = URLRequest(url: Const.kStoreURL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            let task = session.dataTask(with: storeRequest) { (data, response, error) in
                DispatchQueue.main.async(execute: {() in
                    if error == nil,
                        let jsonResponse = self.deserializeJSON(data!),
                        let expirationDate: Date = self.expirationDateFromResponse(jsonResponse),
                        let currentDate = self.dateFromResponse(response) {
                        
                        let isNotExpired = currentDate?.compare(expirationDate) == .orderedAscending
                        self.lastSubscribeStatus = isNotExpired
                        callback(isNotExpired, expirationDate, nil)
                    }
                    else {
                        self.lastSubscribeStatus = false
                        if let error = error {
                            callback(false, nil, error as NSError)
                        }
                    }
                })
            }
            task.resume()
        }
    }
    
    func updateIAPExpirationDate(_ date: Date) {
        
    }
    
    func dateFromResponse(_ response: URLResponse?) -> Date?? {
        if let httpResponse = response as? HTTPURLResponse, let dateStr = httpResponse.allHeaderFields["Date"] as? String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
            formatter.timeZone = TimeZone(identifier: "GMT")
            if let currentDate = formatter.date(from: dateStr) as Date! {
                return currentDate
            }
        }
        return nil
    }
    
    func expirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            if let expirationDate = formatter.date(from: lastReceipt["expires_date"] as! String) as Date! {
                return expirationDate
            }
        }
        return nil
    }
    
    // MARK: - Payments
    
    func restorePurchases(_ restoringCallback: ((Bool, NSError?)->())? = nil){
        if let _ = restoringCallback {
            self.restoringCallback = restoringCallback!
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.restoringCallback(true, nil)
        self.restoringCallback = {_ in}
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        let error = error as NSError
        self.restoringCallback(false, error)
        self.restoringCallback = {_ in}
    }
    
    
    func purchase(_ productID: String) {
        if SKPaymentQueue.canMakePayments() {
            self.requestProducts({(error: NSError?) in
                if let product: SKProduct = self.products![productID] {
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.default().add(payment);
                }
            })
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased, .restored, .failed:
                    if trans.transactionState != .failed {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted), object: nil)
                        InAppPurchaseManager.sharedInstance.lastSubscribeStatus = true
                    }
                    SKPaymentQueue.default().finishTransaction(trans)
                    break
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - JSON Helpers
    
    func serializeJSON(_ dict: AnyObject) -> Data? {
        var data: Data? = nil
        do {
            try data = JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        }
        catch {}
        return data
    }
    
    func deserializeJSON(_ json: Data) -> NSDictionary? {
        var data: NSDictionary? = nil
        do {
            try data = JSONSerialization.jsonObject(with: json, options: .mutableContainers) as? NSDictionary
        }
        catch {}
        return data
    }
}
