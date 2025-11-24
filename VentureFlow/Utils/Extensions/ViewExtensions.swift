import SwiftUI

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    @available(iOS 16.0, *)
    func dismissKeyboardOnScroll() -> AnyView {
        AnyView(self.scrollDismissesKeyboard(.interactively))
    }
    
    /// Adaptive container for forms and detail screens
    func adaptiveFormContainer() -> some View {
        HStack {
            Spacer()
            self
                .frame(maxWidth: 600)
            Spacer()
        }
    }
    
    /// Configure NavigationView for iPad
    func withAdaptiveNavigation() -> some View {
        self.navigationViewStyle(.stack)
    }
    
    /// Card style with background and gradient border
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppColors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppColors.primary.opacity(0.2),
                                        AppColors.primary.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
}

extension Text {
    /// Text style for primary button
    func primaryButtonStyle() -> some View {
        self
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(AppColors.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: AppColors.primary.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}
