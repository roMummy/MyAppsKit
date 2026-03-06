import Foundation
import Combine

@MainActor
public final class DeveloperAppsViewModel: ObservableObject {
    @Published public private(set) var state: DeveloperAppsState = .idle

    private let service: DeveloperAppsService

    public init(service: DeveloperAppsService) {
        self.service = service
    }

    public convenience init(configuration: MyAppsConfiguration) {
        self.init(service: DeveloperAppsService(configuration: configuration))
    }

    public func loadIfNeeded() async {
        guard case .idle = state else {
            return
        }
        await load(resetState: false)
    }

    public func retry() async {
        await load(resetState: true)
    }

    public func reload() async {
        await load(resetState: true)
    }

    private func load(resetState: Bool) async {
        if resetState {
            state = .idle
        }

        state = .loading
        do {
            let apps = try await service.fetchApps()
            state = .loaded(apps)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
