//
//  AnalyticsProtocolDelegate.swift
//  Zype
//
//  Created by Andy Zheng on 1/24/18.
//  Copyright © 2018 Eugene Lizhnyk. All rights reserved.
//

import ZypeAppleTVBase

protocol AnalyticsHelperProtocol: class {
    func getAnalyticsFromResponse(_ playerObject: VideoObjectModel?) -> (beacon: String, customDimensions: [String: String])
    func getSegmentAnalyticsFromResponse(_ playerObject: VideoObjectModel?) -> [String: Any]
}

extension PlayerVC: AnalyticsHelperProtocol {
    func getAnalyticsFromResponse(_ playerObject: VideoObjectModel?) -> (beacon: String, customDimensions: [String: String]) {
        
        var configUrl = ""
        var customDimensions = [String: String]()
        
        if let consumerId = ZypeAppleTVBase.sharedInstance.consumer?.ID {
            if !consumerId.isEmpty {
                customDimensions["consumerId"] = consumerId
            }
        }
        
        if let video = playerObject?.json?["response"]?["video"] as? NSDictionary {
            if let title = video["title"] as? String {
                customDimensions["title"] = title
            }
        }
        
        if let body = playerObject?.json?["response"]?["body"] as? NSDictionary {
            
            if let analytics = body["analytics"] as? NSDictionary {
                
                if let beacon = analytics["beacon"] as? String {
                    configUrl = beacon
                }
                
                if let dimensions = analytics["dimensions"] as? NSDictionary {
                    if let videoId = dimensions["video_id"] as? String {
                        customDimensions["videoId"] = videoId
                    }
                    
                    if let siteId = dimensions["site_id"] as? String {
                        customDimensions["siteId"] = siteId
                    }
                    
                    if let playerId = dimensions["player_id"] as? String {
                        customDimensions["playerId"] = playerId
                    }
                    
                    if let device = dimensions["device"] as? String {
                        customDimensions["deviceType"] = device
                    }
                }
            }
        }
        
        return (beacon: configUrl, customDimensions: customDimensions)
    }

    func getSegmentAnalyticsFromResponse(_ playerObject: VideoObjectModel?) -> [String: Any] {
        var customDimensions = [String: Any]()
        customDimensions[SegmentAnalyticsAttributes.contentCmsCategory.rawValue] = "null"
        customDimensions[SegmentAnalyticsAttributes.adType.rawValue] = "null"
        customDimensions[SegmentAnalyticsAttributes.contentShownOnPlatform.rawValue] = "ott"
        customDimensions[SegmentAnalyticsAttributes.streaming_device.rawValue] = "Apple AppleTV"
        customDimensions[SegmentAnalyticsAttributes.videoAccountId.rawValue] = "416418724"
        customDimensions[SegmentAnalyticsAttributes.videoAccountName.rawValue] = "People"
        customDimensions[SegmentAnalyticsAttributes.videoAdDuration.rawValue] = "null"
        customDimensions[SegmentAnalyticsAttributes.videoAdVolume.rawValue] = "null"
        customDimensions[SegmentAnalyticsAttributes.videoFranchise.rawValue] = "null"
        customDimensions[SegmentAnalyticsAttributes.videoSyndicate.rawValue] = "null"

    
        if let video = playerObject?.json?["response"]?["video"] as? NSDictionary {
            if let title = video["title"] as? String {
                customDimensions[SegmentAnalyticsAttributes.videoName.rawValue] = title
            }
            if let duration = video["duration"] {
                customDimensions[SegmentAnalyticsAttributes.videoContentDuration.rawValue] = duration
            }
            if let keywords = video["keywords"] as? [String], !keywords.isEmpty {
                var output = ""
                keywords.forEach {
                    output += "\($0)|"
                }
                customDimensions[SegmentAnalyticsAttributes.videoTags.rawValue] = output
            }
            if let published = video["published_at"] as? String  {
                customDimensions[SegmentAnalyticsAttributes.videoPublishedAt.rawValue] = published
            }
            if let updated = video["updated_at"] as? String  {
                customDimensions[SegmentAnalyticsAttributes.videoUpdatedAt.rawValue] = updated
            }
            if let created = video["created_at"] as? String  {
                customDimensions[SegmentAnalyticsAttributes.videoCreatedAt.rawValue] = created
            }
            
            if let thumbnails = video["thumbnails"] as? Array<AnyObject>, !thumbnails.isEmpty {
                customDimensions[SegmentAnalyticsAttributes.videoThumbnail.rawValue] = thumbnails[0]["url"] as? String
            }
        }
        
        if let body = playerObject?.json?["response"]?["body"] as? NSDictionary {
            
            if let analytics = body["analytics"] as? NSDictionary {
                
                if let dimensions = analytics["dimensions"] as? NSDictionary {
                    if let videoId = dimensions["video_id"] as? String {
                        customDimensions[SegmentAnalyticsAttributes.videoId.rawValue] = videoId
                    }
                }
            }
        }
        
        // default values
        customDimensions[SegmentAnalyticsAttributes.videoContentPosition.rawValue] = 0
        
        return customDimensions
    }
    
    private func iso8601DateString(_ inputDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: inputDate){
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            let string = dateFormatter.string(from: date)
            return string
        }
        return "null"
    }
}
