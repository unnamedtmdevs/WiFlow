import SwiftUI

extension View {
    func buttonScaleEffect() -> some View {
        self.modifier(ButtonScaleModifier())
    }
}

struct ButtonScaleModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(
                SettingsService.shared.animationsEnabled ?
                .spring(response: 0.2, dampingFraction: 0.6) : .none,
                value: isPressed
            )
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

