import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "folder.fill",
            title: "Manage Projects",
            description: "Organize your work with projects. Track progress, set deadlines, and keep everything in one place.",
            gradient: [AppColors.primary, AppColors.primary.opacity(0.6)]
        ),
        OnboardingPage(
            icon: "checklist",
            title: "Track Tasks",
            description: "Break down projects into tasks. Set priorities, deadlines, and monitor completion status.",
            gradient: [AppColors.gold, AppColors.gold.opacity(0.6)]
        ),
        OnboardingPage(
            icon: "calendar",
            title: "Timeline View",
            description: "Visualize your schedule with calendar and timeline. Never miss important deadlines.",
            gradient: [AppColors.lightBlue, AppColors.lightBlue.opacity(0.6)]
        ),
        OnboardingPage(
            icon: "paperclip",
            title: "Resources & Files",
            description: "Attach files, links, and notes to your projects. Keep all resources organized and accessible.",
            gradient: [AppColors.orange, AppColors.orange.opacity(0.6)]
        )
    ]
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            // Decorative background elements
            VStack {
                HStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .blur(radius: 80)
                        .offset(x: -100, y: -150)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(AppColors.gold.opacity(0.1))
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .offset(x: 80, y: 150)
                }
            }
            
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    // Skip button
                    HStack {
                        Spacer()
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                        }
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, AppSpacing.lg)
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxHeight: .infinity)
                    
                    // Page indicator and buttons
                    VStack(spacing: AppSpacing.lg) {
                        // Custom page indicator
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Capsule()
                                    .fill(index == currentPage ? AppColors.primary : AppColors.textSecondary.opacity(0.3))
                                    .frame(width: index == currentPage ? 32 : 8, height: 8)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                            }
                        }
                        .padding(.bottom, AppSpacing.md)
                        
                        // Navigation buttons
                        HStack(spacing: AppSpacing.md) {
                            if currentPage > 0 {
                                Button(action: {
                                    withAnimation {
                                        currentPage -= 1
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Previous")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, AppSpacing.lg)
                                    .padding(.vertical, AppSpacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                            .fill(AppColors.backgroundSecondary)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                                    .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if currentPage < pages.count - 1 {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                } else {
                                    completeOnboarding()
                                }
                            }) {
                                HStack {
                                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                                    if currentPage < pages.count - 1 {
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.background)
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.vertical, AppSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                        .fill(
                                            LinearGradient(
                                                colors: pages[currentPage].gradient,
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: pages[currentPage].gradient[0].opacity(0.4), radius: 10, x: 0, y: 5)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, AppSpacing.xl)
                }
                .frame(maxWidth: 600)
                Spacer()
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenOnboarding)
        HapticsService.shared.success()
        onComplete()
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let gradient: [Color]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    
    private var iconSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 180 : 160
    }
    
    private var iconFontSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 70 : 80
    }
    
    private var titleFontSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 32 : 36
    }
    
    private var descriptionFontSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 16 : 18
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.gradient.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    page.gradient[0].opacity(0.3),
                                    page.gradient[0].opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: iconSize, height: iconSize)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: iconFontSize, weight: .light))
                        .foregroundColor(page.gradient[0])
                }
            }
            .padding(.bottom, AppSpacing.xl)
            
            // Title
            Text(page.title)
                .font(.system(size: titleFontSize, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, AppTheme.screenPadding)
            
            // Description
            Text(page.description)
                .font(.system(size: descriptionFontSize, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, AppTheme.screenPadding)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}

