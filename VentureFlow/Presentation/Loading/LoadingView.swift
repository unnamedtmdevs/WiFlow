import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var showMainView = false
    @State private var showOnboarding = false
    
    private var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSeenOnboarding)
    }

    var body: some View {
        if showMainView {
            MainContainerView()
        } else if showOnboarding {
            OnboardingView(onComplete: {
                withAnimation {
                    showMainView = true
                }
            })
        } else {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                // Decorative gradient circles
                VStack {
                    HStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.1))
                            .frame(width: 200, height: 200)
                            .blur(radius: 60)
                            .offset(x: -80, y: -100)
                        Spacer()
                    }
                    Spacer()
                }

                VStack(spacing: AppSpacing.xl) {
                    Image(systemName: "folder.fill.badge.gearshape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(AppColors.primary)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
                        .shadow(color: AppColors.primary.opacity(0.4), radius: 20, x: 0, y: 10)

                    Text("VentureFlow")
                        .font(AppTypography.display)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Manage Your Projects")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .onAppear {
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if hasSeenOnboarding {
                        withAnimation {
                            showMainView = true
                        }
                    } else {
                        withAnimation {
                            showOnboarding = true
                        }
                    }
                }
            }
        }
    }
}
