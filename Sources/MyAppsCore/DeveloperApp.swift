import Foundation

public struct DeveloperApp: Decodable, Identifiable, Equatable, Sendable {
    public let trackId: Int
    public let trackName: String
    public let artworkUrl100: String?
    public let trackViewUrl: String?
    public let artistId: Int?
    public let description: String?

    public var id: Int { trackId }

    public var trackViewURL: URL? {
        guard let trackViewUrl,
              trackViewUrl.isEmpty == false else {
            return nil
        }
        return URL(string: trackViewUrl)
    }

    public init(
        trackId: Int,
        trackName: String,
        artworkUrl100: String? = nil,
        trackViewUrl: String? = nil,
        artistId: Int? = nil,
        description: String? = nil
    ) {
        self.trackId = trackId
        self.trackName = trackName
        self.artworkUrl100 = artworkUrl100
        self.trackViewUrl = trackViewUrl
        self.artistId = artistId
        self.description = description
    }
}
