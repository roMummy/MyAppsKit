import Foundation

private struct ITunesLookupResponse: Decodable {
    let results: [LookupSeedItem]
}

private struct LookupSeedItem: Decodable {
    let artistId: Int?
    let artistName: String?
}

private struct ITunesSearchResponse: Decodable {
    let results: [DeveloperApp]
}

public enum DeveloperAppsServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingFailed:
            return "Failed to parse server data"
        }
    }
}

public final class DeveloperAppsService {
    private let configuration: MyAppsConfiguration
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(
        configuration: MyAppsConfiguration,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.configuration = configuration
        self.session = session
        self.decoder = decoder
    }

    public func fetchApps() async throws -> [DeveloperApp] {
        let seed = try await fetchSeedAppInfo()
        guard let artistName = seed.artistName?.trimmingCharacters(in: .whitespacesAndNewlines),
              artistName.isEmpty == false,
              let artistId = seed.artistId else {
            return []
        }

        guard var components = URLComponents(string: "https://itunes.apple.com/search") else {
            throw DeveloperAppsServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "term", value: artistName),
            URLQueryItem(name: "entity", value: "software"),
            URLQueryItem(name: "attribute", value: "softwareDeveloper"),
            URLQueryItem(name: "country", value: configuration.countryCode),
            URLQueryItem(name: "limit", value: "200")
        ]

        guard let url = components.url else {
            throw DeveloperAppsServiceError.invalidURL
        }

        let data = try await fetchData(url: url)
        guard let payload = try? decoder.decode(ITunesSearchResponse.self, from: data) else {
            throw DeveloperAppsServiceError.decodingFailed
        }

        let currentTrackID = Int(configuration.currentAppID)
        let filtered = payload.results.filter { app in
            app.artistId == artistId && app.trackId != currentTrackID
        }

        return filtered.sorted { lhs, rhs in
            lhs.trackName.localizedCaseInsensitiveCompare(rhs.trackName) == .orderedAscending
        }
    }

    private func fetchSeedAppInfo() async throws -> LookupSeedItem {
        guard var components = URLComponents(string: "https://itunes.apple.com/lookup") else {
            throw DeveloperAppsServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "id", value: configuration.developerSeedAppID),
            URLQueryItem(name: "country", value: configuration.countryCode)
        ]

        guard let url = components.url else {
            throw DeveloperAppsServiceError.invalidURL
        }

        let data = try await fetchData(url: url)
        guard let payload = try? decoder.decode(ITunesLookupResponse.self, from: data),
              let seed = payload.results.first else {
            throw DeveloperAppsServiceError.decodingFailed
        }

        return seed
    }

    private func fetchData(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw DeveloperAppsServiceError.invalidResponse
        }
        return data
    }
}
