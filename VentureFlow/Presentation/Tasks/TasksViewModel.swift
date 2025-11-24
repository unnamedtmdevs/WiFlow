import Foundation
import SwiftUI

@MainActor
final class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var filteredTasks: [Task] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: TaskStatus?
    @Published var selectedPriority: TaskPriority?
    @Published var sortOption: TaskSortOption = .deadline
    @Published var showFilters: Bool = false

    private let taskService = TaskService.shared
    private let projectService = ProjectService.shared

    init() {
        // Subscribe to task change notifications
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
    
    @objc private func tasksDidChange() {
        loadTasks()
    }

    func loadTasks() {
        tasks = taskService.getAllTasks()
        applyFiltersAndSort()
    }

    func applyFiltersAndSort() {
        filteredTasks = taskService.getFilteredTasks(
            status: selectedStatus,
            priority: selectedPriority,
            searchText: searchText
        )
        filteredTasks = taskService.sortTasks(filteredTasks, by: sortOption)
    }

    func completeTask(_ task: Task) {
        var updatedTask = task
        // Toggle completion status
        if task.isCompleted {
            updatedTask.status = .toDo
        } else {
            updatedTask.status = .completed
        }
        taskService.updateTask(updatedTask)
        loadTasks()
    }

    func deleteTask(_ task: Task) {
        taskService.deleteTask(task)
        loadTasks()
    }

    func getProjectName(for task: Task) -> String {
        projectService.getProject(by: task.projectId)?.name ?? "Unknown"
    }
}
