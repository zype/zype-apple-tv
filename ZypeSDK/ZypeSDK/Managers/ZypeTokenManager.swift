//
//  ZypeTokenManager.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/7/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

class ZypeTokenManager {
    
    private let kApiKey_AccessToken = "access_token"
    private let kApiKey_RefreshToken = "refresh_token"
    private let kApiKey_CreatedAt  = "created_at"
    private let kApiKey_ExpiresIn = "expires_in"
    
    let kTokenAcceptableBuffer:Int = 600
    
    var tokenModel = ZypeTokenModel()
    
    func accessToken(completion: (token: String) ->Void, update:(refreshToken:String, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void) ->Void)
    {
        if tokenModel.refreshToken.isEmpty
        {
            ZypeLog.error("try to use emply refresh token")
            completion(token: tokenModel.accessToken)
        }
        else if isAccessTokenExpired() == false
        {
            completion(token: tokenModel.accessToken)
        }
        else
        {
            update(refreshToken: tokenModel.refreshToken, completion:{(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void in
                ZypeLog.assert(error == nil && jsonDic != nil, message: "error get new token")
                if jsonDic != nil
                {
                    if self.setAccessTokenData(jsonDic!) == false
                    {
                        ZypeLog.error("parse new token error")
                    }
                }
                completion(token: self.tokenModel.accessToken)
            })
        }
    }
    
    func setLoginAccessTokenData(data: Dictionary<String, AnyObject>) -> NSError?
    {
        if setAccessTokenData(data) == false
        {
            return  NSError(domain: kErrorDomaine, code: kErrorIncorrectLoginParameters, userInfo: data as! Dictionary<String, String>)
        }
        return nil
    }
    
    //private
    
    private func isAccessTokenExpired() -> Bool
    {
        let currentDate = Int(NSDate().timeIntervalSince1970)
        return currentDate >= (tokenModel.expirationDate - kTokenAcceptableBuffer)
    }
    
    private func setAccessTokenData(data: Dictionary<String, AnyObject>) -> Bool?
    {
        do
        {
            let access = try SSUtils.stringFromDictionary(data, key: kApiKey_AccessToken)
            let refresh = try SSUtils.stringFromDictionary(data, key: kApiKey_RefreshToken)
            let createdAt = try SSUtils.intagerFromDictionary(data, key: kApiKey_CreatedAt)
            let expiresIn = try SSUtils.intagerFromDictionary(data, key: kApiKey_ExpiresIn)
            let expirationDate = createdAt + expiresIn
            tokenModel.accessToken = access
            tokenModel.refreshToken = refresh
            tokenModel.expirationDate = expirationDate
        }
        catch _
        {
            return false
        }
        return true
    }

}
