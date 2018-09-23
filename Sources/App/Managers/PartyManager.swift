//
//  PartyManager.swift
//  App
//
//  Created by Shea Sullivan on 2018-08-29.
//

import Vapor
import WebSocket

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyond a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
final class PartyManager {
    
    // MARK: Member Variables
    
    private(set) var sessions: LockedDictionary<PartySession, [WebSocket]> = [:]
    
    // MARK: Observer Interactions
    
    func add(listener: WebSocket, to session: PartySession) {
        guard var listeners = sessions[session] else { return }
        listeners.append(listener)
        sessions[session] = listeners
        
        listener.onClose.always { [weak self, weak listener] in
            guard let listener = listener else { return }
            self?.remove(listener: listener, from: session)
        }
    }
    
    func remove(listener: WebSocket, from session: PartySession) {
        guard var listeners = sessions[session] else { return }
        listeners = listeners.filter { $0 !== listener }
        sessions[session] = listeners
    }
    
    // MARK: Poster Interactions
    
    func createPartySession(for request: Request) -> Future<PartySession> {
        return fiveDigitNumber(req: request)
            .flatMap(to: PartySession.self) { [unowned self] key -> Future<PartySession> in
                let session = PartySession(id: String(key))
                guard self.sessions[session] == nil else {
                    return self.createPartySession(for: request)
                    
                }
                self.sessions[session] = []
                return Future.map(on: request) { session }
        }
    }
    
    func addSong(_ songs: [Song], for session: PartySession) {
        guard let listeners = sessions[session] else { return }
        print("Song Added")
        listeners.forEach { ws in ws.send(songs) }
    }
    
    func close(_ session: PartySession) {
        guard let listeners = sessions[session] else { return }
        listeners.forEach { ws in
            ws.close()
        }
        sessions[session] = nil
    }
}
