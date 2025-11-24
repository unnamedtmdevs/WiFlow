import SwiftUI

struct ProjectsView: View {
    @StateObject private var viewModel = ProjectsViewModel()
    @State private var showCreateProject = false
    @State private var selectedProject: Project?
    @State private var selectedProjectForEdit: Project?
    @State private var showFilters = false

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

                if showFilters {
                    filtersSection
                }

                ScrollView {
                    VStack(spacing: AppSpacing.md) {
                        if viewModel.filteredProjects.isEmpty {
                            EmptyStateView(
                                icon: "folder.badge.plus",
                                message: "No projects yet. Create your first project!"
                            )
                            .padding(.top, AppSpacing.xxl)
                        } else {
                            ForEach(viewModel.filteredProjects) { project in
                                ProjectCard(
                                    project: project,
                                    progress: viewModel.getProjectProgress(project),
                                    taskCount: viewModel.getTaskCount(for: project),
                                    completedTaskCount: viewModel.getCompletedTaskCount(for: project),
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
                                        viewModel.deleteProject(project)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }

                        Spacer(minLength: AppSpacing.xl)
                    }
                    .padding(AppTheme.screenPadding)
                }
            }
        }
        .onAppear {
            viewModel.loadProjects()
        }
        .sheet(isPresented: $showCreateProject) {
            CreateProjectView(onSave: {
                viewModel.loadProjects()
            })
        }
        .sheet(item: $selectedProject) { project in
            ProjectDetailView(project: project, onUpdate: {
                viewModel.loadProjects()
            })
        }
        .sheet(item: $selectedProjectForEdit) { project in
            EditProjectView(project: project, onSave: {
                viewModel.loadProjects()
            })
        }
    }

    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("My Projects")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()

                HStack(spacing: AppSpacing.sm) {
                    Button(action: {
                        HapticsService.shared.impact(.light)
                        showFilters.toggle()
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
                            
                            Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        }
                    }

                    Button(action: {
                        HapticsService.shared.impact()
                        showCreateProject = true
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

            TextField("Search projects...", text: $viewModel.searchText)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.applyFiltersAndSort()
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

    private var filtersSection: some View {
        VStack(spacing: AppSpacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    FilterChip(
                        title: "All",
                        isSelected: viewModel.selectedStatus == nil,
                        onTap: {
                            viewModel.selectedStatus = nil
                            viewModel.applyFiltersAndSort()
                        }
                    )

                    ForEach(ProjectStatus.allCases, id: \.self) { status in
                        FilterChip(
                            title: status.rawValue,
                            isSelected: viewModel.selectedStatus == status,
                            onTap: {
                                viewModel.selectedStatus = status
                                viewModel.applyFiltersAndSort()
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
                            isSelected: viewModel.sortOption == option,
                            onTap: {
                                viewModel.sortOption = option
                                viewModel.applyFiltersAndSort()
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
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            onTap()
        }) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? AppColors.background : AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            LinearGradient(
                                colors: [AppColors.background, AppColors.background],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Color.clear : AppColors.primary.opacity(0.2),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isSelected ? AppColors.primary.opacity(0.3) : Color.clear,
                    radius: isSelected ? 8 : 0,
                    x: 0,
                    y: isSelected ? 4 : 0
                )
        }
    }
}
