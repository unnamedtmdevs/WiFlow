import Foundation

final class TaskService {
    static let shared = TaskService()
    private let storage = StorageService.shared

    private init() {}

    func getAllTasks() -> [Task] {
        storage.loadArray(Task.self, forKey: UserDefaultsKeys.tasks)
    }

    func getTask(by id: UUID) -> Task? {
        getAllTasks().first(where: { $0.id == id })
    }

    func getTasksForProject(_ projectId: UUID) -> [Task] {
        getAllTasks().filter { $0.projectId == projectId }
    }

    func createTask(_ task: Task) {
        var tasks = getAllTasks()
        tasks.append(task)
        storage.saveArray(tasks, forKey: UserDefaultsKeys.tasks)
        
        // Schedule deadline reminder
        if task.deadline != nil {
            NotificationService.shared.scheduleDeadlineReminder(for: task)
        }
        
        NotificationCenter.default.post(name: .tasksDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }

    func updateTask(_ updatedTask: Task) {
        var tasks = getAllTasks()
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            let oldTask = tasks[index]
            tasks[index] = updatedTask
            storage.saveArray(tasks, forKey: UserDefaultsKeys.tasks)

            // Cancel old reminder
            NotificationService.shared.cancelNotification(for: updatedTask.id)
            
            // If task was just completed, save to history and process recurrence
            if updatedTask.isCompleted && !oldTask.isCompleted {
                let totalCompleted = storage.load(Int.self, forKey: UserDefaultsKeys.totalTasksCompleted) ?? 0
                storage.save(totalCompleted + 1, forKey: UserDefaultsKeys.totalTasksCompleted)
                
                // Save to history
                let projectName = ProjectService.shared.getProject(by: updatedTask.projectId)?.name
                HistoryService.shared.saveTaskToHistory(updatedTask, projectName: projectName)
                
                // Process recurring task if needed
                if updatedTask.recurrenceRule?.isActive == true {
                    RecurrenceService.shared.processRecurringTasks()
                }
            } else {
                // Schedule new reminder if deadline changed or task is not completed
                if updatedTask.deadline != nil && !updatedTask.isCompleted {
                    NotificationService.shared.scheduleDeadlineReminder(for: updatedTask)
                }
            }
            
            NotificationCenter.default.post(name: .tasksDidChange, object: nil)
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
        }
    }

    func deleteTask(_ task: Task) {
        var tasks = getAllTasks()
        tasks.removeAll(where: { $0.id == task.id })
        storage.saveArray(tasks, forKey: UserDefaultsKeys.tasks)
        
        // Cancel reminder on deletion
        NotificationService.shared.cancelNotification(for: task.id)
        
        NotificationCenter.default.post(name: .tasksDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }

    func deleteTasksForProject(_ projectId: UUID) {
        var tasks = getAllTasks()
        tasks.removeAll(where: { $0.projectId == projectId })
        storage.saveArray(tasks, forKey: UserDefaultsKeys.tasks)
        
        NotificationCenter.default.post(name: .tasksDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }

    func completeTask(_ task: Task) {
        var updatedTask = task
        updatedTask.status = .completed
        updateTask(updatedTask)
    }

    func getFilteredTasks(
        status: TaskStatus? = nil,
        priority: TaskPriority? = nil,
        projectId: UUID? = nil,
        searchText: String = ""
    ) -> [Task] {
        var tasks = getAllTasks()

        if let status = status {
            tasks = tasks.filter { $0.status == status }
        }

        if let priority = priority {
            tasks = tasks.filter { $0.priority == priority }
        }

        if let projectId = projectId {
            tasks = tasks.filter { $0.projectId == projectId }
        }

        if !searchText.isEmpty {
            tasks = tasks.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return tasks
    }

    func sortTasks(_ tasks: [Task], by sortOption: TaskSortOption) -> [Task] {
        switch sortOption {
        case .deadline:
            return tasks.sorted { task1, task2 in
                guard let d1 = task1.deadline else { return false }
                guard let d2 = task2.deadline else { return true }
                return d1 < d2
            }
        case .priority:
            let priorityOrder: [TaskPriority] = [.high, .medium, .low]
            return tasks.sorted { task1, task2 in
                let index1 = priorityOrder.firstIndex(of: task1.priority) ?? 0
                let index2 = priorityOrder.firstIndex(of: task2.priority) ?? 0
                return index1 < index2
            }
        case .alphabetical:
            return tasks.sorted { $0.name < $1.name }
        case .creationDate:
            return tasks.sorted { $0.createdDate > $1.createdDate }
        }
    }

    func getOverdueTasks() -> [Task] {
        getAllTasks().filter { $0.isOverdue }
    }

    func getTasksDueToday() -> [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return getAllTasks().filter { task in
            guard let deadline = task.deadline, !task.isCompleted else { return false }
            return calendar.isDate(deadline, inSameDayAs: today)
        }
    }

    func getTasksDueThisWeek() -> [Task] {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let weekLater = calendar.date(byAdding: .day, value: 7, to: today) ?? today

        return getAllTasks().filter { task in
            guard let deadline = task.deadline, !task.isCompleted else { return false }
            // Exclude overdue tasks (they should be in overdue)
            guard deadline >= now else { return false }
            // Check if deadline is within the week
            return deadline >= today && deadline <= weekLater
        }
    }
}

enum TaskSortOption: String, CaseIterable {
    case deadline = "Deadline"
    case priority = "Priority"
    case alphabetical = "Alphabetical"
    case creationDate = "Creation Date"
}
