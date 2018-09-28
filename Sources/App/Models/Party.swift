//
//  Party.swift
//  App
//
//  Created by Shea Sullivan on 2018-09-04.
//

import Foundation
import Vapor
import FluentMySQL

final class Party: Content, Codable {
    var id: Int?
    var sessionId: String
    var spotifyToken: String
    
    init(sessionId: String, spotifyToken: String) {
        self.sessionId = sessionId
        self.spotifyToken = spotifyToken
    }
}

extension Party: MySQLModel {}
extension Party: Migration {}
