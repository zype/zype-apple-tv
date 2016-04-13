//
//  ZypeСacheManager.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/16/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class ZypeCacheManager: NSObject {
    
    private(set) internal var loadedVideos = Dictionary<String, VideoModel>()
    private(set) var favorites = Array<FavoriteModel>()
    private(set) internal var loadedPlaylists = Dictionary<String, PlaylistModel>()
    private(set) internal var loadedCategories = Dictionary<String, CategoryModel>()
    private(set) internal var loadedZobjectTypes = Dictionary<String, ZobjectTypeModel>()
    private(set) internal var loadedZobjects = Dictionary<String, ZobjectModel>()
    
    func resetConsumer()
    {
        favorites.removeAll()
    }
    
    func synchronizePlaylists(playlists: Array<PlaylistModel>) -> Array<PlaylistModel>
    {
        var sortedPlaylists = playlists.sort({$0.priority < $1.priority})
        return self.synchronizeObjects(&loadedPlaylists, addObjects: playlists)!
    }
    
    func synchronizeVideos(videos: Array<VideoModel>?) -> Array<VideoModel>?
    {
       return self.synchronizeObjects(&loadedVideos, addObjects: videos)
    }
    
    func synchronizeCategories(categories: Array<CategoryModel>?) -> Array<CategoryModel>?
    {
        return self.synchronizeObjects(&loadedCategories, addObjects: categories)
    }
    
    func synchronizeZobjectTypes(zobjectType: Array<ZobjectTypeModel>?) -> Array<ZobjectTypeModel>?
    {
        return self.synchronizeObjects(&loadedZobjectTypes, addObjects: zobjectType)
    }
    
    func synchronizeZobjects(zobjects: Array<ZobjectModel>?) -> Array<ZobjectModel>?
    {
        return self.synchronizeObjects(&loadedZobjects, addObjects: zobjects)
    }
    
    func addFavoriteVideos(data: Array<FavoriteModel>?)
    {
        if (data != nil)
        {
            self.favorites.appendContentsOf(data!)
        }
    }
    
    func removeFromFavorites(favoriteObject: FavoriteModel)
    {
        ZypeLog.assert(favorites.contains(favoriteObject),message: "can not remove video from favorites")
        favorites.removeAtIndex(favorites.indexOf(favoriteObject)!)
    }
    
    func findFavoteForObject(object: BaseModel) -> FavoriteModel?
    {
        let filteredArray = favorites.filter({(item) -> Bool in
            return item.objectID == object.ID
        })
        return filteredArray.first
    }
    
    private func synchronizeObjects<T>(inout loaded: Dictionary<String, T>, addObjects: Array<T>?) -> Array<T>?
    {
        if addObjects != nil
        {
            var filteredArray = Array<T>()
            for value in addObjects!
            {
                let ID = (value as! BaseModel).ID
                let object = loaded[ID]
                if object == nil
                {
                    loaded[ID] = value
                    filteredArray.append(value)
                }
                else
                {
                    filteredArray.append(loaded[ID]!)
                }
            }
            return filteredArray
        }
        return nil
    }
    
}
