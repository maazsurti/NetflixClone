//
//  YoutubeSearchResponse.swift
//  Netflix
//
//  Created by Maaz on 27/04/22.
//

import Foundation

/*
 
     items =     (
                 {
             etag = "-2fZOAcaga1VRykqVVpzrvQ2jMQ";
             id =             {
                 kind = "youtube#video";
                videoId = jaJuwKCmJbY;
             };
             kind = "youtube#searchResult";
         },
 */

struct YoutubeSearchResponse: Codable {
    
    let items:[VideoElement]
}

struct VideoElement: Codable {
    let id: IdVideoElement
}

struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
