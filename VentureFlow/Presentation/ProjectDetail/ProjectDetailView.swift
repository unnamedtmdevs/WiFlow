import SwiftUI

struct ProjectDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State var project: Project
    let onUpdate: () -> Void

    @State private var tasks: [Task] = []
    @State private var showCreateTask = false
    @State private var showEditProject = false
    @State private var selectedTask: Task?
    @State private var showDeleteAlert = false
    @State private var taskToDelete: Task?

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: AppSpacing.lg) {
                            projectHeaderSection

                            projectInfoSection

                            tasksSection

                            Spacer(minLength: AppSpacing.xl)
                        }
                        .frame(maxWidth: 600)
                        .padding(AppTheme.screenPadding)
                        Spacer()
                    }
                }
            }
            .navigationTitle(project.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        HapticsService.shared.impact(.light)
                        showEditProject = true
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            .onAppear {
                loadTasks()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .tasksDidChange)) { _ in
            loadTasks()
        }
        .onReceive(NotificationCenter.default.publisher(for: .projectsDidChange)) { _ in
            // Reload project data
            if let updatedProject = ProjectService.shared.getProject(by: project.id) {
                project = updatedProject
            }
            loadTasks()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataDidChange)) { _ in
            // Reload project data
            if let updatedProject = ProjectService.shared.getProject(by: project.id) {
                project = updatedProject
            }
            loadTasks()
        }
        .sheet(isPresented: $showCreateTask) {
            CreateTaskView(projectId: project.id, onSave: {
                loadTasks()
                onUpdate()
            })
        }
        .sheet(isPresented: $showEditProject) {
            EditProjectView(project: project, onSave: {
                // Reload project data
                if let updatedProject = ProjectService.shared.getProject(by: project.id) {
                    project = updatedProject
                }
                loadTasks()
                onUpdate()
            })
        }
        .sheet(item: $selectedTask) { task in
            EditTaskView(task: task, onSave: {
                loadTasks()
                onUpdate()
            })
        }
        .alert("Delete Task", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                taskToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let task = taskToDelete {
                    deleteTask(task)
                }
                taskToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
    }
    
    private func deleteTask(_ task: Task) {
        TaskService.shared.deleteTask(task)
        loadTasks()
        onUpdate()
    }

    private var projectHeaderSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                ProgressRing(
                    progress: calculateProgress(),
                    lineWidth: 8,
                    size: 100
                )

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    StatusBadge(text: project.status.rawValue, color: project.status.color)
                    StatusBadge(text: project.priority.rawValue, color: project.priority.color)

                    if let deadline = project.deadline {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(AppColors.gold)
                            Text(deadline.formatted())
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }

                Spacer()
            }
            .padding(AppTheme.cardPadding)
            .cardStyle()
        }
    }

    private var projectInfoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if !project.description.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Description")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text(project.description)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(AppTheme.cardPadding)
                .cardStyle()
            }

            HStack(spacing: AppSpacing.md) {
                InfoCard(title: "Tasks", value: "\(tasks.count)", icon: "checklist")
                InfoCard(title: "Completed", value: "\(tasks.filter { $0.isCompleted }.count)", icon: "checkmark.circle.fill")
            }
        }
    }

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Tasks")
                    .font(AppTypography.title)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: {
                    HapticsService.shared.impact()
                    showCreateTask = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.primary)
                }
            }

            if tasks.isEmpty {
                EmptyStateView(
                    icon: "checklist",
                    message: "No tasks yet. Add your first task!"
                )
            } else {
                // Sort tasks: incomplete first, then completed
                let sortedTasks = tasks.sorted { task1, task2 in
                    if task1.isCompleted != task2.isCompleted {
                        return !task1.isCompleted && task2.isCompleted
                    }
                    return false
                }
                
                ForEach(sortedTasks) { task in
                    TaskCard(
                        task: task,
                        projectName: project.name,
                        onComplete: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                completeTask(task)
                            }
                        },
                        onTap: {
                            selectedTask = task
                        }
                    )
                    .contextMenu {
                        Button {
                            HapticsService.shared.impact(.light)
                            selectedTask = task
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            HapticsService.shared.warning()
                            taskToDelete = task
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private func loadTasks() {
        tasks = TaskService.shared.getTasksForProject(project.id)
    }

    private func calculateProgress() -> Double {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(tasks.count) * 100
    }

    private func completeTask(_ task: Task) {
        var updatedTask = task
        // Toggle completion status
        if task.isCompleted {
            updatedTask.status = .toDo
        } else {
            updatedTask.status = .completed
        }
        TaskService.shared.updateTask(updatedTask)
        loadTasks()
        onUpdate()
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: AppTheme.iconSizeMedium))
                .foregroundColor(AppColors.primary)

            Text(value)
                .font(AppTypography.title)
                .foregroundColor(AppColors.textPrimary)

            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.cardPadding)
        .cardStyle()
    }
}
