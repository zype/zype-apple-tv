//
//  ZypeDataManager.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/8/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

class ZypeDataManager : NSObject {

    //private
    private let serviceController: ZypeRESTController

    //public
    internal let cacheManager = ZypeCacheManager()
    private(set) internal var tokenManager = ZypeTokenManager()
    private(set) internal var consumer = ConsumerModel()

    //MARK: initialize
    init(settings: SettingsModel)
    {
        serviceController = ZypeRESTController(settings: settings)
        super.init()
    }

    func initializeLoadCategories(load: Bool, error: NSError?, completion: (error: NSError?) ->Void)
    {
        if load == false || error != nil
        {
            completion(error: error)
        }
        else
        {
            self.getCategories(QueryCategoriesModel(), completion: { (_, error) -> Void in
                completion(error: error)
            })
        }
    }

    func initializeLoadPlaylists(load: Bool, error: NSError?, completion: (error: NSError?) ->Void)
    {
        if load == false || error != nil
        {
            completion(error: error)
        }
        else
        {
            self.getPlaylists(QueryPlaylistsModel(), completion: { (_, error) -> Void in
                completion(error: error)
            })
        }
    }

    //MARK: Login
    func logOut()
    {
        tokenManager.tokenModel.reset()
        consumer.reset()
        cacheManager.resetConsumer()
    }

