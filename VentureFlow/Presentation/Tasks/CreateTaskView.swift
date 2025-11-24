import SwiftUI

struct CreateTaskView: View {
    @Environment(\.dismiss) var dismiss
    let projectId: UUID?
    let onSave: () -> Void

    @State private var name = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var status: TaskStatus = .toDo
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var notes = ""
    @State private var selectedProjectId: UUID?
    @State private var projects: [Project] = []
    @State private var recurrenceFrequency: RecurrenceFrequency = .none
    @State private var recurrenceInterval: Int = 1
    @State private var recurrenceEndDate: Date? = nil
    @State private var hasRecurrenceEndDate = false

    init(projectId: UUID? = nil, onSave: @escaping () -> Void) {
        self.projectId = projectId
        self.onSave = onSave
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

                        if projectId == nil {
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                Text("Project")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textSecondary)

                                if projects.isEmpty {
                                    Text("No projects available. Create a project first.")
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
                                            Text(selectedProjectId == nil ? "Select project" : projects.first(where: { $0.id == selectedProjectId })?.name ?? "Select project")
                                                .font(AppTypography.body)
                                                .foregroundColor(selectedProjectId == nil ? AppColors.textSecondary : AppColors.textPrimary)
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
                        
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Repeat")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Picker("Frequency", selection: $recurrenceFrequency) {
                                ForEach(RecurrenceFrequency.allCases, id: \.self) { frequency in
                                    Text(frequency.description).tag(frequency)
                                }
                            }
                            .pickerStyle(.segmented)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(8)
                            
                            if recurrenceFrequency != .none {
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    HStack {
                                        Text("Every")
                                            .font(AppTypography.body)
                                            .foregroundColor(AppColors.textSecondary)
                                        
                                        Stepper("", value: $recurrenceInterval, in: 1...365)
                                            .labelsHidden()
                                        
                                        Text(recurrenceIntervalText)
                                            .font(AppTypography.body)
                                            .foregroundColor(AppColors.textPrimary)
                                    }
                                    
                                    Toggle("Set End Date", isOn: $hasRecurrenceEndDate)
                                        .font(AppTypography.body)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    if hasRecurrenceEndDate {
                                        DatePicker("End Date", selection: Binding(
                                            get: { recurrenceEndDate ?? Date().addingTimeInterval(86400 * 30) },
                                            set: { recurrenceEndDate = $0 }
                                        ), displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .font(AppTypography.body)
                                        .foregroundColor(AppColors.textPrimary)
                                    }
                                }
                                .padding(AppSpacing.md)
                                .background(AppColors.backgroundSecondary.opacity(0.5))
                                .cornerRadius(AppTheme.cornerRadius)
                            }
                        }

                        Button(action: saveTask) {
                            Text("Create Task")
                                .primaryButtonStyle()
                        }
                        .disabled(name.isEmpty || (projectId == nil && selectedProjectId == nil))
                        .opacity(name.isEmpty || (projectId == nil && selectedProjectId == nil) ? 0.5 : 1.0)

                            Spacer(minLength: AppSpacing.xl)
                        }
                        .frame(maxWidth: 600)
                        .padding(AppTheme.screenPadding)
                        Spacer()
                    }
                }
            }
            .navigationTitle("New Task")
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
                if projectId == nil {
                    loadProjects()
                } else {
                    selectedProjectId = projectId
                }
            }
        }
    }

    private var recurrenceIntervalText: String {
        switch recurrenceFrequency {
        case .daily: return recurrenceInterval == 1 ? "day" : "days"
        case .weekly: return recurrenceInterval == 1 ? "week" : "weeks"
        case .monthly: return recurrenceInterval == 1 ? "month" : "months"
        case .yearly: return recurrenceInterval == 1 ? "year" : "years"
        case .none: return ""
        }
    }
    
    private func saveTask() {
        let finalProjectId = projectId ?? selectedProjectId
        guard let finalProjectId = finalProjectId else { return }
        
        // Check if project still exists
        guard ProjectService.shared.getProject(by: finalProjectId) != nil else {
            return
        }
        
        var recurrenceRule: RecurrenceRule? = nil
        if recurrenceFrequency != .none {
            recurrenceRule = RecurrenceRule(
                frequency: recurrenceFrequency,
                interval: recurrenceInterval,
                endDate: hasRecurrenceEndDate ? recurrenceEndDate : nil
            )
        }
        
        let task = Task(
            name: name,
            description: description,
            projectId: finalProjectId,
            status: status,
            priority: priority,
            deadline: hasDeadline ? deadline : nil,
            notes: notes,
            recurrenceRule: recurrenceRule,
            startTrackingDate: Date()
        )

        TaskService.shared.createTask(task)
        HapticsService.shared.success()
        onSave()
        dismiss()
    }

    private func loadProjects() {
        projects = ProjectService.shared.getAllProjects()
    }
}
