//
//  ZypeSDK.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/20/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class ZypeSDK: NSObject {

    public static let sharedInstance = ZypeSDK()
    public static var debug = false
    
    private var dataManager: ZypeDataManager?
    
    public var consumer: ConsumerModel? {
        return dataManager?.consumer
    }
    
    override init() {
        super.init()
    }
    
    public func initialize(settings: SettingsModel = SettingsModel(),
        loadCategories: Bool = false,
        loadPlaylists: Bool = false,
        completion:(error: NSError?) -> Void)
    {
        dataManager = ZypeDataManager(settings: settings)
        
        let queryModel = QueryAppModel()
        
        dataManager!.getApp(queryModel, completion:{(app, error) in
            print(app)
            self.dataManager!.initializeLoadCategories(loadCategories, error: nil) { (error) -> Void in
                self.dataManager!.initializeLoadPlaylists(loadPlaylists, error: error, completion:completion)
            }
        })
    }
    
    public func reset()
    {
        self.dataManager = nil
    }
    
    //MARK:login
    public func login(username: String, passwd: String, completion:((logedIn: Bool, error: NSError?) -> Void), token: ZypeTokenModel = ZypeTokenModel())
    {
        dataManager?.tokenManager.tokenModel = token
        dataManager == nil ? completion(logedIn: false, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.login(username, passwd: passwd, completion: completion)
    }
    
    public func login(completion:((logedIn: Bool, error: NSError?) -> Void), token: ZypeTokenModel = ZypeTokenModel())
    {
        dataManager?.tokenManager.tokenModel = token
        dataManager == nil ? completion(logedIn: false, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.loadConsumer(completion)
    }
    
    public func createConsumer(consumer: ConsumerModel, completion:(success: Bool, error: NSError?) -> Void)
    {
        dataManager == nil ? completion(success: false, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
            dataManager?.createConsumer(consumer, completion: completion)
    }
    
    public func logOut()
    {
        dataManager?.logOut()
    }
    
    // MARK:Category
    public func getCategories(queryModel: QueryCategoriesModel = QueryCategoriesModel(), completion:(catgories: Array<CategoryModel>?, error: NSError?) -> Void)
    {
        dataManager == nil ? completion(catgories: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.getCategories(queryModel, completion: completion)
    }
    
    public func getStoredCategories() -> Array<CategoryModel>?
    {
        return dataManager == nil ? nil :
            Array(dataManager!.cacheManager.loadedCategories.values)
    }
    
    // MARK:Video
    public func getVideos(queryModel: QueryVideosModel, completion:(videos: Array<VideoModel>?, error: NSError?) -> Void)
    {
        dataManager == nil ? completion(videos: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.getVideos(queryModel, completion: completion)
    }
    
    public func getVideos(completion:((videos: Array<VideoModel>?, error: NSError?) -> Void),
        categoryValue: CategoryValueModel? = nil,
        searchString: String = "",
        keyword: String = "",
        active: Bool = true,
        page: Int = kApiFirstPage,
        perPage: Int = 0)
    {
        let queryModel = QueryVideosModel(categoryValue: categoryValue)
        queryModel.searchString = searchString
        queryModel.keyword = keyword
        queryModel.active = active
        queryModel.page = page
        queryModel.perPage = perPage
        self.getVideos(queryModel, completion: completion)
    }
    
    public func getStoredVideos() -> Array<VideoModel>?
    {
        return dataManager == nil ? nil :
            Array(dataManager!.cacheManager.loadedVideos.values)
    }
    
    internal func getVideoObject(video: VideoModel,  type: VideoUrlType, completion:(playerObject: VideoObjectModel?, error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(playerObject: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
//        }  else if self.consumer!.isLoggedIn == false {
//            completion(url: "", error: NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.getVideoObject(video, type: type, completion: completion)
        }
    }
    
     // MARK: Favorite
    public func getFavorites(completion:(favorites: Array<FavoriteModel>?, error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(favorites: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(favorites: nil, error: NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.getFavorites(completion)
        }
    }
    
    public func getVideoByFavoriteModel(favorite: FavoriteModel, completion:((video: VideoModel?, error: NSError?) -> Void),
        active: Bool = true)
    {
        let queryModel = QueryVideosModel()
        queryModel.perPage = 1
        queryModel.videoID = favorite.objectID
        self.getVideos(queryModel, completion:{(videos, error) in
                completion(video: videos?.first, error: error)
        })
    }
    
    public func setFavorite(object: BaseModel, shouldSet: Bool, completion:(success: Bool, error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(success: false, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(success: false, error: NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.setFavorite(object, shouldSet: shouldSet, completion: completion)
        }
    }
    
    public func getFavoriteModel(object: BaseModel) -> FavoriteModel?
    {
        return dataManager?.cacheManager.findFavoteForObject(object)
    }
    
    // MARK: Zobjects
    public func getZobjectTypes(queryModel: QueryZobjectTypesModel = QueryZobjectTypesModel(), completion:(objectTypes: Array<ZobjectTypeModel>?, error: NSError?) -> Void)
    {
        dataManager == nil ? completion(objectTypes: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.getZobjectTypes(queryModel, completion: completion)
    }
    
    public func getStoredZobjectTypes() -> Array<ZobjectTypeModel>?
    {
        return dataManager == nil ? nil :
            Array(dataManager!.cacheManager.loadedZobjectTypes.values)
    }

    public func getZobjects(queryModel: QueryZobjectsModel = QueryZobjectsModel(), completion:(objects: Array<ZobjectModel>?, error: NSError?) -> Void)
    {
        dataManager == nil ? completion(objects: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
        dataManager?.getZobjects(queryModel, completion: completion)
    }
    
    public func getStoredZobjects() -> Array<ZobjectModel>?
    {
        return dataManager == nil ? nil :
            Array(dataManager!.cacheManager.loadedZobjects.values)
    }
    
    //MARK: Subscriptions
    public func getSubscriptions(queryModel: QuerySubscriptionsModel = QuerySubscriptionsModel(), completion:(subscriptions: Array<SubscriptionModel>?, error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(subscriptions: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(subscriptions: nil, error: NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.getSubscriptions(queryModel, completion: completion)
        }
    }
    
    public func createSubscription(planID: String, completion:(subscription: SubscriptionModel?, error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(subscription: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(subscription: nil, error: NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.createSubscription(planID, completion: completion)
        }
    }
    
    public func retrieveSubscription(subscription: SubscriptionModel, completion:(subscription: SubscriptionModel?, error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(subscription: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(subscription: nil, error: NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.retrieveSubscription(subscription, completion: completion)
        }
    }
    
    public func updateSubscription(planID: String, completion:(subscription: SubscriptionModel?, error: NSError?) -> Void)
    {
        if self.dataManager == nil {
            completion(subscription: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil))
        }  else if self.consumer!.isLoggedIn == false {
            completion(subscription: nil, error: NSError(domain:kErrorDomaine, code: kErrorConsumerNotLoggedIn, userInfo: nil))
        } else {
            dataManager?.updateSubscription(planID, completion: completion)
        }
    }
    
    public func removeSubscription(subscription: SubscriptionModel, completion:(success: Bool, error: NSError?) -> Void)
    {
        dataManager == nil ? completion(success: false, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
            dataManager?.removeSubscription(subscription, completion: completion)
    }
    
    //MARK: play list
    public func getPlaylists(queryModel: QueryPlaylistsModel = QueryPlaylistsModel(), completion:(playlists: Array<PlaylistModel>?, error: NSError?) -> Void)
    {
        dataManager == nil ? completion(playlists: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
            dataManager?.getPlaylists(queryModel, completion: completion)
    }
    
    public func retrieveVideosInPlaylist(queryModel: QueryRetrieveVideosInPlaylistModel, completion:(videos: Array<VideoModel>?, error: NSError?) -> Void)
    {
        dataManager == nil ? completion(videos: nil, error: NSError(domain: kErrorDomaine, code: kErrorSDKNotInitialized, userInfo: nil)) :
            dataManager?.retrieveVideosInPlaylist(queryModel, completion: completion)
    }
    
    public func getStoredPlaylists() -> Array<PlaylistModel>?
    {
        return dataManager == nil ? nil :
            Array(dataManager!.cacheManager.loadedPlaylists.values)
    }
    
    public func getStoredPlaylist(playlistID: String) -> PlaylistModel?
    {
        return dataManager == nil ? nil :
            dataManager!.cacheManager.loadedPlaylists[playlistID]
    }
        
}
