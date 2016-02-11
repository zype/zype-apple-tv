//
//  VimeoUrl.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 10/30/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

class VimeoUrl: BaseUrl, VideoUrl {

    private let kPlayerGetVideo = "%@/embed/%@.json?app_key=%@"

     func getVideoObject(video: VideoModel, completion:(playerObject: VideoObjectModel, error: NSError?) -> Void)
     {
        let urlAsString = String(format: kPlayerGetVideo, self.controller!.keys.playerDomain, video.ID, self.controller!.keys.appKey)
        self.controller!.getQuery(urlAsString, withCompletion: { (jsonDic, error) -> Void in
            let player = VideoObjectModel()
            player.json = jsonDic
                let response = jsonDic?[kJSONResponse]
                if response != nil
                {
                    let outputs = response?[kJSONBody]?![kJSONOutputs] as? Array <Dictionary<String, String> >
                    if outputs?.first != nil
                    {
                        player.videoURL = outputs!.first![kJSONUrl]!
                    }
                }
                completion(playerObject: player, error: error)
        })
     }
}
