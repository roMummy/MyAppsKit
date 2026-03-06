import MyAppsCore
import SwiftUI

public struct MyAppsSectionView: View {
    private let state: DeveloperAppsState
    private let style: MyAppsSectionStyle
    private let onRetry: () -> Void
    private let onTapApp: (DeveloperApp) -> Void
    private let onSectionAppear: () -> Void

    public init(
        state: DeveloperAppsState,
        style: MyAppsSectionStyle = MyAppsSectionStyle(),
        onRetry: @escaping () -> Void,
        onTapApp: @escaping (DeveloperApp) -> Void,
        onSectionAppear: @escaping () -> Void = {}
    ) {
        self.state = state
        self.style = style
        self.onRetry = onRetry
        self.onTapApp = onTapApp
        self.onSectionAppear = onSectionAppear
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            contentView
        }
    }

    private var header: some View {
        Text("my_apps_title", bundle: .module)
            .font(style.headerFont)
            .foregroundStyle(style.titleColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
    }

    @ViewBuilder
    private var contentView: some View {
        switch state {
        case .idle, .loading:
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .frame(maxWidth: .infinity)
        case .failed(let message):
            VStack(alignment: .leading, spacing: 8) {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(style.cardSubtitleColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    onRetry()
                } label: {
                    Text("my_apps_retry", bundle: .module)
                }
                .buttonStyle(.borderedProminent)
                .tint(style.retryButtonTint)
            }
            .padding(.horizontal)
        case .loaded(let apps):
            if apps.isEmpty {
                EmptyView()
            } else {
                appsView(apps)
            }
        }
    }

    private func appsView(_ apps: [DeveloperApp]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(apps) { app in
                    HStack(alignment: .top, spacing: 10) {
                        AsyncImage(url: URL(string: app.artworkUrl100 ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            style.placeholderColor
                        }
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(app.trackName)
                                .font(style.cardTitleFont)
                                .foregroundStyle(style.cardTitleColor)
                                .lineLimit(1)

                            Text(summaryText(for: app.description))
                                .font(style.cardSubtitleFont)
                                .foregroundStyle(style.cardSubtitleColor)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(width: 220, alignment: .leading)
                    .padding(10)
                    .background(style.cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTapApp(app)
                    }
                }
            }
        }
        .onAppear {
            onSectionAppear()
        }
    }

    private func summaryText(for text: String?) -> String {
        guard let text,
              text.isEmpty == false else {
            return String(localized: "my_apps_no_description", bundle: .module)
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return String(localized: "my_apps_no_description", bundle: .module)
        }

        if let line = trimmed.split(separator: "\n").first {
            return String(line)
        }

        return trimmed
    }
}
