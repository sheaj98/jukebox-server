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
        .flatMap(to: HTTPStatus.self, { song in
            song.hasPlayed = true
            return song.save(on: req).flatMap(to: HTTPStatus.self) { newSong in
                return Song.query(on: req).filter(\.sessionId == session.id).filter(\.hasPlayed == false).all().map(to: HTTPStatus.self, { songs in
                    sessionManager.addSong(songs, for: session)
                    return HTTPStatus.accepted
                })
            }
        })
    }
    
    router.get("party", PartySession.parameter, "songs") {
        req -> Future<[Song]> in
        let session = try req.parameters.next(PartySession.self)
        return Song.query(on: req).filter(\.sessionId == session.id).filter(\.hasPlayed == false).all()
    }
    
    router.get("party", PartySession.parameter, "search") {
        request -> Future<[Song]> in
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
