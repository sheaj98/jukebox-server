//
//  SpotifyToken.swift
//  App
//
//  Created by Shea Sullivan on 2018-09-24.
//

import Foundation
import Vapor

final class SpotifyToken: Content, Codable {
    var token: String
    
    init(token: String) {
        self.token = token
    }
}
