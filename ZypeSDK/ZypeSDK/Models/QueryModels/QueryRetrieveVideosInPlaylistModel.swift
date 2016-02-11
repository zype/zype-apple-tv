//
//  QueryRetrieveVideosInPlaylistModel.swift
//  ZypeSDK
//
//  Created by Ilya Sorokin on 10/28/15.
//  Copyright © 2015 Ilya Sorokin. All rights reserved.
//

import UIKit

public class QueryRetrieveVideosInPlaylistModel: QueryBaseModel {
    
    public var playlistID = ""
    
    public init(playlist: PlaylistModel? = nil)
    {
        if playlist != nil
        {
            self.playlistID = playlist!.ID
        }
    }
    
}
