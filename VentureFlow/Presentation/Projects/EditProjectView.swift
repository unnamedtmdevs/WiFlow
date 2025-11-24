import SwiftUI

struct EditProjectView: View {
    @Environment(\.dismiss) var dismiss
    let project: Project
    let onSave: () -> Void

    @State private var name: String
    @State private var description: String
    @State private var priority: ProjectPriority
    @State private var status: ProjectStatus
    @State private var category: String
    @State private var hasDeadline: Bool
    @State private var deadline: Date
    @State private var notes: String
    @State private var categories: [Category] = []

    init(project: Project, onSave: @escaping () -> Void) {
        self.project = project
        self.onSave = onSave
        _name = State(initialValue: project.name)
        _description = State(initialValue: project.description)
        _priority = State(initialValue: project.priority)
        _status = State(initialValue: project.status)
        _category = State(initialValue: project.category)
        _hasDeadline = State(initialValue: project.deadline != nil)
        _deadline = State(initialValue: project.deadline ?? Date())
        _notes = State(initialValue: project.notes)
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
                            Text("Project Name")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            TextField("Enter project name", text: $name)
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
                            Text("Priority")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            HStack(spacing: AppSpacing.sm) {
                                ForEach(ProjectPriority.allCases, id: \.self) { p in
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
                                ForEach(ProjectStatus.allCases, id: \.self) { s in
                                    Text(s.rawValue).tag(s)
                                }
                            }
                            .pickerStyle(.segmented)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(8)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            HStack {
                                Text("Category")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Spacer()
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.sm) {
                                    ForEach(categories, id: \.id) { cat in
                                        Button(action: {
                                            withAnimation(SettingsService.shared.animationsEnabled ? .spring(response: 0.3, dampingFraction: 0.7) : .none) {
                                                HapticsService.shared.impact(.light)
                                                category = cat.name
                                            }
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: cat.icon)
                                                    .font(.system(size: 12, weight: .semibold))
                                                Text(cat.name)
                                                    .font(AppTypography.caption)
                                            }
                                            .foregroundColor(category == cat.name ? AppColors.background : AppColors.textPrimary)
                                            .padding(.horizontal, AppSpacing.md)
                                            .padding(.vertical, AppSpacing.sm)
                                            .background(
                                                category == cat.name ?
                                                Color(hex: cat.color) :
                                                AppColors.backgroundSecondary
                                            )
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        category == cat.name ? Color.clear : Color(hex: cat.color).opacity(0.3),
                                                        lineWidth: 1
                                                    )
                                            )
                                        }
                                    }
                                }
                            }
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

                        Button(action: saveProject) {
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
            .navigationTitle("Edit Project")
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
                loadCategories()
            }
            .onReceive(NotificationCenter.default.publisher(for: .categoriesDidChange)) { _ in
                loadCategories()
                // If current category was deleted, set to Personal
                if !categories.contains(where: { $0.name == category }) {
                    category = "Personal"
                }
            }
        }
    }
    
    private func loadCategories() {
        categories = CategoryService.shared.getAllCategories()
        // If current category doesn't exist, set to Personal
        if !categories.contains(where: { $0.name == category }) {
            category = "Personal"
        }
    }

    private func saveProject() {
        var updatedProject = project
        updatedProject.name = name
        updatedProject.description = description
        updatedProject.priority = priority
        updatedProject.status = status
        updatedProject.category = category
        updatedProject.deadline = hasDeadline ? deadline : nil
        updatedProject.notes = notes

        ProjectService.shared.updateProject(updatedProject)
        HapticsService.shared.success()
        onSave()
        dismiss()
    }
}

