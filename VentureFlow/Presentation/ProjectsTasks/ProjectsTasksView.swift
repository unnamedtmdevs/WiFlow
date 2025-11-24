import SwiftUI

enum ProjectsTasksTab: String, CaseIterable {
    case projects = "Projects"
    case tasks = "Tasks"
    
    var icon: String {
        switch self {
        case .projects: return "folder.fill"
        case .tasks: return "checklist"
        }
    }
}

struct ProjectsTasksView: View {
    @State private var selectedTab: ProjectsTasksTab = .projects
    @State private var showCreateProject = false
    @State private var showCreateTask = false
    @State private var selectedProject: Project?
    @State private var selectedProjectForEdit: Project?
    @State private var selectedTask: Task?
    @State private var showDeleteProjectAlert = false
    @State private var projectToDelete: Project?
    @State private var showDeleteTaskAlert = false
    @State private var taskToDelete: Task?
    
    @StateObject private var projectsViewModel = ProjectsViewModel()
    @StateObject private var tasksViewModel = TasksViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            // Decorative element
            VStack {
                HStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.08))
                        .frame(width: 150, height: 150)
                        .blur(radius: 40)
                        .offset(x: -50, y: -80)
                    Spacer()
                }
                Spacer()
            }
            
            VStack(spacing: 0) {
                headerSection
                
                tabSelector
                
                if selectedTab == .projects {
                    if projectsViewModel.showFilters {
                        projectsFiltersSection
                    }
                } else {
                    if tasksViewModel.showFilters {
                        tasksFiltersSection
                    }
                }
                
                ScrollView {
                    HStack {
                        Spacer()
                        VStack(spacing: AppSpacing.md) {
                            if selectedTab == .projects {
                                projectsContent
                            } else {
                                tasksContent
                            }
                            
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
            projectsViewModel.loadProjects()
            tasksViewModel.loadTasks()
        }
        .sheet(isPresented: $showCreateProject) {
            CreateProjectView(onSave: {
                projectsViewModel.loadProjects()
            })
        }
        .sheet(isPresented: $showCreateTask) {
            CreateTaskView(onSave: {
                tasksViewModel.loadTasks()
            })
        }
        .sheet(item: $selectedProject) { project in
            ProjectDetailView(project: project, onUpdate: {
                projectsViewModel.loadProjects()
            })
        }
        .sheet(item: $selectedProjectForEdit) { project in
            EditProjectView(project: project, onSave: {
                projectsViewModel.loadProjects()
            })
        }
        .sheet(item: $selectedTask) { task in
            EditTaskView(task: task, onSave: {
                tasksViewModel.loadTasks()
            })
        }
        .alert("Delete Project", isPresented: $showDeleteProjectAlert) {
            Button("Cancel", role: .cancel) {
                projectToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let project = projectToDelete {
                    projectsViewModel.deleteProject(project)
                }
                projectToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this project? All tasks and resources in this project will also be deleted. This action cannot be undone.")
        }
        .alert("Delete Task", isPresented: $showDeleteTaskAlert) {
            Button("Cancel", role: .cancel) {
                taskToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let task = taskToDelete {
                    tasksViewModel.deleteTask(task)
                }
                taskToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("My Work")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                HStack(spacing: AppSpacing.sm) {
                    Button(action: {
                        HapticsService.shared.impact(.light)
                        if selectedTab == .projects {
                            projectsViewModel.showFilters.toggle()
                        } else {
                            tasksViewModel.showFilters.toggle()
                        }
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
                            
                            Image(systemName: (selectedTab == .projects ? projectsViewModel.showFilters : tasksViewModel.showFilters) ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    
                    Button(action: {
                        HapticsService.shared.impact()
                        if selectedTab == .projects {
                            showCreateProject = true
                        } else {
                            showCreateTask = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .shadow(color: AppColors.primary.opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.background)
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, AppSpacing.lg)
            
            searchBar
        }
        .background(AppColors.background)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ProjectsTasksTab.allCases, id: \.self) { tab in
                    Button(action: {
                        HapticsService.shared.impact(.light)
                        withAnimation(SettingsService.shared.animationsEnabled ? .spring(response: 0.3, dampingFraction: 0.7) : .none) {
                            selectedTab = tab
                            projectsViewModel.showFilters = false
                            tasksViewModel.showFilters = false
                        }
                    }) {
                    VStack(spacing: AppSpacing.xs) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? AppColors.primary : AppColors.textSecondary)
                            
                            Text(tab.rawValue)
                                .font(.system(size: 16, weight: selectedTab == tab ? .bold : .semibold))
                                .foregroundColor(selectedTab == tab ? AppColors.primary : AppColors.textSecondary)
                        }
                        
                        // Indicator line
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 3)
                                .matchedGeometryEffect(id: "tabIndicator", in: tabNamespace)
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                }
            }
        }
        .background(AppColors.background)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppColors.backgroundSecondary.opacity(0.5)),
            alignment: .bottom
        )
    }
    
    @Namespace private var tabNamespace
    
    private var searchBar: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.primary)
            }
            
            if selectedTab == .projects {
                TextField("Search projects...", text: $projectsViewModel.searchText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .onChange(of: projectsViewModel.searchText) { _ in
                        projectsViewModel.applyFiltersAndSort()
                    }
            } else {
                TextField("Search tasks...", text: $tasksViewModel.searchText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .onChange(of: tasksViewModel.searchText) { _ in
                        tasksViewModel.applyFiltersAndSort()
                    }
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
        .padding(.horizontal, AppTheme.screenPadding)
    }
    
    private var projectsFiltersSection: some View {
        VStack(spacing: AppSpacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    FilterChip(
                        title: "All",
                        isSelected: projectsViewModel.selectedStatus == nil,
                        onTap: {
                            projectsViewModel.selectedStatus = nil
                            projectsViewModel.applyFiltersAndSort()
                        }
                    )
                    
                    ForEach(ProjectStatus.allCases, id: \.self) { status in
                        FilterChip(
                            title: status.rawValue,
                            isSelected: projectsViewModel.selectedStatus == status,
                            onTap: {
                                projectsViewModel.selectedStatus = status
                                projectsViewModel.applyFiltersAndSort()
                            }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    Text("Sort:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    ForEach(ProjectSortOption.allCases, id: \.self) { option in
                        FilterChip(
                            title: option.rawValue,
                            isSelected: projectsViewModel.sortOption == option,
                            onTap: {
                                projectsViewModel.sortOption = option
                                projectsViewModel.applyFiltersAndSort()
                            }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
            }
        }
        .padding(.vertical, AppSpacing.md)
        .background(
            LinearGradient(
                colors: [
                    AppColors.backgroundSecondary.opacity(0.8),
                    AppColors.backgroundSecondary.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var tasksFiltersSection: some View {
        VStack(spacing: AppSpacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    FilterChip(
                        title: "All",
                        isSelected: tasksViewModel.selectedStatus == nil,
                        onTap: {
                            tasksViewModel.selectedStatus = nil
                            tasksViewModel.applyFiltersAndSort()
                        }
                    )
                    
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        FilterChip(
                            title: status.rawValue,
                            isSelected: tasksViewModel.selectedStatus == status,
                            onTap: {
                                tasksViewModel.selectedStatus = status
                                tasksViewModel.applyFiltersAndSort()
                            }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    Text("Priority:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    FilterChip(
                        title: "All",
                        isSelected: tasksViewModel.selectedPriority == nil,
                        onTap: {
                            tasksViewModel.selectedPriority = nil
                            tasksViewModel.applyFiltersAndSort()
                        }
                    )
                    
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        FilterChip(
                            title: priority.rawValue,
                            isSelected: tasksViewModel.selectedPriority == priority,
                            onTap: {
                                tasksViewModel.selectedPriority = priority
                                tasksViewModel.applyFiltersAndSort()
                            }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    Text("Sort:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    ForEach(TaskSortOption.allCases, id: \.self) { option in
                        FilterChip(
                            title: option.rawValue,
                            isSelected: tasksViewModel.sortOption == option,
                            onTap: {
                                tasksViewModel.sortOption = option
                                tasksViewModel.applyFiltersAndSort()
                            }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
            }
        }
        .padding(.vertical, AppSpacing.md)
        .background(
            LinearGradient(
                colors: [
                    AppColors.backgroundSecondary.opacity(0.8),
                    AppColors.backgroundSecondary.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var projectsContent: some View {
        Group {
            if projectsViewModel.filteredProjects.isEmpty {
                EmptyStateView(
                    icon: "folder.badge.plus",
                    message: "No projects yet. Create your first project!"
                )
                .padding(.top, AppSpacing.xxl)
            } else {
                ForEach(projectsViewModel.filteredProjects) { project in
                    ProjectCard(
                        project: project,
                        progress: projectsViewModel.getProjectProgress(project),
                        taskCount: projectsViewModel.getTaskCount(for: project),
                        completedTaskCount: projectsViewModel.getCompletedTaskCount(for: project),
                        onTap: {
                            selectedProject = project
                        }
                    )
                    .contextMenu {
                        Button {
                            HapticsService.shared.impact(.light)
                            selectedProjectForEdit = project
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            HapticsService.shared.warning()
                            projectToDelete = project
                            showDeleteProjectAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    
    private var tasksContent: some View {
        Group {
            if tasksViewModel.filteredTasks.isEmpty {
                EmptyStateView(
                    icon: "checklist",
                    message: "No tasks yet. Create your first task!"
                )
                .padding(.top, AppSpacing.xxl)
            } else {
                ForEach(tasksViewModel.filteredTasks) { task in
                    TaskCard(
                        task: task,
                        projectName: tasksViewModel.getProjectName(for: task),
                        onComplete: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                tasksViewModel.completeTask(task)
                            }
                        },
                        onTap: {
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
                            showDeleteTaskAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}