    func login(username: String, passwd: String, completion:(logedIn: Bool, error: NSError?) -> Void)
    {
        serviceController.getTokenWithUsername(username, withPassword: passwd, withCompletion: {(data, error) -> Void in
            if (error != nil)
            {
                self.loginCompletion(false, error: error, completion: completion)
            }
            else if (data == nil)
            {
                self.loginCompletion(false, error: NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: nil), completion: completion)
            }
            else
            {
                let error = self.tokenManager.setLoginAccessTokenData(data!)
                if (error != nil)
                {
                    self.loginCompletion(false, error: error, completion: completion)
                }
                else
                {
                    self.loadConsumer(completion)
                }
            }
       })
    }

    func loadConsumer(completion:(success: Bool, error: NSError?) -> Void)
    {
        if (tokenManager.tokenModel.refreshToken.isEmpty)
        {
            self.loginCompletion(false, error: nil, completion:completion)
            return
        }
        tokenManager.accessToken({ (token) -> Void in
            self.serviceController.getConsumerIdWithToken(token, completion: { (jsonDic, error) -> Void in
                do
                {
                    let idString = try SSUtils.stringFromDictionary(jsonDic, key: kJSONResourceOwnerId)
                    if (idString.isEmpty == false)
                    {
                        self.serviceController.getConsumerInformationWithID(token, consumerId: idString, withCompletion: { (jsonDic, error) -> Void in
                            do
                            {
                                if (jsonDic != nil)
                                {
                                    let response = jsonDic![kJSONResponse] as! Dictionary <String, AnyObject>?
                                    if (response != nil)
                                    {
                                        let emailString = try SSUtils.stringFromDictionary(response, key: kJSONEmail)
                                        let nameString = try SSUtils.stringFromDictionary(response, key: kJSONName)
                                        dispatch_sync(dispatch_get_main_queue(),{
                                            self.consumer.setData(idString, email: emailString, name: nameString)
                                        })
                                        self.loginCompletion(self.consumer.isLoggedIn, error: error, completion: completion)
                                        return
                                    }
                                }
                            }
                            catch _
                            {
                            }
                            self.loginCompletion(false, error: error, completion: completion)
                        })
                        return
                    }
                }
                catch _
                {
                }
                self.loginCompletion(false, error: error, completion: completion)
            })
        }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }

    func createConsumer(consumer: ConsumerModel, completion:(success: Bool, error: NSError?) -> Void)
    {
        self.serviceController.createConsumer(consumer) { (jsonDic, var error) -> Void in
            var success = false
            if error == nil && jsonDic != nil
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    success = true
                }
            }
            dispatch_sync(dispatch_get_main_queue(),{
                completion(success: success, error: error)
            })
        }
    }

    //MARK: Categories
    func getCategories(queryModel: QueryCategoriesModel, var toArray: Array<CategoryModel> = Array<CategoryModel>(),
        completion:(categories: Array<CategoryModel>, error: NSError?) -> Void)
    {
        serviceController.getCategories(queryModel, completion: { (jsonDic, var error) -> Void in
            if (jsonDic != nil && error == nil)
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    let data = response as? Array <AnyObject>
                    if (data != nil)
                    {
                        for value in data!
                        {
                            let category  = CategoryModel(fromJson: value as! Dictionary<String, AnyObject>)
                            toArray.append(category)
                        }
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page++
                        self.getCategories(queryModel, toArray: toArray, completion: completion)
                        return
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(categories: self.cacheManager.synchronizeCategories(toArray)!, error: error)
            })
        })
    }

    //MARK: Videos
    func getVideos(queryModel: QueryVideosModel, var returnArray: Array<VideoModel> = Array<VideoModel>(),
        completion:((videos: Array<VideoModel>?, error: NSError?) -> Void))
    {
        serviceController.getVideos(queryModel, completion:{ (jsonDic, var error) -> Void in
            if jsonDic != nil
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    let videos = self.jsonToVideosArrayPrivate(jsonDic)
                    if (videos != nil)
                    {
                        returnArray.appendContentsOf(videos!)
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page++
                        self.getVideos(queryModel, returnArray: returnArray, completion: completion)
                        return
                    }
                }
            }
            self.videoCompletion(returnArray, error: error, completion:completion)
        })
    }

    //TODO need  add subscriptions and test
    func getVideoObject(video: VideoModel, type: VideoUrlType, completion:(playerObject: VideoObjectModel?, error: NSError?) -> Void)
    {
        ZypeFactory.videoUrl(type, restController: serviceController)?.getVideoObject(video, completion: {(player, error) in
            dispatch_async(dispatch_get_main_queue(), {
                completion(playerObject: player, error: error)
            })
        })
    }

   //MARK: favorites
    func getFavorites(completion:(favorites: Array<FavoriteModel>?, error: NSError?) -> Void)
    {
        completion(favorites: cacheManager.favorites, error: nil)
    }

    func setFavorite(object: BaseModel, shouldSet: Bool, completion:(success: Bool, error: NSError?) -> Void)
    {
        let favoriteObject: FavoriteModel? = shouldSet == true ? nil : cacheManager.findFavoteForObject(object)
        if (shouldSet == false && favoriteObject == nil)
        {
            completion(success: false, error: NSError(domain: kErrorDomaine, code: kErrorItemNotInFavorites, userInfo: nil))
            return
        }
        tokenManager.accessToken({ (token) -> Void in
            if (shouldSet == true)
            {
                self.favoriteVideo(token, object: object, completion: completion)
            }
            else
            {
                self.unfavoriteVideo(token, favoriteObject: favoriteObject!, completion: completion)
            }
         }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }
    
    //MARK: app
    func getApp(queryModel: QueryAppModel, completion: (app: AppModel?, error: NSError?) -> Void)
    {
        self.serviceController.getApp(queryModel, completion: {(jsonDic, var error) -> Void in
            var app: AppModel?
            if (jsonDic != nil)
            {
                error = self.isServiceError(jsonDic!)
                if error == nil {
                    app = AppModel(fromJson: jsonDic![kJSONResponse] as! Dictionary<String, AnyObject>)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    completion(app: app, error: error)
                })
            }
        })
    }
    
    //MARK: zobjects
    func getZobjectTypes(queryModel: QueryZobjectTypesModel, var toArray: Array<ZobjectTypeModel> = Array<ZobjectTypeModel>(),
        completion:(objectTypes: Array<ZobjectTypeModel>, error: NSError?) -> Void)
    {
        self.serviceController.getZobjectTypes(queryModel) { (jsonDic, var error) -> Void in
            if (jsonDic != nil)
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    for value in response as! Array<AnyObject>
                    {
                        toArray.append(ZobjectTypeModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                }
            }
            if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
            {
                queryModel.page++
                self.getZobjectTypes(queryModel, toArray: toArray, completion: completion)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(objectTypes: self.cacheManager.synchronizeZobjectTypes(toArray)!, error: error)
            })
        }
    }

    func getZobjects(queryModel: QueryZobjectsModel, var toArray: Array<ZobjectModel> = Array<ZobjectModel>(),
        completion:(objects: Array<ZobjectModel>, error: NSError?) -> Void)
    {
        self.serviceController.getZobjects(queryModel, completion: {(jsonDic, var error) -> Void in
            if (jsonDic != nil)
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    for value in response as! Array<AnyObject>
                    {
                        toArray.append(ZobjectModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                }
            }
            if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
            {
                queryModel.page++
                self.getZobjects(queryModel, toArray: toArray, completion: completion)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(objects: self.cacheManager.synchronizeZobjects(toArray)!, error: error)
            })
        })
    }

    //MARK: Subscriptions
    //TODO need convert subscription from json to model
    func getSubscriptions(queryModel: QuerySubscriptionsModel, var toArray: Array<SubscriptionModel> = Array<SubscriptionModel>(),
        completion:(subscriptions: Array<SubscriptionModel>, error: NSError?) -> Void)
    {
        self.serviceController.getSubscriptions(queryModel, completion: { (jsonDic, var error) -> Void in
            if (jsonDic != nil)
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    let response = jsonDic![kJSONResponse]
                    for value in response as! Array<AnyObject>
                    {
                        toArray.append(SubscriptionModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page++
                        self.getSubscriptions(queryModel, toArray: toArray, completion: completion)
                        return
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(subscriptions: toArray, error: error)
            })
        })
    }

    //TODO need api not work
    func createSubscription(planID: String, completion:(subscription: SubscriptionModel?, error: NSError?) -> Void)
    {
        self.serviceController.createSubscription(self.consumer.ID, planID: planID, completion:{ (jsonDic, var error) -> Void in
            var subscription: SubscriptionModel?
            if (jsonDic != nil)
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    subscription = SubscriptionModel(fromJson: jsonDic![kJSONResponse] as! Dictionary<String, AnyObject>)
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(subscription: subscription, error: error)
            })
        })
    }

    func retrieveSubscription(subscription: SubscriptionModel, completion:(subscription: SubscriptionModel?, error: NSError?) -> Void)
    {
        self.serviceController.retrieveSubscription(subscription.ID, completion:{ (jsonDic, var error) -> Void in
            var subscription: SubscriptionModel?
            if (jsonDic != nil)
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    subscription = SubscriptionModel(fromJson: jsonDic![kJSONResponse] as! Dictionary<String, AnyObject>)
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(subscription: subscription, error: error)
            })
        })
    }

    func updateSubscription(planID: String, completion:(subscription: SubscriptionModel?, error: NSError?) -> Void)
    {
        self.serviceController.updateSubscription(self.consumer.ID, planID: planID, completion: {(jsonDic, var error) -> Void in
            var subscription: SubscriptionModel?
            if (jsonDic != nil)
            {
                error = self.isServiceError(jsonDic!)
                if (error == nil)
                {
                    subscription = SubscriptionModel(fromJson: jsonDic![kJSONResponse] as! Dictionary<String, AnyObject>)
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(subscription: subscription, error: error)
            })
        })
    }

    func removeSubscription(subscription: SubscriptionModel, completion:(success: Bool, error: NSError?) -> Void)
    {
        self.serviceController.removeSubscription(subscription.ID, completion: { (jsonDic, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                completion(success: false, error: error)
            })
        })
    }

    //MARK: play list
    func getPlaylists(queryModel: QueryPlaylistsModel, var toArray: Array<PlaylistModel> = Array<PlaylistModel>(),
        completion:(playlists: Array<PlaylistModel>, error: NSError?) -> Void)
    {
        self.serviceController.getPlaylists(queryModel, completion: { (jsonDic, var error) -> Void in
            if jsonDic != nil
            {
                error = self.isServiceError(jsonDic!)
                if error == nil
                {
                    for value in jsonDic![kJSONResponse] as! Array<AnyObject>
                    {
                        toArray.append(PlaylistModel(fromJson: value as! Dictionary<String, AnyObject>))
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page++
                        self.getPlaylists(queryModel, toArray: toArray, completion: completion)
                        return
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(playlists: self.cacheManager.synchronizePlaylists(toArray), error: error)
            })
        })
    }

    func retrieveVideosInPlaylist(queryModel: QueryRetrieveVideosInPlaylistModel, var toArray: Array<VideoModel> = Array<VideoModel>(),
        completion:(videos: Array<VideoModel>?, error: NSError?) -> Void)
    {
        self.serviceController.retrieveVideosInPlaylist(queryModel, completion: { (jsonDic, var error) -> Void in
            if jsonDic != nil
            {
                error = self.isServiceError(jsonDic!)
                if error == nil
                {
                    let videos = self.jsonToVideosArrayPrivate(jsonDic)
                    if (videos != nil)
                    {
                        toArray.appendContentsOf(videos!)
                    }
                    if (queryModel.perPage == 0 && self.isLastPage(jsonDic) == false)
                    {
                        queryModel.page++
                        self.retrieveVideosInPlaylist(queryModel, toArray: toArray, completion: completion)
                        return
                    }
                }
            }
            self.videoCompletion(toArray, error: error, completion:completion)
        })
    }

    //MARK: Private
    private func loadFavorites(page: Int = kApiFirstPage)
    {
        tokenManager.accessToken({ (token) -> Void in
            self.serviceController.getFavorites(token, consumerId: self.consumer.ID, page: page, completion: { (jsonDic, error) -> Void in
                let favorites = self.jsonToFavoriteArrayPrivate(jsonDic)
                if (favorites != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.cacheManager.addFavoriteVideos(favorites)
                    })
                }
                if (self.isLastPage(jsonDic) == false)
                {
                    self.loadFavorites(page + 1)
                }
            })
        }, update: serviceController.refreshAccessTokenWithCompletionHandler)
    }

    private func favoriteVideo(token: String, object: BaseModel, completion:(success: Bool, error: NSError?) -> Void)
    {
        self.serviceController.favoriteObject(token, consumerId: self.consumer.ID, objectID: object.ID, completion: { (jsonDic, var error) -> Void in
            let favorites = self.jsonToFavoriteArrayPrivate(jsonDic)
            let success = favorites != nil && favorites?.isEmpty == false && favorites?.first?.objectID == object.ID
            if (success == false && jsonDic != nil)
            {
                 error = NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: jsonDic as? Dictionary<String, String>)
            }
            dispatch_async(dispatch_get_main_queue(), {
                if (success == true)
                {
                    self.cacheManager.addFavoriteVideos(favorites)
                }
                completion(success: success, error: error)
            })
        })
    }

    private func unfavoriteVideo(token: String, favoriteObject: FavoriteModel, completion:(success: Bool, error: NSError?) -> Void)
    {
        self.serviceController.unfavoriteObject(token, consumerId: self.consumer.ID, favoriteID: favoriteObject.ID, completion: { (statusCode, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (statusCode == kHTTPCodeNoContent)
                {
                    self.cacheManager.removeFromFavorites(favoriteObject)
                }
                completion(success: statusCode == kHTTPCodeNoContent, error: error)
            })
        })
    }

    private func loginCompletion(logedIn: Bool, error: NSError?, completion:(logedIn: Bool, error: NSError?) -> Void)
    {
        dispatch_async(dispatch_get_main_queue(),{
            completion(logedIn: logedIn, error: error)
        })
        if (logedIn == true)
        {
            loadFavorites()
        }
    }

    private func videoCompletion(videos: Array<VideoModel>?, error: NSError? ,completion:(videos: Array<VideoModel>?, error: NSError?) -> Void)
    {
        dispatch_async(dispatch_get_main_queue(), {
            completion(videos: self.cacheManager.synchronizeVideos(videos), error: error)
        })
    }

    private func jsonToFavoriteArrayPrivate(jsonDic: Dictionary<String, AnyObject>?) -> Array<FavoriteModel>?
    {
        if (jsonDic != nil)
        {
            let response = jsonDic![kJSONResponse]
            if (response != nil)
            {
                var array = Array<FavoriteModel>()
                if (response as? Array<AnyObject> == nil)
                {
                     array.append(FavoriteModel(json: response as! Dictionary<String, AnyObject>))
                }
                else
                {
                    for value in response as! Array<AnyObject>
                    {
                        array.append(FavoriteModel(json: value as! Dictionary<String, AnyObject>))
                    }
                }
                return array
            }
        }
        return nil
    }

    private func jsonToVideosArrayPrivate(jsonDic: Dictionary<String, AnyObject>?) -> Array<VideoModel>?
    {
        if (jsonDic != nil)
        {
            let response = jsonDic![kJSONResponse]
            if (response != nil)
            {
                var dataArray = Array<VideoModel>()
                for value in (response as? Array<AnyObject>)!
                {
                    dataArray.append(VideoModel(fromJson: (value as? Dictionary<String, AnyObject>)!))
                }
                return dataArray
            }
        }
        return nil
    }

    private func isServiceError(jsonDic: Dictionary<String, AnyObject>, shouldContainsField: String = kJSONResponse) -> NSError?
    {
        let response = jsonDic[shouldContainsField]
        if (response != nil)
        {
            return nil
        }
        return NSError(domain: kErrorDomaine, code: kErrorServiceError, userInfo: jsonDic as? Dictionary<String, String>)
    }

    private func isLastPage(jsonDic:Dictionary<String, AnyObject>?) -> Bool
    {
        do
        {
            if (jsonDic != nil)
            {
                let pagination = jsonDic![kJSONPagination]
                if ((pagination) != nil)
                {
                    let pages = try SSUtils.intagerFromDictionary(pagination as? Dictionary<String, AnyObject>, key: kJSONPages)
                    let current = try SSUtils.intagerFromDictionary(pagination as? Dictionary<String, AnyObject>, key: kJSONCurrent)
                    if (current < pages)
                    {
                        return false
                    }
                }
            }
        }
        catch _
        {
        }
        return true
    }

}
