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
    
    init(sessionId: String) {
        self.sessionId = sessionId
    }
}

extension Party: MySQLModel {}
extension Party: Migration {}
