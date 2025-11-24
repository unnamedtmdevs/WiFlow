import SwiftUI

struct TimelineView: View {
    @State private var tasks: [Task] = []
    @State private var projects: [Project] = []
    @State private var milestones: [Milestone] = []
    @State private var selectedDate = Date()
    @State private var viewMode: TimelineViewMode = .week
    @State private var currentMonth = Date()
    @State private var showCalendar = true

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            // Decorative element
            VStack {
                HStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.08))
                        .frame(width: 180, height: 180)
                        .blur(radius: 50)
                        .offset(x: -60, y: -100)
                    Spacer()
                }
                Spacer()
            }

            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    HStack {
                        Spacer()
                        VStack(spacing: AppSpacing.lg) {
                            if showCalendar {
                                calendarSection
                            }
                            
                            dateNavigationSection

                            timelineItemsSection

                            Spacer(minLength: AppSpacing.xl)
                        }
                        .frame(maxWidth: 600)
                        .padding(AppTheme.screenPadding)
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .tasksDidChange)) { _ in
            loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .projectsDidChange)) { _ in
            loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .milestonesDidChange)) { _ in
            loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataDidChange)) { _ in
            loadData()
        }
    }

    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Spacer()
                HStack(spacing: AppSpacing.md) {
                    Text("Timeline")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 28 : 36, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showCalendar.toggle()
                        }
                    }) {
                        Image(systemName: showCalendar ? "calendar" : "calendar.badge.plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
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
                            )
                    }

                    Picker("View Mode", selection: $viewMode) {
                        Text("Week").tag(TimelineViewMode.week)
                        Text("Month").tag(TimelineViewMode.month)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.backgroundSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .frame(maxWidth: 600)
                Spacer()
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)
        }
        .background(AppColors.background)
    }

    private var calendarSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Month header with navigation
            HStack {
                Button(action: {
                    withAnimation {
                        moveMonth(by: -1)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(AppColors.primary.opacity(0.15))
                        )
                }
                
                Spacer()
                
                Text(currentMonth.formatted(style: .long))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .textCase(.none)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        moveMonth(by: 1)
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(AppColors.primary.opacity(0.15))
                        )
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, AppSpacing.xs)
            
            // Calendar grid
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7),
                spacing: 6
            ) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isSelected: isSameDay(date, selectedDate),
                            isToday: isSameDay(date, Date()),
                            hasEvents: hasEvents(on: date),
                            isCurrentMonth: Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDate = date
                                // Update current month if needed
                                let calendar = Calendar.current
                                if !calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                                    currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
                                }
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 60)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.sm)
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
        .shadow(color: AppColors.primary.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.shortWeekdaySymbols
    }
    
    private var calendarDays: [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)!.count
        
        var days: [Date?] = []
        
        // Add empty cells for days before month starts
        let emptyCells = (firstWeekday - calendar.firstWeekday + 7) % 7
        for _ in 0..<emptyCells {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasEvents(on date: Date) -> Bool {
        let calendar = Calendar.current
        let dateStart = calendar.startOfDay(for: date)
        let dateEnd = calendar.date(byAdding: .day, value: 1, to: dateStart)!
        
        let hasTask = tasks.contains { task in
            guard let deadline = task.deadline else { return false }
            let taskDate = calendar.startOfDay(for: deadline)
            return taskDate >= dateStart && taskDate < dateEnd
        }
        
        let hasProject = projects.contains { project in
            guard let deadline = project.deadline else { return false }
            let projectDate = calendar.startOfDay(for: deadline)
            return projectDate >= dateStart && projectDate < dateEnd
        }
        
        let hasMilestone = milestones.contains { milestone in
            let milestoneDate = calendar.startOfDay(for: milestone.targetDate)
            return milestoneDate >= dateStart && milestoneDate < dateEnd
        }
        
        return hasTask || hasProject || hasMilestone
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    private func moveMonth(by offset: Int) {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private var dateNavigationSection: some View {
        HStack(spacing: AppSpacing.lg) {
            Button(action: {
                HapticsService.shared.impact(.light)
                moveDate(by: -1)
            }) {
                ZStack {
                    Circle()
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
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
            }

            Spacer()

            VStack(spacing: AppSpacing.xs) {
                Text(selectedDate.formatted(style: .long))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text(dateRangeText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Button(action: {
                HapticsService.shared.impact(.light)
                moveDate(by: 1)
            }) {
                ZStack {
                    Circle()
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
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.primary)
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
                                    AppColors.primary.opacity(0.3),
                                    AppColors.primary.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: AppColors.primary.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private var timelineItemsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if tasksInRange.isEmpty && projectsInRange.isEmpty && milestonesInRange.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    message: "No deadlines in this period"
                )
                .padding(.top, AppSpacing.xxl)
            } else {
                if !projectsInRange.isEmpty {
                    sectionHeader(title: "Project Deadlines", icon: "folder.fill", color: AppColors.primary)
                    ForEach(projectsInRange) { project in
                        TimelineProjectCard(project: project)
                    }
                }

                if !milestonesInRange.isEmpty {
                    sectionHeader(title: "Milestones", icon: "flag.fill", color: AppColors.gold)
                    ForEach(milestonesInRange) { milestone in
                        TimelineMilestoneCard(milestone: milestone)
                    }
                }

                if !tasksInRange.isEmpty {
                    sectionHeader(title: "Task Deadlines", icon: "checklist", color: AppColors.darkGreen)
                    ForEach(tasksInRange) { task in
                        TimelineTaskCard(task: task, projectName: getProjectName(for: task))
                    }
                }
            }
        }
    }

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
        }
        .padding(.top, AppSpacing.lg)
    }

    private var tasksInRange: [Task] {
        tasks.filter { task in
            guard let deadline = task.deadline else { return false }
            return isDateInRange(deadline)
        }.sorted { task1, task2 in
            guard let d1 = task1.deadline, let d2 = task2.deadline else { return false }
            return d1 < d2
        }
    }

    private var projectsInRange: [Project] {
        projects.filter { project in
            guard let deadline = project.deadline else { return false }
            return isDateInRange(deadline)
        }.sorted { proj1, proj2 in
            guard let d1 = proj1.deadline, let d2 = proj2.deadline else { return false }
            return d1 < d2
        }
    }

    private var milestonesInRange: [Milestone] {
        milestones.filter { isDateInRange($0.targetDate) }
            .sorted { $0.targetDate < $1.targetDate }
    }

    private var dateRangeText: String {
        let calendar = Calendar.current
        let endDate: Date

        switch viewMode {
        case .week:
            endDate = calendar.date(byAdding: .day, value: 7, to: selectedDate) ?? selectedDate
        case .month:
            endDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        }

        return "\(selectedDate.formatted(style: .short)) - \(endDate.formatted(style: .short))"
    }

    private func isDateInRange(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let start = selectedDate
        let days = viewMode == .week ? 7 : 30
        let end = calendar.date(byAdding: .day, value: days, to: start) ?? start

        return date >= start && date <= end
    }

    private func moveDate(by offset: Int) {
        let calendar = Calendar.current
        let component: Calendar.Component = viewMode == .week ? .weekOfYear : .month
        if let newDate = calendar.date(byAdding: component, value: offset, to: selectedDate) {
            withAnimation {
                selectedDate = newDate
                // Update current month if needed
                if !calendar.isDate(newDate, equalTo: currentMonth, toGranularity: .month) {
                    currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: newDate)) ?? newDate
                }
            }
        }
    }

    private func loadData() {
        tasks = TaskService.shared.getAllTasks()
        projects = ProjectService.shared.getAllProjects()
        milestones = MilestoneService.shared.getAllMilestones()
    }

    private func getProjectName(for task: Task) -> String {
        ProjectService.shared.getProject(by: task.projectId)?.name ?? "Unknown"
    }
}

