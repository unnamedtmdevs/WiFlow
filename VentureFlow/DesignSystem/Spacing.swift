import SwiftUI

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    static func adaptive(_ base: CGFloat) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return base * 1.25
        }
        return base
    }
}
