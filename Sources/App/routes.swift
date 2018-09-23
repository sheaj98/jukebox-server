import Vapor
import Fluent

let sessionManager = PartyManager()

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    
    router.post("party/create", use: sessionManager.createPartySession)
    
    router.post("party/close", PartySession.parameter) {
        req -> HTTPStatus in
            let session = try req.parameters.next(PartySession.self)
            sessionManager.close(session)
        return .ok
    }
    
    router.post("party/update", PartySession.parameter) {
    req -> Future<HTTPStatus> in
    let session = try req.parameters.next(PartySession.self)
    return try Song.decode(from: req)
        .map(to: HTTPStatus.self) { song in
            Song.query(on: req).filter(\.sessionId == session.id).filter(\.nextSongId == nil).first().do({ lastSong in
                guard let lastSong = lastSong else { return }
                lastSong.nextSongId = song.songId;
                lastSong.save(on: req).catch({ error in
                    print(error)
                })
            }).catch({ error in
                print(error)
            })
            song.save(on: req).do({ _ in
                Song.query(on: req).filter(\.sessionId == session.id).filter(\.hasPlayed == false).all().do({ songs in
                    print(songs)
                    sessionManager.addSong(songs, for: session)
                }).catch({ error in
                    print(error)
                })
            }).catch({ error in
                print(error)
            })
            
            return .ok
        }
    }
    
    router.post("party", PartySession.parameter, "played") {
        req -> Future<HTTPStatus> in
        let session = try req.parameters.next(PartySession.self)
        return try Song.decode(from: req)
        .map(to: HTTPStatus.self, { song in
            song.hasPlayed = true
            song.save(on: req)
            Song.query(on: req).filter(\.sessionId == session.id).filter(\.hasPlayed == false).all().do({ songs in
                sessionManager.addSong(songs, for: session)
            })
            return .ok
        })
    }
    
    router.get("party", PartySession.parameter, "songs") {
        req -> Future<[Song]> in
        let session = try req.parameters.next(PartySession.self)
        return Song.query(on: req).filter(\.sessionId == session.id).filter(\.hasPlayed == false).all()
    }

}
