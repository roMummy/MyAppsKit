import Foundation

public enum DeveloperAppsState: Equatable, Sendable {
    case idle
    case loading
    case loaded([DeveloperApp])
    case failed(String)
}
