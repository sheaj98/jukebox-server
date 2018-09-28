// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

struct SpotifyTrack: Codable {
    let tracks: Tracks
}

struct Tracks: Codable {
    let href: String
    let items: [Item]
    let limit: Int
    let offset: Int
    let total: Int
}

struct Item: Codable {
    let album: Album
    let artists: [Artist]
    let availableMarkets: [String]
    let discNumber, durationMS: Int
    let explicit: Bool
    let externalIDS: ExternalIDS
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let isLocal: Bool
    let name: String
    let popularity: Int
    let trackNumber: Int
    let type: ItemType
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case album, artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMS = "duration_ms"
        case explicit
        case externalIDS = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isLocal = "is_local"
        case name, popularity
        case trackNumber = "track_number"
        case type, uri
    }
}

struct Album: Codable {
    let albumType: AlbumTypeEnum
    let artists: [Artist]
    let availableMarkets: [String]
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let images: [Image]
    let name: String
    let releaseDate: String
    let totalTracks: Int
    let type: AlbumTypeEnum
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case releaseDate = "release_date"
        case totalTracks = "total_tracks"
        case type, uri
    }
}

enum AlbumTypeEnum: String, Codable {
    case album = "album"
    case single = "single"
    case compilation = "compilation"
}

struct Artist: Codable {
    let externalUrls: ExternalUrls
    let href: String
    let id, name: String
    let type: ArtistType
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }
}

struct ExternalUrls: Codable {
    let spotify: String
}

enum ArtistType: String, Codable {
    case artist = "artist"
}

struct Image: Codable {
    let height: Int
    let url: String
    let width: Int
}

enum ReleaseDatePrecision: String, Codable {
    case day = "day"
}

struct ExternalIDS: Codable {
    let isrc: String
}

enum ItemType: String, Codable {
    case track = "track"
}

// MARK: Encode/decode helpers

//class JSONNull: Codable, Hashable {
//
//    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//        return true
//    }
//
//    public var hashValue: Int {
//        return 0
//    }
//
//    public init() {}
//
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if !container.decodeNil() {
//            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encodeNil()
//    }
//}
