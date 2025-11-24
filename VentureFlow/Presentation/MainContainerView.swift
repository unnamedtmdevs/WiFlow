import SwiftUI

struct MainContainerView: View {
    @State private var selectedTab: TabItem = .home

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                            .transition(.asymmetric(
                                insertion: SettingsService.shared.animationsEnabled ? .move(edge: .leading).combined(with: .opacity) : .identity,
                                removal: SettingsService.shared.animationsEnabled ? .move(edge: .trailing).combined(with: .opacity) : .identity
                            ))
                    case .projects:
                        ProjectsTasksView()
                            .transition(.asymmetric(
                                insertion: SettingsService.shared.animationsEnabled ? .move(edge: .leading).combined(with: .opacity) : .identity,
                                removal: SettingsService.shared.animationsEnabled ? .move(edge: .trailing).combined(with: .opacity) : .identity
                            ))
                    case .timeline:
                        TimelineView()
                            .transition(.asymmetric(
                                insertion: SettingsService.shared.animationsEnabled ? .move(edge: .leading).combined(with: .opacity) : .identity,
                                removal: SettingsService.shared.animationsEnabled ? .move(edge: .trailing).combined(with: .opacity) : .identity
                            ))
                    case .resources:
                        ResourcesView()
                            .transition(.asymmetric(
                                insertion: SettingsService.shared.animationsEnabled ? .move(edge: .leading).combined(with: .opacity) : .identity,
                                removal: SettingsService.shared.animationsEnabled ? .move(edge: .trailing).combined(with: .opacity) : .identity
                            ))
                    case .settings:
                        SettingsView()
                            .transition(.asymmetric(
                                insertion: SettingsService.shared.animationsEnabled ? .move(edge: .leading).combined(with: .opacity) : .identity,
                                removal: SettingsService.shared.animationsEnabled ? .move(edge: .trailing).combined(with: .opacity) : .identity
                            ))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(
                    SettingsService.shared.animationsEnabled ?
                    .spring(response: 0.4, dampingFraction: 0.8) : .none,
                    value: selectedTab
                )

                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}
