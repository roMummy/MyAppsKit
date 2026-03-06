# MyAppsKit

A reusable Swift Package for showing an app's "My Apps" section.

## Modules

- `MyAppsCore`: data models, iTunes API service, and view model.
- `MyAppsUI`: ready-to-use SwiftUI section view.

## Supported Localizations

- `en`, `zh-Hans`, `zh-Hant`, `ja`, `ko`, `de`, `fr`, `es`, `it`, `pt-BR`, `pt-PT`, `ru`, `tr`, `pl`, `ar`

## Install

In Xcode:

1. `File` -> `Add Packages...`
2.  input `https://github.com/roMummy/MyAppsKit.git`
4. Add product to your target:
   - `MyAppsUI` for ready-to-use SwiftUI section UI.
   - `MyAppsCore` for non-UI/business-layer usage only.

## Usage (UI)

```swift
import MyAppsCore
import MyAppsUI
import SwiftUI

struct SettingsView: View {
    @StateObject private var myAppsViewModel = DeveloperAppsViewModel(
        configuration: .init(
            currentAppID: "0000",
            developerSeedAppID: "000",
            countryCode: "us"
        )
    )

    var body: some View {
        MyAppsSectionView(
            state: myAppsViewModel.state,
            onRetry: {
                Task { await myAppsViewModel.retry() }
            },
            onTapApp: { app in
                guard let url = app.trackViewURL else { return }
                UIApplication.shared.open(url)
            },
            onSectionAppear: {
                // optional analytics
            }
        )
        .task {
            await myAppsViewModel.loadIfNeeded()
        }
    }
}
```

## Usage (Core + Custom UI, No `MyAppsUI`)

Use only `MyAppsCore` and build your own UI.  
Example below renders a simple list item with icon + title + description.

```swift
import MyAppsCore
import SwiftUI

struct SimpleMyAppsListView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel = DeveloperAppsViewModel(
        configuration: .init(
            currentAppID: "0000",
            developerSeedAppID: "000",
            countryCode: "us"
        )
    )

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .failed(let message):
                VStack(spacing: 12) {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        Task { await viewModel.retry() }
                    }
                }
            case .loaded(let apps):
                List(apps) { app in
                    HStack(alignment: .top, spacing: 12) {
                        AsyncImage(url: URL(string: app.artworkUrl100 ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color(.systemGray5)
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(app.trackName)
                                .font(.headline)
                                .lineLimit(1)
                            Text(summaryText(for: app.description))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard let url = app.trackViewURL else { return }
                        openURL(url)
                    }
                }
                .listStyle(.plain)
            }
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }

    private func summaryText(for text: String?) -> String {
        guard let text else { return "No description" }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return "No description" }
        return String(trimmed.split(separator: "\n").first ?? Substring(trimmed))
    }
}
```

If you only need raw data (no `ViewModel`), you can call `DeveloperAppsService` directly:

```swift
import MyAppsCore

let service = DeveloperAppsService(
    configuration: .init(
        currentAppID: "0000",
        developerSeedAppID: "000",
        countryCode: "us"
    )
)

let apps = try await service.fetchApps()
```
