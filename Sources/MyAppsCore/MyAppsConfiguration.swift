import Foundation

public struct MyAppsConfiguration: Equatable, Sendable {
    public let currentAppID: String
    public let developerSeedAppID: String
    public let countryCode: String

    public init(
        currentAppID: String,
        developerSeedAppID: String? = nil,
        countryCode: String = "us"
    ) {
        let trimmedCurrent = currentAppID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.currentAppID = trimmedCurrent

        let seed = developerSeedAppID?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.developerSeedAppID = (seed?.isEmpty == false) ? seed! : trimmedCurrent

        let normalizedCountry = countryCode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        self.countryCode = normalizedCountry.isEmpty ? "us" : normalizedCountry
    }
}
