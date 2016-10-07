//
//  ZypeRESTController.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/6/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

class ZypeRESTController: NSObject, NSURLSessionDelegate {
    //
    // constants
    //
    
    private let kGetApp = "%@/app/?app_key=%@"

    //favorites
    private let kGetFavorites = "%@/consumers/%@/video_favorites/?access_token=%@&page=%d"
    private let kPostFavorite = "%@/consumers/%@/video_favorites/?access_token=%@&video_id=%@"
    private let kDeleteFavorite = "%@/consumers/%@/video_favorites/%@/?access_token=%@"

    //Zobjects
    private let kGetZobjectTypes = "%@/zobject_types?app_key=%@&page=%d&per_page=%d&keywords=%@"
    private let kGetZobjects = "%@/zobjects/?app_key=%@&zobject_type=%@&page=%d&per_page=%d&keywords=%@"

    //Subscriptions
    private let kGetSubscriptions = "%@/subscriptions/?app_key=%@&page=%d&per_page=%d&q=%@&id=%@&id!=%@"
    private let kCreateSubscription = "%@/subscriptions/?app_key=%@&subscription[%@]=&@"

    //playlists
    private let kGetPlaylists = "%@/playlists?app_key=%@&page=%d&per_page=%d&active=%@&keyword=%@&category[%@]=%@"
    private let kGetRetrieveVideosInPlaylist = "%@/playlists/%@/videos?app_key=%@&page=%d&per_page=%d"

    //OAut
    private let kOAuth_GetToken = "%@/oauth/token"
    private let kAPIConsumerInformation = "%@/consumers/%@/?access_token=%@"

    private let kOAuth_GetTokenByLogin = "username=%@&password=%@&client_id=%@&client_secret=%@&grant_type=password"
    private let kOAuth_UpdateTokenByRefreshToken = "refresh_token=%@&client_id=%@&client_secret=%@&grant_type=refresh_token"
//    private let kOAuth_PostUpdateTokenByRefreshToken = "%@/oauth/token/?client_id=%@&client_secret=%@&refresh_token=%@&grant_type=refresh_token"
    private let kOAuth_GetTokenInfo = "%@/oauth/token/info?access_token=%@"
    private let kOAuth_CreateConsumer = "%@/consumers?app_key=%@&consumer[email]=%@&consumer[name]=%@&consumer[password]=%@"

    //get content
    private let kApiGetCategories = "%@/categories?app_key=%@&page=%d&per_page=%d"
    private let kApiGetListVideos = "%@/videos?app_key=%@&active=%@&on_air=%@&page=%d&per_page=%d" +
        "&category[%@]=%@&category![%@]=%@" +
        "&q=%@&keyword=%@&id=%@&id!=%@&status=%@" +
        "&zobject_id=%@&zobject_id!=%@" +
    "&created_at=%@&published_at=%@&dpt=%@"

    //
    //variables
    //
    private var session: NSURLSession?

    let keys: SettingsModel

    init(settings: SettingsModel)
    {
        self.keys = settings
        super.init()
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = keys.allowAllCertificates ? NSURLSession(configuration: sessionConfiguration, delegate: self,  delegateQueue: nil) :
            NSURLSession(configuration: sessionConfiguration)
    }

    // MARK: OAuth API

