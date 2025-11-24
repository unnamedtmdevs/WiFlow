import Foundation
import SwiftUI

@MainActor
final class ProjectsViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var filteredProjects: [Project] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: ProjectStatus?
    @Published var selectedCategory: String?
    @Published var sortOption: ProjectSortOption = .deadline
    @Published var showFilters: Bool = false

    private let projectService = ProjectService.shared
    private let taskService = TaskService.shared

    init() {
        // Subscribe to project and task change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(projectsDidChange),
            name: .projectsDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tasksDidChange),
            name: .tasksDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func projectsDidChange() {
        loadProjects()
    }
    
    @objc private func tasksDidChange() {
        loadProjects()
    }

    func loadProjects() {
        projects = projectService.getAllProjects()
        applyFiltersAndSort()
    }

    func applyFiltersAndSort() {
        filteredProjects = projectService.getFilteredProjects(
            status: selectedStatus,
            category: selectedCategory,
            searchText: searchText
        )
        filteredProjects = projectService.sortProjects(filteredProjects, by: sortOption)
    }

    func deleteProject(_ project: Project) {
        projectService.deleteProject(project)
        loadProjects()
    }

    func getProjectProgress(_ project: Project) -> Double {
        projectService.calculateProgress(for: project)
    }

    func getTaskCount(for project: Project) -> Int {
        taskService.getTasksForProject(project.id).count
    }

    func getCompletedTaskCount(for project: Project) -> Int {
        taskService.getTasksForProject(project.id).filter { $0.isCompleted }.count
    }
}
