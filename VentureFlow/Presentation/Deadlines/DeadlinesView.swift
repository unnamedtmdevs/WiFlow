import SwiftUI

enum DeadlineType {
    case overdue
    case upcoming
}

struct DeadlinesView: View {
    @Environment(\.dismiss) var dismiss
    let deadlineType: DeadlineType
    @State private var tasks: [Task] = []
    @State private var selectedTask: Task?
    @State private var selectedProject: Project?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    HStack {
                        Spacer()
                        VStack(spacing: AppSpacing.lg) {
                            headerSection
                            
                            if tasks.isEmpty {
                                EmptyStateView(
                                    icon: deadlineType == .overdue ? "checkmark.circle.fill" : "calendar",
                                    message: deadlineType == .overdue ? 
                                        "No overdue tasks. Great job!" : 
                                        "No upcoming deadlines this week"
                                )
                                .padding(.top, AppSpacing.xxl)
                            } else {
                                tasksListSection
                            }
                            
                            Spacer(minLength: AppSpacing.xl)
                        }
                        .frame(maxWidth: 600)
                        .padding(AppTheme.screenPadding)
                        Spacer()
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            .onAppear {
                loadTasks()
            }
            .onReceive(NotificationCenter.default.publisher(for: .tasksDidChange)) { _ in
                loadTasks()
            }
            .onReceive(NotificationCenter.default.publisher(for: .projectsDidChange)) { _ in
                loadTasks()
            }
            .onReceive(NotificationCenter.default.publisher(for: .dataDidChange)) { _ in
                loadTasks()
            }
            .sheet(item: $selectedTask) { task in
                EditTaskView(task: task, onSave: {
                    loadTasks()
                })
            }
            .sheet(item: $selectedProject) { project in
                ProjectDetailView(project: project, onUpdate: {
                    loadTasks()
                })
            }
        }
    }
    
    private var title: String {
        deadlineType == .overdue ? "Overdue Tasks" : "Upcoming Deadlines"
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text(deadlineType == .overdue ? 
                 "Tasks that have passed their deadline" : 
                 "Tasks due within the next 7 days")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    private var tasksListSection: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(tasks) { task in
                DeadlineTaskCard(
                    task: task,
                    deadlineType: deadlineType,
                    onTap: {
                        selectedTask = task
                    },
                    onProjectTap: {
                        if let project = ProjectService.shared.getProject(by: task.projectId) {
                            selectedProject = project
                        }
                    }
                )
            }
        }
    }
    
    private func loadTasks() {
        let taskService = TaskService.shared
        if deadlineType == .overdue {
            tasks = taskService.getOverdueTasks()
                .sorted { task1, task2 in
                    // Sort by deadline: most overdue first
                    guard let d1 = task1.deadline, let d2 = task2.deadline else { return false }
                    return d1 < d2
                }
        } else {
            tasks = taskService.getTasksDueThisWeek()
                .sorted { task1, task2 in
                    // Sort by deadline: nearest deadlines first
                    guard let d1 = task1.deadline, let d2 = task2.deadline else { return false }
                    return d1 < d2
                }
        }
    }
}

struct DeadlineTaskCard: View {
    let task: Task
    let deadlineType: DeadlineType
    let onTap: () -> Void
    let onProjectTap: () -> Void
    
    private var projectName: String {
        ProjectService.shared.getProject(by: task.projectId)?.name ?? "Unknown Project"
    }
    
    private var daysUntilDeadline: Int? {
        guard let deadline = task.deadline else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        return components.day
    }
    
    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            onTap()
        }) {
            HStack(spacing: 0) {
                // Left accent bar
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                deadlineType == .overdue ? AppColors.orange : AppColors.gold,
                                (deadlineType == .overdue ? AppColors.orange : AppColors.gold).opacity(0.6)
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
                                (deadlineType == .overdue ? AppColors.orange : AppColors.gold).opacity(0.2)
                            )
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: deadlineType == .overdue ? "exclamationmark.triangle.fill" : "clock.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(deadlineType == .overdue ? AppColors.orange : AppColors.gold)
                    }
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(task.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                        
                        HStack(spacing: AppSpacing.sm) {
                            Button(action: {
                                HapticsService.shared.impact(.light)
                                onProjectTap()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "folder.fill")
                                        .font(.system(size: 11, weight: .semibold))
                                    Text(projectName)
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.backgroundSecondary.opacity(0.6))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if task.deadline != nil {
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 11, weight: .semibold))
                                    
                                    if deadlineType == .overdue {
                                        Text("Overdue")
                                            .font(.system(size: 13, weight: .semibold))
                                    } else if let days = daysUntilDeadline {
                                        Text("\(days) day\(days == 1 ? "" : "s") left")
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                }
                                .foregroundColor(deadlineType == .overdue ? AppColors.orange : AppColors.gold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background((deadlineType == .overdue ? AppColors.orange : AppColors.gold).opacity(0.15))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    StatusBadge(
                        text: task.priority.rawValue,
                        color: task.priority.color
                    )
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
                                (deadlineType == .overdue ? AppColors.orange : AppColors.gold).opacity(0.2),
                                (deadlineType == .overdue ? AppColors.orange : AppColors.gold).opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: (deadlineType == .overdue ? AppColors.orange : AppColors.gold).opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

