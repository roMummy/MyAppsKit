import SwiftUI

public struct MyAppsSectionStyle {
    public var headerFont: Font
    public var titleColor: Color
    public var cardTitleFont: Font
    public var cardSubtitleFont: Font
    public var cardTitleColor: Color
    public var cardSubtitleColor: Color
    public var cardBackgroundColor: Color
    public var placeholderColor: Color
    public var retryButtonTint: Color

    public init(
        headerFont: Font = .system(size: 16, weight: .bold),
        titleColor: Color = .primary,
        cardTitleFont: Font = .system(size: 13, weight: .medium),
        cardSubtitleFont: Font = .system(size: 11, weight: .regular),
        cardTitleColor: Color = .primary,
        cardSubtitleColor: Color = .secondary,
        cardBackgroundColor: Color = .white,
        placeholderColor: Color = Color(.systemGray5),
        retryButtonTint: Color = .accentColor
    ) {
        self.headerFont = headerFont
        self.titleColor = titleColor
        self.cardTitleFont = cardTitleFont
        self.cardSubtitleFont = cardSubtitleFont
        self.cardTitleColor = cardTitleColor
        self.cardSubtitleColor = cardSubtitleColor
        self.cardBackgroundColor = cardBackgroundColor
        self.placeholderColor = placeholderColor
        self.retryButtonTint = retryButtonTint
    }
}
