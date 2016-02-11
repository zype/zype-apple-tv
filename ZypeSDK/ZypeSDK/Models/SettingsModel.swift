//
//  SettingsModel.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 10/26/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//


public class SettingsModel: NSObject
{
    //keys
    internal let appKey: String
    internal let clientId: String
    internal let clientSecret: String

    //hosts
    internal let apiDomain: String
    internal let tokenDomain: String
    internal let playerDomain: String

    //network
    internal let allowAllCertificates: Bool
    internal let userAgent: String

    public init (clientID: String = kOAuthClientId,
        secret: String = kOAuthClientSecret,
        appKey: String = kAppKey,
        apiDomain: String = kApiDomain,
        tokenDomain: String = KOAuth_GetTokenDomain,
        playerDomain: String = kPlayerDomain,
        allowAllCertificates: Bool = false,
        userAgent: String = "")
    {
        self.clientId = clientID
        self.clientSecret = secret
        self.appKey = appKey
        self.apiDomain = apiDomain
        self.tokenDomain = tokenDomain
        self.playerDomain = playerDomain
        self.allowAllCertificates = allowAllCertificates
        self.userAgent = userAgent
        super.init()
    }

}
