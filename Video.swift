//
//  Video.swift
//  iOSVideoPlayerStoryboard
//
//  Created by Indu Pandey on 16/01/24.
//

import Foundation

struct Video: Codable {
    let id: String
    let title: String
    let fullURL: String
    let hlsURL: String
    let description: String
    let publishedAt: String
    let author: Author
}

struct Author: Codable {
    let id: String
    let name: String
}
