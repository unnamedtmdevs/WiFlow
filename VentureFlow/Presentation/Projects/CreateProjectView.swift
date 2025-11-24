import SwiftUI

struct CreateProjectView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: () -> Void

    @State private var name = ""
    @State private var description = ""
    @State private var priority: ProjectPriority = .medium
    @State private var status: ProjectStatus = .planning
    @State private var category = "Personal"
    @State private var startDate = Date()
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var notes = ""
    @State private var categories: [Category] = []

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

                            if categories.isEmpty {
                                Text("No categories available. Create a category first.")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(AppSpacing.md)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.backgroundSecondary)
                                    .cornerRadius(AppTheme.cornerRadius)
                            } else {
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
                                                        .lineLimit(1)
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
                                                .shadow(
                                                    color: category == cat.name ? Color(hex: cat.color).opacity(0.3) : Color.clear,
                                                    radius: category == cat.name ? 4 : 0,
                                                    x: 0,
                                                    y: category == cat.name ? 2 : 0
                                                )
                                            }
                                        }
                                    }
                                    .padding(.horizontal, AppSpacing.xs)
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
                            Text("Create Project")
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
            .navigationTitle("New Project")
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
                // If current category was deleted, set to first available
                if !categories.contains(where: { $0.name == category }) {
                    category = categories.first?.name ?? "Personal"
                }
            }
        }
    }
    
    private func loadCategories() {
        categories = CategoryService.shared.getAllCategories()
        // If category not found in list, set to first available
        if !categories.contains(where: { $0.name == category }) {
            category = categories.first?.name ?? "Personal"
        }
    }

    private func saveProject() {
        let project = Project(
            name: name,
            description: description,
            status: status,
            priority: priority,
            category: category,
            startDate: startDate,
            deadline: hasDeadline ? deadline : nil,
            notes: notes
        )

        ProjectService.shared.createProject(project)
        HapticsService.shared.success()
        onSave()
        dismiss()
    }
}
