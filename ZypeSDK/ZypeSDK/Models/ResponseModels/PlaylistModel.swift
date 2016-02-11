//
//  PlaylistModel.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 10/28/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

public class PlaylistModel: BaseModel {
 
    private(set) public var descriptionString = ""
    private(set) public var keywords = Array<String>()
    private(set) public var active = false
    private(set) public var priority = 0
    private(set) public var createdAt: NSDate?
    private(set) public var updatedAt: NSDate?
    private(set) public var playlistItemCount = 0
    private(set) public var siteID = ""
    private(set) public var relatedVideoIDs = Array<String>()
    
    public init(fromJson: Dictionary<String, AnyObject>)
    {
        super.init(json: fromJson)
        do
        {
            self.descriptionString = try SSUtils.stringFromDictionary(fromJson, key: kJSONDescription)
            self.keywords = fromJson[kJSON_Keywords] as! Array<String>
            self.active = try SSUtils.boolFromDictionary(fromJson, key: kJSONActive)
            self.priority = try SSUtils.intagerFromDictionary(fromJson, key: kJSONPriority)
            self.createdAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONCreatedAt))
            self.updatedAt = SSUtils.stringToDate(try SSUtils.stringFromDictionary(fromJson, key: kJSONUpdatedAt))
            self.playlistItemCount = try SSUtils.intagerFromDictionary(fromJson, key: kJSONPlaylistItemCount)
            self.siteID = try SSUtils.stringFromDictionary(fromJson, key: kJSONSiteId)
            self.relatedVideoIDs = fromJson[kJSONRelatedVideoIds] as! Array <String>
        }
        catch _
        {
            ZypeLog.error("Exception: PlaylistModel")
        }
    }
    
    public func getVideos(loadedSince: NSDate = NSDate(), completion:(videos: Array<VideoModel>?, error: NSError?) -> Void)
    {
        let videos = self.userData["videos"]
        if (videos != nil)
        {
            if(loadedSince.compare(self.userData["date"] as! NSDate) == NSComparisonResult.OrderedAscending)
            {
                completion(videos: videos as? Array<VideoModel>, error: nil)
                return
            }
        }
        ZypeSDK.sharedInstance.retrieveVideosInPlaylist(QueryRetrieveVideosInPlaylistModel(playlist: self), completion:{(videos, error) -> Void in
            self.userData["videos"] = videos
            self.userData["date"] = NSDate()
            completion(videos: videos, error: error)
        })
    }

}

