import SwiftUI

struct AppTheme {
    static let cornerRadius: CGFloat = 16
    static let shadowRadius: CGFloat = 8
    static let minTouchTarget: CGFloat = 44

    static let cardPadding: CGFloat = AppSpacing.adaptive(AppSpacing.md)
    static let screenPadding: CGFloat = AppSpacing.adaptive(20)

    static let iconSizeSmall: CGFloat = AppSpacing.adaptive(20)
    static let iconSizeMedium: CGFloat = AppSpacing.adaptive(24)
    static let iconSizeLarge: CGFloat = AppSpacing.adaptive(32)
}
