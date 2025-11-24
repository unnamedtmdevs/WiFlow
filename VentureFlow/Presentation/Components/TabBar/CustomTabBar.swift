import SwiftUI

enum TabItem: Int, CaseIterable {
    case home
    case projects
    case timeline
    case resources
    case settings

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .projects: return "folder.fill"
        case .timeline: return "calendar"
        case .resources: return "paperclip"
        case .settings: return "gearshape.fill"
        }
    }

    var title: String {
        switch self {
        case .home: return "Home"
        case .projects: return "Work"
        case .timeline: return "Timeline"
        case .resources: return "Resources"
        case .settings: return "Settings"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @Namespace private var animationNamespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: animationNamespace
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .padding(.bottom, AppSpacing.md)
        .background(
            ZStack {
                // Blur background
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
    }
}

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
                Button(action: {
                    HapticsService.shared.impact(.light)
                    withAnimation(SettingsService.shared.animationsEnabled ? .spring(response: 0.3, dampingFraction: 0.7) : .none) {
                        action()
                    }
                }) {
            VStack(spacing: 6) {
                ZStack {
                    // Selection indicator background
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.primary.opacity(0.2),
                                        AppColors.primary.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                            .matchedGeometryEffect(id: "selectedTab", in: namespace)
                            .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                            .animation(
                                SettingsService.shared.animationsEnabled ?
                                .spring(response: 0.3, dampingFraction: 0.7) : .none,
                                value: isSelected
                            )
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: isSelected ? 22 : 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? AppColors.primary : AppColors.textSecondary)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(
                            SettingsService.shared.animationsEnabled ?
                            .spring(response: 0.3, dampingFraction: 0.7) : .none,
                            value: isSelected
                        )
                }
                .frame(height: 50)

                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.textSecondary)
                    .opacity(isSelected ? 1.0 : 0.7)
                    .animation(
                        SettingsService.shared.animationsEnabled ?
                        .spring(response: 0.3, dampingFraction: 0.7) : .none,
                        value: isSelected
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected && SettingsService.shared.animationsEnabled ? 1.05 : 1.0)
        .animation(
            SettingsService.shared.animationsEnabled ?
            .spring(response: 0.3, dampingFraction: 0.7) : .none,
            value: isSelected
        )
    }
}
