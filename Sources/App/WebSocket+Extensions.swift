//
//  WebSocket+Extensions.swift
//  App
//
//  Created by Shea Sullivan on 2018-08-29.
//

import Vapor
import WebSocket
import Foundation

extension WebSocket {
    func send(_ songs: [Song]) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(songs) else { return }
        guard let message = String(data: data, encoding: .utf8) else { return }
        send(message)
    }
}
