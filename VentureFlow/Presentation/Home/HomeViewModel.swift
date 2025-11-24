import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var stats: ProjectStats = ProjectStats()
    @Published var recentProjects: [Project] = []
    @Published var upcomingTasks: [Task] = []
    @Published var overdueTasks: [Task] = []

    private let projectService = ProjectService.shared
    private let taskService = TaskService.shared

    init() {
        // Subscribe to data change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dataDidChange),
            name: .dataDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func dataDidChange() {
        loadData()
    }

    func loadData() {
        stats = projectService.getProjectStats()
        recentProjects = projectService.getAllProjects()
            .sorted { $0.lastUpdated > $1.lastUpdated }
            .prefix(5)
            .map { $0 }
        // Load all tasks for correct count in alerts
        upcomingTasks = taskService.getTasksDueThisWeek()
        overdueTasks = taskService.getOverdueTasks()
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

    func getProjectName(for taskId: UUID) -> String {
        guard let task = taskService.getTask(by: taskId),
              let project = projectService.getProject(by: task.projectId) else {
            return "Unknown"
        }
        return project.name
    }
}