    func getTokenWithUsername(username: String, withPassword password: String, withCompletion completion: (jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let escapedPassword = SSUtils.escapedString(password)
        let bodyString = String(format: kOAuth_GetTokenByLogin, username, escapedPassword, keys.clientId, keys.clientSecret)
        let URLString = String(format: kOAuth_GetToken, self.keys.tokenDomain)
        postQuery(URLString, bodyAsString: bodyString, withCompletion: completion)
    }

    func getConsumerIdWithToken(accessToken:String, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
       if (accessToken.isEmpty)
       {
            completion(jsonDic: nil, error: nil)
            return
        }
        let urlAsString = String(format: kOAuth_GetTokenInfo, self.keys.tokenDomain, accessToken)
        self.getQuery(urlAsString, withCompletion: completion)

    }

    func getConsumerInformationWithID(token: String, consumerId: String, withCompletion completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let urlAsString = String(format: kAPIConsumerInformation, self.keys.apiDomain, consumerId, token)
        self.getQuery(urlAsString, withCompletion: completion)
    }

    func refreshAccessTokenWithCompletionHandler(refreshToken:String, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        // Prepare parameters
        if (refreshToken.isEmpty) {
            ZypeLog.write("Invalid refreshToken")
            return;
        }
        let bodyString = String(format: kOAuth_UpdateTokenByRefreshToken , refreshToken, keys.clientId, keys.clientSecret)
        let URLString = String(format: kOAuth_GetToken, self.keys.tokenDomain)
//        let URLString = String(format: kOAuth_PostUpdateTokenByRefreshToken, self.keys.apiDomain, keys.clientId, keys.clientSecret, refreshToken)
        postQuery(URLString, bodyAsString: bodyString, withCompletion: completion)
    }

    func createConsumer(consumer: ConsumerModel, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let urlAsString = String(format: kOAuth_CreateConsumer, self.keys.apiDomain, keys.appKey,
            SSUtils.escapedString(consumer.emailString), SSUtils.escapedString(consumer.nameString), SSUtils.escapedString(consumer.passwordString))
        self.postQuery(urlAsString, bodyAsString: "", withCompletion: completion)
    }

    //MARK: Video API

    func getCategories(query: QueryCategoriesModel, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let perPage = query.perPage == 0 ? kApiMaxItems : query.perPage
        let urlAsString = String(format: kApiGetCategories, self.keys.apiDomain, keys.appKey, query.page, perPage);
        getQuery(urlAsString, withCompletion: completion)
    }

    func getVideos(query: QueryVideosModel, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let categoryKey:String = SSUtils.escapedString(query.categoryKey)
        let categoryValue:String = SSUtils.escapedString(query.categoryValue)
        let exceptCategoryKey:String = SSUtils.escapedString(query.exceptCategoryKey)
        let exceptCategoryValue:String = SSUtils.escapedString(query.exceptCategoryValue)
        let search:String = SSUtils.escapedString(query.searchString)
        let keyword:String = SSUtils.escapedString(query.keyword)
        let perPage:Int = query.perPage == 0 ? kApiMaxItems : query.perPage
        let status:String = SSUtils.escapedString(query.status)
        let createdDate:String = SSUtils.dateToString(query.createdDate)
        let publishedDate:String = SSUtils.dateToString(query.publishedDate)
        var urlAsString:String = String(format: kApiGetListVideos, self.keys.apiDomain, keys.appKey, String(query.active), String(query.onAir), query.page, perPage,
            categoryKey, categoryValue, exceptCategoryKey, exceptCategoryValue,
            search, keyword, query.videoID, query.exceptVideoID, status, query.zObjectID, query.exceptZObjectID,
            createdDate, publishedDate, String(query.dpt));
        if let _ = query.sort {
          urlAsString = String(format: "%@&sort=%@&order=%@", urlAsString, query.sort!, query.ascending ? "asc" : "desc")
        }
        getQuery(urlAsString, withCompletion: completion)
    }

    //MARK:  Favorite API
    func getFavorites(accessToken: String,consumerId: String, page: Int, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let urlAsString = String(format: kGetFavorites, self.keys.apiDomain, consumerId, accessToken, page)
        getQuery(urlAsString, withCompletion: completion)
    }
    
    // MARK: App Settings
    func getApp(queryModel: QueryAppModel, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void) {
        let urlAsString = String(format: kGetApp, self.keys.apiDomain, keys.appKey)
        getQuery(urlAsString, withCompletion: completion)
    }

    func favoriteObject(accessToken: String,consumerId: String, objectID: String, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let urlAsString = String(format: kPostFavorite, self.keys.apiDomain, consumerId, accessToken, objectID)
        postQuery(urlAsString, bodyAsString: "", withCompletion: completion)
    }

    func unfavoriteObject(accessToken: String,consumerId: String, favoriteID: String, completion:(statusCode: Int, error: NSError?) -> Void)
    {
        let urlAsString = String(format: kDeleteFavorite, self.keys.apiDomain, consumerId, favoriteID, accessToken)
        deleteQuery(urlAsString, withCompletion: {(statusCode: Int, jsonDic: Dictionary<String, AnyObject>?, error: NSError?) in
            completion(statusCode: statusCode, error: error)
        })
    }

    //MARK:  Zobjects
    func getZobjectTypes(queryModel: QueryZobjectTypesModel, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let perPage = queryModel.perPage == 0 ? kApiMaxItems : queryModel.perPage
        let keywords = SSUtils.escapedString(queryModel.keywords)
        let urlAsString = String(format: kGetZobjectTypes, self.keys.apiDomain, keys.appKey, queryModel.page, perPage, keywords)
        getQuery(urlAsString, withCompletion: completion)
    }

    func getZobjects(queryModel: QueryZobjectsModel, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let perPage = queryModel.perPage == 0 ? kApiMaxItems : queryModel.perPage
        let type = SSUtils.escapedString(queryModel.zobjectType)
        let keywords = SSUtils.escapedString(queryModel.keywords)
        let urlAsString = String(format: kGetZobjects, self.keys.apiDomain, keys.appKey, type, queryModel.page, perPage, keywords)
        getQuery(urlAsString, withCompletion: completion)
    }

    //MARK: Subscription
    func getSubscriptions(queryModel: QuerySubscriptionsModel, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let perPage = queryModel.perPage == 0 ? kApiMaxItems : queryModel.perPage
        let search = SSUtils.escapedString(queryModel.searchString)
        let urlAsString = String(format: kGetSubscriptions, self.keys.apiDomain, keys.appKey, queryModel.page, perPage, search, queryModel.ID, queryModel.exceptID)
        getQuery(urlAsString, withCompletion: completion)
    }

    func createSubscription(consumerID: String, planID: String, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        completion(jsonDic: nil, error: NSError(domain: kErrorDomaine, code: kErrorNotImplemented, userInfo: nil))
//        let urlAsString = String(format: kCreateSubscription, self.keys.apiDomain, keys.appKey, consumerID, SSUtils.escapedString(consumerID))
//        postQuery(urlAsString, bodyAsString: "", withCompletion: completion)
    }

    func retrieveSubscription(ID: String, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        completion(jsonDic: nil, error: NSError(domain: kErrorDomaine, code: kErrorNotImplemented, userInfo: nil))
    }

    func updateSubscription(consumerID: String, planID: String, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        completion(jsonDic: nil, error: NSError(domain: kErrorDomaine, code: kErrorNotImplemented, userInfo: nil))
    }

    func removeSubscription(ID: String, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        completion(jsonDic: nil, error: NSError(domain: kErrorDomaine, code: kErrorNotImplemented, userInfo: nil))
    }

    //MARK: Playlist
    func getPlaylists(queryModel: QueryPlaylistsModel, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let perPage = queryModel.perPage == 0 ? kApiMaxItems : queryModel.perPage
        let urlAsString = String(format: kGetPlaylists, self.keys.apiDomain, keys.appKey, queryModel.page, perPage,
            String(queryModel.active),  SSUtils.escapedString(queryModel.keyword),
            SSUtils.escapedString(queryModel.categoryKey), SSUtils.escapedString(queryModel.categoryValue))
        getQuery(urlAsString, withCompletion: completion)
    }

    func retrieveVideosInPlaylist(queryModel: QueryRetrieveVideosInPlaylistModel, completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)
    {
        let perPage = queryModel.perPage == 0 ? kApiMaxItems : queryModel.perPage
        let urlAsString = String(format: kGetRetrieveVideosInPlaylist, self.keys.apiDomain, queryModel.playlistID, keys.appKey, queryModel.page, perPage)
        getQuery(urlAsString, withCompletion: completion)
    }

//private
      private func deleteQuery(urlAsString: String,
        withCompletion completion:(statusCode: Int, jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)  -> NSURLSessionDataTask
    {
        return query("DELETE", urlAsString: urlAsString, bodyAsString: "", withCompletion: completion)
    }

    func getQuery(urlAsString: String,
        withCompletion completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)  -> NSURLSessionDataTask
    {
        return query("GET", urlAsString: urlAsString, bodyAsString: "",
            withCompletion: {(statusCode, jsonDic, error) in
            completion(jsonDic: jsonDic, error: error)
        })
    }

    private func postQuery(urlAsString: String, bodyAsString: String,
        withCompletion completion:(jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void)  -> NSURLSessionDataTask
    {
        return query("POST", urlAsString: urlAsString, bodyAsString: bodyAsString,
            withCompletion: {(statusCode, jsonDic, error) in
            completion(jsonDic: jsonDic, error: error)
        })
    }

    private func query(method: String, urlAsString: String, bodyAsString: String,
        withCompletion completion:(statusCode: Int, jsonDic: Dictionary<String, AnyObject>?, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        ZypeLog.write("\(method) Query: \(urlAsString) \(bodyAsString)")
        let request = NSMutableURLRequest(URL: NSURL(string: urlAsString)!)
        request.HTTPMethod = method
        request.HTTPBody = bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
        if self.keys.userAgent.isEmpty == false
        {
            request.setValue(self.keys.userAgent, forHTTPHeaderField:"User-Agent")
        }
        let task = session!.dataTaskWithRequest(request) {
            (let data, let response, var error) in
            ZypeLog.assert(error == nil, message: "http error: \(error)")
            var statusCode = 0
            if response != nil
            {
                statusCode = (response as! NSHTTPURLResponse).statusCode
            }
            var jsonDic: Dictionary<String, AnyObject>?
            if data != nil && data!.length != 0
            {
                do
                {
                    jsonDic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? Dictionary <String, AnyObject>
                }
                catch _
                {
                    let dataString = String(data:data!, encoding:NSUTF8StringEncoding)
                    ZypeLog.error("JSON Parse Error \(dataString)")
                    error = NSError(domain: kErrorDomaine, code: kErrorJSONParsing, userInfo: ["data" : dataString!])
                }
            }
            completion(statusCode: statusCode, jsonDic: jsonDic, error: error)
        }
        task.resume()
        return task
    }

    //delegate
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        let credential = NSURLCredential(trust:challenge.protectionSpace.serverTrust!)
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential);
    }

}
