//
//  18-09-27-AddSpotifyTokenToParty.swift
//  App
//
//  Created by Shea Sullivan on 2018-09-27.
//

import Foundation
import FluentMySQL
import Vapor

struct AddSpotifyTokenToParty: Migration {
    
    typealias Database = MySQLDatabase
    
    static func prepare(
        on connection: MySQLConnection
        ) -> Future<Void> {
        return Database.update(
            Party.self, on: connection
        ) { builder in
            builder.field(for: \.spotifyToken)
        }
    }
    
    static func revert(
        on connection: MySQLConnection
        ) -> Future<Void> {
        return Database.update(
            Party.self, on: connection
        ) { builder in
            builder.deleteField(for: \.spotifyToken)
        }
    }
}
