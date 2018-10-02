//
//  websockets.swift
//  App
//
//  Created by Shea Sullivan on 2018-08-31.
//

import Vapor

public func sockets(_ websockets: NIOWebSocketServer) {
    
    // Status
    
    websockets.get("echo-test") { ws, req in
        print("ws connnected")
        ws.onText { ws, text in
            print("ws received: \(text)")
            ws.send("echo - \(text)")
        }
    }
    
    // Listener
    
    websockets.get("party", PartySession.parameter) { ws, req in
        let logger = try? req.sharedContainer.make(Logger.self)
        logger?.log(req.description, at: .info, file: #file, function: #function, line: #line, column: #column)
        let session = try req.parameters.next(PartySession.self)
        guard sessionManager.sessions[session] != nil else {
            logger?.log("WS Closing due to session being nil", at: .info, file: #file, function: #function, line: #line, column: #column)
            ws.close()
            return
        }
        sessionManager.add(listener: ws, to: session)
        logger?.log("Adding listener \(ws) to session \(session).", at: .info, file: #file, function: #function, line: #line, column: #column)

    }
}
