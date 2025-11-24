import SwiftUI

struct DebugMenuView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    HStack {
                        Spacer()
                        VStack(spacing: AppSpacing.lg) {
                            headerSection
                            
                            dataCreationSection
                            
                            dataManagementSection
                            
                            statisticsSection
                            
                            Spacer(minLength: AppSpacing.xl)
                        }
                        .frame(maxWidth: 600)
                        .padding(AppTheme.screenPadding)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Debug Menu")
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
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                // Update statistics on appear
            }
            .onReceive(NotificationCenter.default.publisher(for: .dataDidChange)) { _ in
                // Update statistics when data changes
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Debug Tools")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text("Testing utilities for development")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    private var dataCreationSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Create Test Data")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                debugButton(
                    title: "Create Sample Project",
                    icon: "folder.badge.plus",
                    color: AppColors.primary
                ) {
                    createSampleProject()
                }
                
                debugButton(
                    title: "Create 5 Test Projects",
                    icon: "folder.fill",
                    color: AppColors.primary
                ) {
                    createMultipleProjects(count: 5)
                }
                
                debugButton(
                    title: "Create 10 Test Tasks",
                    icon: "checklist",
                    color: AppColors.gold
                ) {
                    createMultipleTasks(count: 10)
                }
                
                debugButton(
                    title: "Create Sample Resources",
                    icon: "paperclip",
                    color: AppColors.orange
                ) {
                    createSampleResources()
                }
                
                debugButton(
                    title: "Create Full Test Dataset",
                    icon: "sparkles",
                    color: AppColors.lightBlue
                ) {
                    createFullTestDataset()
                }
            }
        }
    }
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Data Management")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                debugButton(
                    title: "Clear All Projects",
                    icon: "trash.fill",
                    color: AppColors.orange,
                    isDestructive: true
                ) {
                    clearAllProjects()
                }
                
                debugButton(
                    title: "Clear All Tasks",
                    icon: "trash.fill",
                    color: AppColors.orange,
                    isDestructive: true
                ) {
                    clearAllTasks()
                }
                
                debugButton(
                    title: "Clear All Resources",
                    icon: "trash.fill",
                    color: AppColors.orange,
                    isDestructive: true
                ) {
                    clearAllResources()
                }
                
                debugButton(
                    title: "Clear All Data",
                    icon: "exclamationmark.triangle.fill",
                    color: AppColors.orange,
                    isDestructive: true
                ) {
                    clearAllData()
                }
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Statistics")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                let stats = getStatistics()
                
                DebugStatRow(label: "Projects", value: "\(stats.projects)")
                DebugStatRow(label: "Tasks", value: "\(stats.tasks)")
                DebugStatRow(label: "Resources", value: "\(stats.resources)")
                DebugStatRow(label: "Categories", value: "\(stats.categories)")
                DebugStatRow(label: "History Items", value: "\(stats.history)")
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
    }
    
    private func debugButton(
        title: String,
        icon: String,
        color: Color,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            HapticsService.shared.impact(.medium)
            action()
        }) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(color.opacity(isDestructive ? 0.3 : 0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
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
                                        color.opacity(0.3),
                                        color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Data Creation
    
    private func createSampleProject() {
        let categories = CategoryService.shared.getAllCategories()
        let categoryName = categories.randomElement()?.name ?? "Personal"
        
        let project = Project(
            name: "Sample Project \(Int.random(in: 1...100))",
            description: "This is a sample project created for testing purposes.",
            status: ProjectStatus.allCases.randomElement() ?? .planning,
            priority: ProjectPriority.allCases.randomElement() ?? .medium,
            category: categoryName,
            deadline: Calendar.current.date(byAdding: .day, value: Int.random(in: 1...30), to: Date())
        )
        
        ProjectService.shared.createProject(project)
        showAlert(title: "Success", message: "Sample project created")
    }
    
    private func createMultipleProjects(count: Int) {
        let categories = CategoryService.shared.getAllCategories()
        let categoryNames = categories.map { $0.name }
        
        for i in 1...count {
            let project = Project(
                name: "Test Project \(i)",
                description: "Test project number \(i) for testing",
                status: ProjectStatus.allCases.randomElement() ?? .planning,
                priority: ProjectPriority.allCases.randomElement() ?? .medium,
                category: categoryNames.randomElement() ?? "Personal",
                deadline: Calendar.current.date(byAdding: .day, value: Int.random(in: 1...60), to: Date())
            )
            ProjectService.shared.createProject(project)
        }
        
        showAlert(title: "Success", message: "Created \(count) test projects")
    }
    
    private func createMultipleTasks(count: Int) {
        let projects = ProjectService.shared.getAllProjects()
        guard !projects.isEmpty else {
            showAlert(title: "Error", message: "Create at least one project first")
            return
        }
        
        for i in 1...count {
            let project = projects.randomElement()!
            let task = Task(
                name: "Test Task \(i)",
                description: "Test task number \(i)",
                projectId: project.id,
                status: TaskStatus.allCases.randomElement() ?? .toDo,
                priority: TaskPriority.allCases.randomElement() ?? .medium,
                deadline: Calendar.current.date(byAdding: .day, value: Int.random(in: 1...30), to: Date())
            )
            TaskService.shared.createTask(task)
        }
        
        showAlert(title: "Success", message: "Created \(count) test tasks")
    }
    
    private func createSampleResources() {
        let projects = ProjectService.shared.getAllProjects()
        guard !projects.isEmpty else {
            showAlert(title: "Error", message: "Create at least one project first")
            return
        }
        
        let resourceTypes: [ResourceType] = [.note, .link, .file]
        
        for i in 1...3 {
            let project = projects.randomElement()!
            let type = resourceTypes[i % resourceTypes.count]
            
            let resource = Resource(
                name: "Sample \(type.rawValue) \(i)",
                type: type,
                projectId: project.id,
                content: type == .link ? "https://example.com/\(i)" : "Sample content for \(type.rawValue) \(i)",
                notes: ""
            )
            ResourceService.shared.createResource(resource)
        }
        
        showAlert(title: "Success", message: "Created 3 sample resources")
    }
    
    private func createFullTestDataset() {
        // Create projects
        let categories = CategoryService.shared.getAllCategories()
        let categoryNames = categories.map { $0.name }
        
        for i in 1...5 {
            let project = Project(
                name: "Project \(i)",
                description: "Description for project \(i)",
                status: ProjectStatus.allCases.randomElement() ?? .planning,
                priority: ProjectPriority.allCases.randomElement() ?? .medium,
                category: categoryNames.randomElement() ?? "Personal",
                deadline: Calendar.current.date(byAdding: .day, value: Int.random(in: 1...60), to: Date())
            )
            ProjectService.shared.createProject(project)
        }
        
        // Create tasks for projects
        let projects = ProjectService.shared.getAllProjects()
        for project in projects.prefix(5) {
            for i in 1...3 {
                let task = Task(
                    name: "Task \(i) for \(project.name)",
                    description: "Task description",
                    projectId: project.id,
                    status: TaskStatus.allCases.randomElement() ?? .toDo,
                    priority: TaskPriority.allCases.randomElement() ?? .medium,
                    deadline: Calendar.current.date(byAdding: .day, value: Int.random(in: 1...30), to: Date())
                )
                TaskService.shared.createTask(task)
            }
        }
        
        // Create resources
        for project in projects.prefix(3) {
            let note = Resource(
                name: "Note for \(project.name)",
                type: .note,
                projectId: project.id,
                content: "This is a note for the project",
                notes: ""
            )
            ResourceService.shared.createResource(note)
        }
        
        showAlert(title: "Success", message: "Created full test dataset (5 projects, 15 tasks, 3 resources)")
    }
    
    // MARK: - Data Management
    
    private func clearAllProjects() {
        let projects = ProjectService.shared.getAllProjects()
        for project in projects {
            ProjectService.shared.deleteProject(project)
        }
        showAlert(title: "Success", message: "All projects deleted")
    }
    
    private func clearAllTasks() {
        let tasks = TaskService.shared.getAllTasks()
        for task in tasks {
            TaskService.shared.deleteTask(task)
        }
        showAlert(title: "Success", message: "All tasks deleted")
    }
    
    private func clearAllResources() {
        let resources = ResourceService.shared.getAllResources()
        for resource in resources {
            ResourceService.shared.deleteResource(resource)
        }
        showAlert(title: "Success", message: "All resources deleted")
    }
    
    private func clearAllData() {
        clearAllProjects()
        clearAllTasks()
        clearAllResources()
        
        // Clear history
        StorageService.shared.saveArray([HistoryItem](), forKey: UserDefaultsKeys.history)
        
        showAlert(title: "Success", message: "All data cleared")
    }
    
    // MARK: - Statistics
    
    private func getStatistics() -> (projects: Int, tasks: Int, resources: Int, categories: Int, history: Int) {
        let projects = ProjectService.shared.getAllProjects().count
        let tasks = TaskService.shared.getAllTasks().count
        let resources = ResourceService.shared.getAllResources().count
        let categories = CategoryService.shared.getAllCategories().count
        let history = HistoryService.shared.getAllHistory().count
        
        return (projects, tasks, resources, categories, history)
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct DebugStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

