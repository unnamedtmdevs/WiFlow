import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    let task: Task
    let onSave: () -> Void

    @State private var name: String
    @State private var description: String
    @State private var priority: TaskPriority
    @State private var status: TaskStatus
    @State private var hasDeadline: Bool
    @State private var deadline: Date
    @State private var notes: String
    @State private var selectedProjectId: UUID
    @State private var projects: [Project] = []

    init(task: Task, onSave: @escaping () -> Void) {
        self.task = task
        self.onSave = onSave
        _name = State(initialValue: task.name)
        _description = State(initialValue: task.description)
        _priority = State(initialValue: task.priority)
        _status = State(initialValue: task.status)
        _hasDeadline = State(initialValue: task.deadline != nil)
        _deadline = State(initialValue: task.deadline ?? Date())
        _notes = State(initialValue: task.notes)
        _selectedProjectId = State(initialValue: task.projectId)
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    HStack {
                        Spacer()
                        VStack(spacing: AppSpacing.lg) {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Task Name")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            TextField("Enter task name", text: $name)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(AppSpacing.md)
                                .background(AppColors.backgroundSecondary)
                                .cornerRadius(AppTheme.cornerRadius)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Description")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            TextEditor(text: $description)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(height: 100)
                                .padding(AppSpacing.sm)
                                .background(AppColors.backgroundSecondary)
                                .cornerRadius(AppTheme.cornerRadius)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Project")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            if projects.isEmpty {
                                Text("No projects available.")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(AppSpacing.md)
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.backgroundSecondary)
                                    .cornerRadius(AppTheme.cornerRadius)
                            } else {
                                Menu {
                                    ForEach(projects) { project in
                                        Button(action: {
                                            selectedProjectId = project.id
                                        }) {
                                            HStack {
                                                Text(project.name)
                                                if selectedProjectId == project.id {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(projects.first(where: { $0.id == selectedProjectId })?.name ?? "Select project")
                                            .font(AppTypography.body)
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding(AppSpacing.md)
                                    .background(AppColors.backgroundSecondary)
                                    .cornerRadius(AppTheme.cornerRadius)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Priority")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            HStack(spacing: AppSpacing.sm) {
                                ForEach(TaskPriority.allCases, id: \.self) { p in
                                    Button(action: {
                                        HapticsService.shared.impact(.light)
                                        priority = p
                                    }) {
                                        Text(p.rawValue)
                                            .font(AppTypography.caption)
                                            .foregroundColor(priority == p ? AppColors.background : AppColors.textPrimary)
                                            .padding(.horizontal, AppSpacing.md)
                                            .padding(.vertical, AppSpacing.sm)
                                            .frame(maxWidth: .infinity)
                                            .background(priority == p ? p.color : AppColors.backgroundSecondary)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Status")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            Picker("Status", selection: $status) {
                                ForEach(TaskStatus.allCases, id: \.self) { s in
                                    Text(s.rawValue).tag(s)
                                }
                            }
                            .pickerStyle(.segmented)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(8)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Toggle("Set Deadline", isOn: $hasDeadline)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textPrimary)

                            if hasDeadline {
                                DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }

                        Button(action: saveTask) {
                            Text("Save Changes")
                                .primaryButtonStyle()
                        }
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1.0)

                            Spacer(minLength: AppSpacing.xl)
                        }
                        .frame(maxWidth: 600)
                        .padding(AppTheme.screenPadding)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            .onAppear {
                loadProjects()
            }
        }
    }

    private func saveTask() {
        var updatedTask = task
        updatedTask.name = name
        updatedTask.description = description
        updatedTask.priority = priority
        updatedTask.status = status
        updatedTask.deadline = hasDeadline ? deadline : nil
        updatedTask.notes = notes
        updatedTask.projectId = selectedProjectId

        TaskService.shared.updateTask(updatedTask)
        HapticsService.shared.success()
        onSave()
        dismiss()
    }

    private func loadProjects() {
        projects = ProjectService.shared.getAllProjects()
    }
}

