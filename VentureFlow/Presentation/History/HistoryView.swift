import SwiftUI

struct HistoryView: View {
    @State private var historyItems: [HistoryItem] = []
    @State private var selectedType: HistoryItemType? = nil
    @State private var searchText = ""
    @State private var selectedDateFilter: DateFilter = .all
    @State private var statistics: (totalCompleted: Int, tasksCompleted: Int, projectsCompleted: Int, thisWeek: Int, thisMonth: Int) = (0, 0, 0, 0, 0)
    
    enum DateFilter: String, CaseIterable {
        case all = "All Time"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case lastMonth = "Last Month"
    }
    
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
                    VStack(spacing: AppSpacing.xl) {
                        headerSection
                        
                        statisticsSection
                        
                        filtersSection
                        
                        if historyItems.isEmpty {
                            EmptyStateView(
                                icon: "clock.arrow.circlepath",
                                message: "No completed items yet. Complete tasks or projects to see them here!"
                            )
                            .padding(.top, AppSpacing.xxl)
                        } else {
                            historyListSection
                        }
                        
                        Spacer(minLength: AppSpacing.xl)
                    }
                    .frame(maxWidth: 600)
                    .padding(AppTheme.screenPadding)
                    Spacer()
                }
            }
        }
        .onAppear {
            loadHistory()
            loadStatistics()
        }
        .onReceive(NotificationCenter.default.publisher(for: .historyDidChange)) { _ in
            loadHistory()
            loadStatistics()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("History")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text("Track your completed tasks and projects")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Statistics")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            
            HStack(spacing: AppSpacing.md) {
                StatCard(
                    title: "Total",
                    value: "\(statistics.totalCompleted)",
                    icon: "checkmark.circle.fill",
                    color: AppColors.primary,
                    style: .vertical
                )
                
                StatCard(
                    title: "Tasks",
                    value: "\(statistics.tasksCompleted)",
                    icon: "checklist",
                    color: AppColors.gold,
                    style: .vertical
                )
                
                StatCard(
                    title: "Projects",
                    value: "\(statistics.projectsCompleted)",
                    icon: "folder.fill",
                    color: AppColors.darkGreen,
                    style: .vertical
                )
            }
            
            HStack(spacing: AppSpacing.md) {
                StatCard(
                    title: "This Week",
                    value: "\(statistics.thisWeek)",
                    icon: "calendar",
                    color: AppColors.lightBlue,
                    style: .vertical
                )
                
                StatCard(
                    title: "This Month",
                    value: "\(statistics.thisMonth)",
                    icon: "calendar.badge.clock",
                    color: AppColors.orange,
                    style: .vertical
                )
            }
        }
    }
    
    private var filtersSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Search bar
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                }
                
                TextField("Search history...", text: $searchText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .onChange(of: searchText) { _ in
                        loadHistory()
                    }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppColors.primary.opacity(0.2),
                                        AppColors.primary.opacity(0.05)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            
            // Type filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    FilterChip(
                        title: "All",
                        isSelected: selectedType == nil,
                        onTap: {
                            HapticsService.shared.impact(.light)
                            selectedType = nil
                            loadHistory()
                        }
                    )
                    
                    ForEach([HistoryItemType.task, HistoryItemType.project], id: \.self) { type in
                        FilterChip(
                            title: type.rawValue,
                            isSelected: selectedType == type,
                            onTap: {
                                HapticsService.shared.impact(.light)
                                selectedType = type
                                loadHistory()
                            }
                        )
                    }
                }
            }
            
            // Date filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(DateFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            isSelected: selectedDateFilter == filter,
                            onTap: {
                                HapticsService.shared.impact(.light)
                                selectedDateFilter = filter
                                loadHistory()
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var historyListSection: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(groupedHistoryItems) { group in
                HistoryGroupView(items: group.items, date: group.date)
            }
        }
    }
    
    private var groupedHistoryItems: [HistoryGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: historyItems) { item in
            calendar.startOfDay(for: item.completedDate)
        }
        
        return grouped.map { date, items in
            HistoryGroup(date: date, items: items.sorted { $0.completedDate > $1.completedDate })
        }
        .sorted { $0.date > $1.date }
    }
    
    private func loadHistory() {
        var items = HistoryService.shared.getHistory(for: selectedType)
        
        // Apply date filter
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedDateFilter {
        case .today:
            let today = calendar.startOfDay(for: now)
            items = items.filter { calendar.isDate($0.completedDate, inSameDayAs: today) }
        case .thisWeek:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
            items = items.filter { $0.completedDate >= weekStart }
        case .thisMonth:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            items = items.filter { $0.completedDate >= monthStart }
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: lastMonth)) ?? lastMonth
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? now
            items = items.filter { $0.completedDate >= monthStart && $0.completedDate < monthEnd }
        case .all:
            break
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            items = items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.projectName?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        historyItems = items
    }
    
    private func loadStatistics() {
        statistics = HistoryService.shared.getStatistics()
    }
}

struct HistoryGroup: Identifiable {
    let id = UUID()
    let date: Date
    let items: [HistoryItem]
}

struct HistoryGroupView: View {
    let items: [HistoryItem]
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(dateFormatter.string(from: date))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(items.count) \(items.count == 1 ? "item" : "items")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(items) { item in
                    HistoryItemCard(item: item)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .cardStyle()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

struct HistoryItemCard: View {
    let item: HistoryItem
    
    var body: some View {
        HStack(spacing: 0) {
            // Left colored accent bar
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            item.type == .task ? AppColors.gold : AppColors.darkGreen,
                            (item.type == .task ? AppColors.gold : AppColors.darkGreen).opacity(0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 6)
            
            HStack(spacing: AppSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            (item.type == .task ? AppColors.gold : AppColors.darkGreen).opacity(0.2)
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: item.type == .task ? "checkmark.circle.fill" : "folder.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(item.type == .task ? AppColors.gold : AppColors.darkGreen)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(item.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                    
                    if let projectName = item.projectName {
                        HStack(spacing: 4) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                            Text(projectName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    HStack(spacing: AppSpacing.sm) {
                        if let priority = item.priority {
                            StatusBadge(text: priority, color: priorityColor(priority))
                        }
                        
                        Text(timeFormatter.string(from: item.completedDate))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        
                        if let completionTime = item.completionTime {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 11))
                                Text(formatCompletionTime(completionTime))
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(AppSpacing.lg)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.backgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            (item.type == .task ? AppColors.gold : AppColors.darkGreen).opacity(0.2),
                            (item.type == .task ? AppColors.gold : AppColors.darkGreen).opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: (item.type == .task ? AppColors.gold : AppColors.darkGreen).opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    
    private func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "High": return AppColors.orange
        case "Medium": return AppColors.gold
        case "Low": return AppColors.lightBlue
        default: return AppColors.primary
        }
    }
    
    private func formatCompletionTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

