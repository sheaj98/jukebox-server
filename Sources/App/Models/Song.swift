//
//  Song.swift
//  App
//
//  Created by Shea Sullivan on 2018-08-31.
//

import Foundation
import Vapor
import FluentMySQL

final class Song: Content, Codable {
    var id: Int?
    var songId: String
    var artist: String
    var duration: Int
    var name: String
    var imageUrl: String
    var sessionId: String
    var hasPlayed: Bool = false
    var nextSongId: String?
    
    init(songId: String, artist: String, duration: Int, name: String, imageUrl: String, sessionId: String) {
        self.songId = songId
        self.artist = artist
        self.duration = duration
        self.name = name
        self.imageUrl = imageUrl
        self.sessionId = sessionId
    }

}


extension Song: MySQLModel {}
extension Song: Migration {}
