//
//  CategoryValueModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/11/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public class CategoryValueModel: BaseModel {

    private (set) internal weak var parent:CategoryModel?
    
    init(name: String, parent: CategoryModel)
    {
        super.init(ID: SSUtils.categoryToId(parent.titleString, categoryValue: name), title: name)
        self.parent = parent
    }
 
    public func getVideos(loadedSince: NSDate = NSDate(), completion:(videos: Array<VideoModel>?, error: NSError?) -> Void)
    {
        let videos = self.userData["videos"]
        if (videos != nil)
        {
            if(loadedSince.compare(self.userData["videos_date"] as! NSDate) == NSComparisonResult.OrderedAscending)
            {
                completion(videos: videos as? Array<VideoModel>, error: nil)
                return
            }
        }
        ZypeSDK.sharedInstance.getVideos({ (videos, error) -> Void in
            self.userData["videos"] = videos
            self.userData["videos_date"] = NSDate()
            completion(videos: videos, error: error)
        }, categoryValue: self)
    }
    
    public func getPlaylists(loadedSince: NSDate = NSDate(), completion:(playlists: Array<PlaylistModel>?, error: NSError?) -> Void)
    {
        let lists = self.userData["playlists"]
        if lists != nil
        {
            if(loadedSince.compare(self.userData["playlists_date"] as! NSDate) == NSComparisonResult.OrderedAscending)
            {
                completion(playlists: lists as? Array<PlaylistModel>, error: nil)
                return
            }
        }
        ZypeSDK.sharedInstance.getPlaylists(QueryPlaylistsModel(category: self), completion: { (playlists, error) -> Void in
            self.userData["playlists"] = playlists
            self.userData["playlists_date"] = NSDate()
            completion(playlists: playlists, error: error)
        })
    }

}
