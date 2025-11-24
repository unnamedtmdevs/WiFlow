import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showCreateProject = false
    @State private var selectedProject: Project?
    @State private var showDeadlinesView = false
    @State private var deadlineType: DeadlineType = .overdue

    var body: some View {
        ZStack {
            // Background with gradient
            AppColors.background
                .ignoresSafeArea()
            
            // Decorative elements
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .offset(x: 50, y: -100)
                }
                Spacer()
            }
            
            ScrollView {
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        headerSection
                        
                        statsSection
                        
                        if !viewModel.overdueTasks.isEmpty || !viewModel.upcomingTasks.isEmpty {
                            alertsSection
                        }
                        
                        recentProjectsSection
                        
                        quickActionsSection
                        
                        Spacer(minLength: AppSpacing.xl)
                    }
                    .frame(maxWidth: 600)
                    .padding(.bottom, AppSpacing.xl)
                    Spacer()
                }
            }
        }
        .dismissKeyboardOnTap()
        .onAppear {
            viewModel.loadData()
        }
        .sheet(isPresented: $showCreateProject) {
            CreateProjectView(onSave: {
                viewModel.loadData()
            })
        }
        .sheet(item: $selectedProject) { project in
            ProjectDetailView(project: project, onUpdate: {
                viewModel.loadData()
            })
        }
        .sheet(isPresented: $showDeadlinesView) {
            DeadlinesView(deadlineType: deadlineType)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Welcome back")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Dashboard")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                // Decorative circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppColors.primary.opacity(0.3),
                                    AppColors.primary.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, AppSpacing.lg)
        }
    }

    private var statsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.md) {
                StatCard(
                    title: "Active Projects",
                    value: "\(viewModel.stats.activeProjects)",
                    icon: "folder.fill",
                    color: AppColors.primary,
                    gradient: [AppColors.primary, AppColors.primary.opacity(0.6)]
                )
                
                StatCard(
                    title: "Total Tasks",
                    value: "\(viewModel.stats.totalTasks)",
                    icon: "checklist",
                    color: AppColors.gold,
                    gradient: [AppColors.gold, AppColors.gold.opacity(0.6)]
                )
                
                StatCard(
                    title: "Completed",
                    value: "\(viewModel.stats.completedTasks)",
                    icon: "checkmark.circle.fill",
                    color: AppColors.darkGreen,
                    gradient: [AppColors.darkGreen, AppColors.darkGreen.opacity(0.6)]
                )
                
                StatCard(
                    title: "Overdue",
                    value: "\(viewModel.stats.overdueTasks)",
                    icon: "exclamationmark.triangle.fill",
                    color: AppColors.orange,
                    gradient: [AppColors.orange, AppColors.orange.opacity(0.6)]
                )
            }
            .padding(.horizontal, AppTheme.screenPadding)
        }
    }

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Alerts")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // Decorative dot
                Circle()
                    .fill(AppColors.orange)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, AppTheme.screenPadding)

            if !viewModel.overdueTasks.isEmpty {
                AlertBanner(
                    message: "\(viewModel.overdueTasks.count) tasks overdue",
                    color: AppColors.orange,
                    onTap: {
                        deadlineType = .overdue
                        showDeadlinesView = true
                    }
                )
                .padding(.horizontal, AppTheme.screenPadding)
            }

            if !viewModel.upcomingTasks.isEmpty {
                AlertBanner(
                    message: "\(viewModel.upcomingTasks.count) deadlines this week",
                    color: AppColors.gold,
                    onTap: {
                        deadlineType = .upcoming
                        showDeadlinesView = true
                    }
                )
                .padding(.horizontal, AppTheme.screenPadding)
            }
        }
    }

    private var recentProjectsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // Decorative line
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 40, height: 3)
            }
            .padding(.horizontal, AppTheme.screenPadding)

            if viewModel.recentProjects.isEmpty {
                EmptyStateView(
                    icon: "folder.badge.plus",
                    message: "No projects yet. Create your first project!"
                )
                .padding(.horizontal, AppTheme.screenPadding)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.recentProjects) { project in
                            ProjectCard(
                                project: project,
                                progress: viewModel.getProjectProgress(project),
                                taskCount: viewModel.getTaskCount(for: project),
                                completedTaskCount: viewModel.getCompletedTaskCount(for: project),
                                onTap: {
                                    HapticsService.shared.impact(.light)
                                    selectedProject = project
                                }
                            )
                            .frame(width: min(600, UIScreen.main.bounds.width) - AppTheme.screenPadding * 2)
                        }
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                }
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(spacing: AppSpacing.md) {
            Button(action: {
                HapticsService.shared.impact()
                showCreateProject = true
            }) {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.primary.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.background)
                    }
                    
                    Text("Create New Project")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(AppTheme.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(AppColors.backgroundSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            AppColors.primary.opacity(0.3),
                                            AppColors.primary.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
            }
            .padding(.horizontal, AppTheme.screenPadding)
        }
    }
}

struct AlertBanner: View {
    let message: String
    let color: Color
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            onTap?()
        }) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(color)
                }

                Text(message)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color.opacity(0.7))
            }
            .padding(AppTheme.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.15),
                                color.opacity(0.08)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.primary.opacity(0.15),
                                AppColors.primary.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(AppColors.primary.opacity(0.7))
            }

            Text(message)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 14 : 16, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, AppSpacing.xl)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xxl)
    }
}
