import SwiftUI

struct TasksView: View {
    @StateObject private var viewModel = TasksViewModel()
    @State private var showFilters = false
    @State private var showCreateTask = false
    @State private var selectedTaskForEdit: Task?

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            // Decorative element
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(AppColors.darkGreen.opacity(0.08))
                        .frame(width: 150, height: 150)
                        .blur(radius: 40)
                        .offset(x: 50, y: 80)
                }
            }

            VStack(spacing: 0) {
                headerSection

                if showFilters {
                    filtersSection
                }

                ScrollView {
                    VStack(spacing: AppSpacing.md) {
                        if viewModel.filteredTasks.isEmpty {
                            EmptyStateView(
                                icon: "checklist",
                                message: "No tasks yet. Create your first task!"
                            )
                            .padding(.top, AppSpacing.xxl)
                        } else {
                            ForEach(viewModel.filteredTasks) { task in
                                TaskCard(
                                    task: task,
                                    projectName: viewModel.getProjectName(for: task),
                                    onComplete: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            viewModel.completeTask(task)
                                        }
                                    },
                                    onTap: {
                                    }
                                )
                                .contextMenu {
                                    Button {
                                        HapticsService.shared.impact(.light)
                                        selectedTaskForEdit = task
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        HapticsService.shared.warning()
                                        viewModel.deleteTask(task)
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
            viewModel.loadTasks()
        }
        .sheet(isPresented: $showCreateTask) {
            CreateTaskView(onSave: {
                viewModel.loadTasks()
            })
        }
        .sheet(item: $selectedTaskForEdit) { task in
            EditTaskView(task: task, onSave: {
                viewModel.loadTasks()
            })
        }
    }

    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("My Tasks")
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
                        showCreateTask = true
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

            TextField("Search tasks...", text: $viewModel.searchText)
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

                    ForEach(TaskStatus.allCases, id: \.self) { status in
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
                    Text("Priority:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)

                    FilterChip(
                        title: "All",
                        isSelected: viewModel.selectedPriority == nil,
                        onTap: {
                            viewModel.selectedPriority = nil
                            viewModel.applyFiltersAndSort()
                        }
                    )

                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        FilterChip(
                            title: priority.rawValue,
                            isSelected: viewModel.selectedPriority == priority,
                            onTap: {
                                viewModel.selectedPriority = priority
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

                    ForEach(TaskSortOption.allCases, id: \.self) { option in
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
