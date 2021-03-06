import Vapor
import Fluent
import Foundation

let sessionManager = PartyManager()

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    
    router.post("party/create", use: sessionManager.createPartySession)
    
    router.post("party/close", PartySession.parameter) {
        req -> Future<HTTPStatus> in
        let logger = try? req.sharedContainer.make(Logger.self)
        logger?.log(req.description, at: .info, file: #file, function: #function, line: #line, column: #column)
        let session = try req.parameters.next(PartySession.self)
        sessionManager.close(session)
        Party.query(on: req).filter(\.sessionId == session.id).first().unwrap(or: Abort.init(HTTPResponseStatus.notFound)).delete(on: req)
        return Song.query(on: req).filter(\.sessionId == session.id).all().then({ songs in
            return songs.map({ song in
                return song.delete(on: req)
            }).flatten(on: req)
        }).transform(to: HTTPStatus.noContent)
    }
    
    router.post("party/update", PartySession.parameter) {
    req -> Future<HTTPStatus> in
    let logger = try? req.sharedContainer.make(Logger.self)
    logger?.log(req.description, at: .info, file: #file, function: #function, line: #line, column: #column)
    let session = try req.parameters.next(PartySession.self)
    return try Song.decode(from: req)
        .map(to: HTTPStatus.self) { song in
            Song.query(on: req).filter(\.sessionId == session.id).filter(\.nextSongId == nil).first().do({ lastSong in
                guard let lastSong = lastSong else { return }
                lastSong.nextSongId = song.songId;
                lastSong.save(on: req).catch({ error in
                    logger?.log(error.localizedDescription, at: .error, file: #file, function: #function, line: #line, column: #column)
                })
            }).catch({ error in
                logger?.log(error.localizedDescription, at: .error, file: #file, function: #function, line: #line, column: #column)
            })
            song.save(on: req).do({ _ in
                Song.query(on: req).filter(\.sessionId == session.id).filter(\.hasPlayed == false).all().do({ songs in
                    logger?.log("Sending Socket event with songs \(songs)", at: .info, file: #file, function: #function, line: #line, column: #column)
                    sessionManager.addSong(songs, for: session, on: req)
                }).catch({ error in
                    logger?.log(error.localizedDescription, at: .error, file: #file, function: #function, line: #line, column: #column)
                })
            }).catch({ error in
                logger?.log(error.localizedDescription, at: .error, file: #file, function: #function, line: #line, column: #column)
            })
            
            return .ok
        }
    }
    
    router.post("party", PartySession.parameter, "played") {
        req -> Future<HTTPStatus> in
        let session = try req.parameters.next(PartySession.self)
        return try Song.decode(from: req)
        .flatMap(to: HTTPStatus.self, { song in
            song.hasPlayed = true
            return song.save(on: req).flatMap(to: HTTPStatus.self) { newSong in
                return Song.query(on: req).filter(\.sessionId == session.id).filter(\.hasPlayed == false).all().map(to: HTTPStatus.self, { songs in
                    sessionManager.addSong(songs, for: session, on: req)
                    return HTTPStatus.accepted
                })
            }
        })
    }
    
    router.get("party", PartySession.parameter, "songs") {
        req -> Future<[Song]> in
        let logger = try? req.sharedContainer.make(Logger.self)
        logger?.log(req.description, at: .info, file: #file, function: #function, line: #line, column: #column)
        let session = try req.parameters.next(PartySession.self)
        return Song.query(on: req).filter(\.sessionId == session.id).filter(\.hasPlayed == false).all()
    }
    
    router.get("party", PartySession.parameter, "search") {
        request -> Future<[Song]> in
        let logger = try? request.sharedContainer.make(Logger.self)
        logger?.log(request.description, at: .info, file: #file, function: #function, line: #line, column: #column)
        let session = try request.parameters.next(PartySession.self)
        return Party.query(on: request).filter(\.sessionId == session.id).first().unwrap(or: Abort.init(HTTPResponseStatus.notFound)).flatMap({ party in
            
            let client = try request.make(Client.self)
            guard let query = request.query[String.self, at: "q"] else {
                throw Abort(.badRequest)
            }
            return client.get("https://api.spotify.com/v1/search?q=\(query)&limit=15&type=track", headers: HTTPHeaders([("Authorization", "Bearer \(party.spotifyToken)")])).flatMap(to: [Song].self, { response in
                return try response.content.decode(SpotifyTrack.self).map({ tracks in
                    return tracks.tracks.items.map({ track in
                        return Song(songId: track.uri, artist: track.artists.first!.name, duration: track.durationMS, name: track.name, imageUrl: track.album.images.first!.url, sessionId: session.id)
                    })
                })
            })
        })
    }

}