enum TimelineViewMode {
    case week
    case month
}

struct TimelineProjectCard: View {
    let project: Project

    var body: some View {
        HStack(spacing: 0) {
            // Left colored accent bar
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
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
                            LinearGradient(
                                colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "folder.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(project.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)

                    if let deadline = project.deadline {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                                .foregroundColor(deadlineColor(deadline))
                            Text(deadlineText(deadline))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(deadlineColor(deadline))
                        }
                    }
                    
                    StatusBadge(text: project.status.rawValue, color: project.status.color)
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
                            AppColors.primary.opacity(0.2),
                            AppColors.primary.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: AppColors.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func deadlineColor(_ deadline: Date) -> Color {
        let days = Date().daysUntil(deadline)
        if days < 0 {
            return AppColors.orange
        } else if days <= 7 {
            return AppColors.orange
        } else {
            return AppColors.textSecondary
        }
    }
    
    private func deadlineText(_ deadline: Date) -> String {
        let days = Date().daysUntil(deadline)
        if days < 0 {
            return "\(abs(days))d late"
        } else if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else if days <= 7 {
            return "\(days)d"
        } else {
            return deadline.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

struct TimelineMilestoneCard: View {
    let milestone: Milestone

    var body: some View {
        HStack(spacing: 0) {
            // Left colored accent bar
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [AppColors.gold, AppColors.gold.opacity(0.6)],
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
                            LinearGradient(
                                colors: [AppColors.gold.opacity(0.3), AppColors.gold.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "flag.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.gold)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(milestone.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar.fill")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textSecondary)
                        Text(milestone.targetDate.formatted())
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    StatusBadge(text: milestone.status.rawValue, color: milestone.status == .completed ? AppColors.darkGreen : AppColors.gold)
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
                            AppColors.gold.opacity(0.2),
                            AppColors.gold.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: AppColors.gold.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct TimelineTaskCard: View {
    let task: Task
    let projectName: String

    var body: some View {
        HStack(spacing: 0) {
            // Left colored accent bar based on priority
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [task.priority.color, task.priority.color.opacity(0.6)],
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
                            LinearGradient(
                                colors: [task.priority.color.opacity(0.3), task.priority.color.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(task.priority.color)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(task.name)
                        .font(.system(size: 17, weight: task.isCompleted ? .medium : .bold))
                        .foregroundColor(task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                        .strikethrough(task.isCompleted)
                        .lineLimit(2)

                    HStack(spacing: AppSpacing.sm) {
                        // Project name
                        HStack(spacing: 4) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                            Text(projectName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        // Deadline
                        if let deadline = task.deadline {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(deadlineColor(deadline))
                                Text(deadlineText(deadline))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(deadlineColor(deadline))
                            }
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
                        colors: task.isCompleted ?
                        [
                            AppColors.darkGreen.opacity(0.15),
                            AppColors.darkGreen.opacity(0.05)
                        ] :
                        [
                            task.priority.color.opacity(0.2),
                            task.priority.color.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .opacity(task.isCompleted ? 0.7 : 1.0)
        .shadow(color: task.priority.color.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private func deadlineColor(_ deadline: Date) -> Color {
        if task.isOverdue {
            return AppColors.orange
        }
        let days = Date().daysUntil(deadline)
        if days <= 7 {
            return AppColors.orange
        }
        return AppColors.lightBlue
    }
    
    private func deadlineText(_ deadline: Date) -> String {
        let days = Date().daysUntil(deadline)
        if days < 0 {
            return "\(abs(days))d late"
        } else if days == 0 {
            return "Today"
        } else {
            return "\(days)d"
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    let isCurrentMonth: Bool
    let action: () -> Void
    
    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            action()
        }) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                AppColors.backgroundSecondary.opacity(0.5),
                                AppColors.backgroundSecondary.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isToday && !isSelected ?
                                LinearGradient(
                                    colors: [AppColors.primary.opacity(0.6), AppColors.primary.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [
                                        AppColors.primary.opacity(isSelected ? 0.3 : 0.1),
                                        AppColors.primary.opacity(isSelected ? 0.1 : 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isToday && !isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? AppColors.primary.opacity(0.4) : Color.clear,
                        radius: isSelected ? 8 : 0,
                        x: 0,
                        y: isSelected ? 4 : 0
                    )
                
                VStack(spacing: 4) {
                    Text("\(dayNumber)")
                        .font(.system(size: 16, weight: isSelected ? .bold : (isToday ? .semibold : .medium)))
                        .foregroundColor(
                            isSelected ? AppColors.background :
                            isToday ? AppColors.primary :
                            isCurrentMonth ? AppColors.textPrimary : AppColors.textSecondary.opacity(0.5)
                        )
                    
                    // Event indicator
                    if hasEvents {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(isSelected ? AppColors.background : AppColors.primary)
                                .frame(width: 5, height: 5)
                            Circle()
                                .fill(isSelected ? AppColors.background.opacity(0.8) : AppColors.primary.opacity(0.7))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .aspectRatio(0.8, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isCurrentMonth ? 1.0 : 0.35)
    }
}
