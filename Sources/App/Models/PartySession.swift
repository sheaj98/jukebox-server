//
//  PartySession.swift
//  App
//
//  Created by Shea Sullivan on 2018-08-29.
//

import Foundation
import Vapor

struct PartySession: Content, Hashable {
    let id: String
}

extension PartySession: Parameter {
    static func resolveParameter(_ parameter: String, on container: Container) throws -> PartySession {
        return .init(id: parameter)
    }
}
