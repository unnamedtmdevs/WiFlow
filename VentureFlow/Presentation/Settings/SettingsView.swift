import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var deadlineRemindersEnabled = true
    @State private var animationsEnabled = true
    @State private var hapticFeedbackEnabled = true
    @State private var stats: ProjectStats = ProjectStats()
    @State private var showCategories = false
    @State private var showHistory = false
    @State private var showDebugMenu = false
    @State private var debugTapCount = 0
    @State private var showClearDataAlert = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            // Decorative element
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(AppColors.primary.opacity(0.08))
                        .frame(width: 160, height: 160)
                        .blur(radius: 50)
                        .offset(x: 60, y: -100)
                }
                Spacer()
            }

            ScrollView {
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        headerSection

                        appSettingsSection
                        
                        notificationSettingsSection
                        
                        categoriesSection
                        
                        historySection

                        statisticsSection

                        dataManagementSection

                        aboutSection

                        Spacer(minLength: AppSpacing.xl)
                    }
                    .frame(maxWidth: 600)
                    .padding(.bottom, AppSpacing.xl)
                    Spacer()
                }
            }
        }
        .onAppear {
            loadSettings()
            loadStats()
        }
        .sheet(isPresented: $showCategories) {
            CategoriesView()
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
            .sheet(isPresented: $showDebugMenu) {
                DebugMenuView()
            }
            .alert("Clear All Data", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all projects, tasks, resources, milestones, and history. This action cannot be undone.")
            }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("History")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.screenPadding)
            
            Button(action: {
                HapticsService.shared.impact()
                showHistory = true
            }) {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(AppColors.gold.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.gold)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("View History")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        Text("See all completed tasks and projects")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(AppColors.backgroundSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            AppColors.gold.opacity(0.2),
                                            AppColors.gold.opacity(0.05)
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
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Settings")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, AppTheme.screenPadding)
        .padding(.top, AppSpacing.lg)
    }

    private var notificationSettingsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Notifications")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, AppTheme.screenPadding)

            VStack(spacing: AppSpacing.sm) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                    
                    Text("Deadline Reminders")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $deadlineRemindersEnabled)
                        .onChange(of: deadlineRemindersEnabled) { newValue in
                            saveSettings()
                            // Sync reminders when setting changes
                            if newValue {
                                NotificationService.shared.requestAuthorization { granted in
                                    if granted {
                                        NotificationService.shared.syncAllReminders()
                                    }
                                }
                            } else {
                                // Cancel all reminders when disabled
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            }
                        }
                }
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
            .padding(.horizontal, AppTheme.screenPadding)
        }
    }

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Statistics")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
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

            VStack(spacing: AppSpacing.md) {
                StatRow(label: "Total Projects", value: "\(stats.totalProjects)", icon: "folder.fill", color: AppColors.primary)
                StatRow(label: "Active Projects", value: "\(stats.activeProjects)", icon: "folder.badge.gearshape", color: AppColors.darkGreen)
                StatRow(label: "Completed Projects", value: "\(stats.completedProjects)", icon: "checkmark.circle.fill", color: AppColors.darkGreen)
                StatRow(label: "Total Tasks", value: "\(stats.totalTasks)", icon: "checklist", color: AppColors.gold)
                StatRow(label: "Completed Tasks", value: "\(stats.completedTasks)", icon: "checkmark.square.fill", color: AppColors.darkGreen)
                StatRow(label: "Overdue Tasks", value: "\(stats.overdueTasks)", icon: "exclamationmark.triangle.fill", color: AppColors.orange)
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
            .padding(.horizontal, AppTheme.screenPadding)
        }
    }

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Data Management")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.screenPadding)

            VStack(spacing: AppSpacing.sm) {
                Button(action: {
                    HapticsService.shared.impact()
                    exportData()
                }) {
                    HStack(spacing: AppSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        Text("Export Data")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(AppSpacing.md)
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

                Button(action: {
                    HapticsService.shared.warning()
                    showClearDataAlert = true
                }) {
                    HStack(spacing: AppSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(AppColors.orange.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColors.orange)
                        }
                        
                        Text("Clear All Data")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.orange)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.orange.opacity(0.7))
                    }
                    .padding(AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(AppColors.backgroundSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                AppColors.orange.opacity(0.3),
                                                AppColors.orange.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                    )
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("About")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.screenPadding)

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Text("App Version")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Text("1.0.0")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }

                Divider()
                    .background(AppColors.backgroundSecondary)

                Text("WiFlow helps you manage personal projects, track tasks, and meet deadlines efficiently.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
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
            .padding(.horizontal, AppTheme.screenPadding)
            .onTapGesture {
                debugTapCount += 1
                HapticsService.shared.impact(.light)
                
                if debugTapCount >= 5 {
                    HapticsService.shared.success()
                    showDebugMenu = true
                    debugTapCount = 0
                } else {
                    // Reset counter after 2 seconds if 5 taps not reached
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if debugTapCount < 5 {
                            debugTapCount = 0
                        }
                    }
                }
            }
        }
    }

    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("App Settings")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.screenPadding)
            
            VStack(spacing: AppSpacing.sm) {
                SettingToggleRow(
                    icon: "sparkles",
                    title: "Animations",
                    description: "Enable smooth animations",
                    isOn: $animationsEnabled,
                    iconColor: AppColors.gold
                )
                
                SettingToggleRow(
                    icon: "hand.tap.fill",
                    title: "Haptic Feedback",
                    description: "Enable tactile feedback",
                    isOn: $hapticFeedbackEnabled,
                    iconColor: AppColors.primary
                )
            }
            .padding(.horizontal, AppTheme.screenPadding)
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Categories")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.screenPadding)
            
            Button(action: {
                HapticsService.shared.impact()
                showCategories = true
            }) {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "tag.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Manage Categories")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Create, edit, or delete categories")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(AppSpacing.md)
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
            .padding(.horizontal, AppTheme.screenPadding)
        }
    }
    
    private func loadSettings() {
        deadlineRemindersEnabled = SettingsService.shared.deadlineRemindersEnabled
        animationsEnabled = SettingsService.shared.animationsEnabled
        hapticFeedbackEnabled = SettingsService.shared.hapticFeedbackEnabled
    }

    private func saveSettings() {
        SettingsService.shared.deadlineRemindersEnabled = deadlineRemindersEnabled
        SettingsService.shared.animationsEnabled = animationsEnabled
        SettingsService.shared.hapticFeedbackEnabled = hapticFeedbackEnabled
    }

    private func loadStats() {
        stats = ProjectService.shared.getProjectStats()
    }

    private func exportData() {
        if StorageService.shared.exportToJSON() != nil {
            HapticsService.shared.success()
        }
    }
    
    private func clearAllData() {
        // Cancel all notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Clear all projects (this will also delete associated tasks, milestones, and resources)
        let projects = ProjectService.shared.getAllProjects()
        for project in projects {
            ProjectService.shared.deleteProject(project)
        }
        
        // Clear remaining tasks (in case some weren't associated with projects)
        let tasks = TaskService.shared.getAllTasks()
        for task in tasks {
            TaskService.shared.deleteTask(task)
        }
        
        // Clear all resources
        let resources = ResourceService.shared.getAllResources()
        for resource in resources {
            ResourceService.shared.deleteResource(resource)
        }
        
        // Clear all milestones
        let milestones = MilestoneService.shared.getAllMilestones()
        for milestone in milestones {
            MilestoneService.shared.deleteMilestone(milestone)
        }
        
        // Clear history
        StorageService.shared.saveArray([HistoryItem](), forKey: UserDefaultsKeys.history)
        
        // Reset statistics counters
        StorageService.shared.save(0, forKey: UserDefaultsKeys.totalProjectsCreated)
        StorageService.shared.save(0, forKey: UserDefaultsKeys.totalTasksCompleted)
        
        // Reset categories to default only
        StorageService.shared.saveArray(Category.defaultCategories, forKey: UserDefaultsKeys.categories)
        
        // Post notifications to update UI
        NotificationCenter.default.post(name: .projectsDidChange, object: nil)
        NotificationCenter.default.post(name: .tasksDidChange, object: nil)
        NotificationCenter.default.post(name: .resourcesDidChange, object: nil)
        NotificationCenter.default.post(name: .milestonesDidChange, object: nil)
        NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
        NotificationCenter.default.post(name: .historyDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
        
        // Reload stats
        loadStats()
        
        HapticsService.shared.success()
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(color)
        }
    }
}
