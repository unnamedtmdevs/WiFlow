import Foundation

final class RecurrenceService {
    static let shared = RecurrenceService()
    private let taskService = TaskService.shared
    private let calendar = Calendar.current
    
    private init() {}
    
    // Check and create recurring tasks
    func processRecurringTasks() {
        let allTasks = taskService.getAllTasks()
        
        for task in allTasks {
            guard let recurrence = task.recurrenceRule,
                  recurrence.isActive,
                  task.isCompleted else { continue }
            
            // Check if we need to create next occurrence
            if let deadline = task.deadline {
                let nextDeadline = recurrence.nextOccurrence(from: deadline)
                
                if let nextDeadline = nextDeadline {
                    // Check if next occurrence already exists
                    let existingTasks = taskService.getTasksForProject(task.projectId)
                    let originalTaskId = task.originalTaskId ?? task.id
                    
                    let hasNextOccurrence = existingTasks.contains { existingTask in
                        existingTask.originalTaskId == originalTaskId &&
                        existingTask.deadline == nextDeadline &&
                        !existingTask.isCompleted
                    }
                    
                    if !hasNextOccurrence && (recurrence.endDate == nil || nextDeadline <= recurrence.endDate!) {
                        createNextRecurrence(of: task, withDeadline: nextDeadline, originalTaskId: originalTaskId)
                    }
                }
            }
        }
    }
    
    private func createNextRecurrence(of task: Task, withDeadline deadline: Date, originalTaskId: UUID) {
        // Create new task with new ID
        let newTask = Task(
            id: UUID(),
            name: task.name,
            description: task.description,
            projectId: task.projectId,
            status: .toDo,
            priority: task.priority,
            deadline: deadline,
            notes: task.notes,
            subtasks: task.subtasks.map { subtask in
                Subtask(
                    id: UUID(),
                    name: subtask.name,
                    isCompleted: false
                )
            },
            createdDate: Date(),
            recurrenceRule: task.recurrenceRule,
            originalTaskId: originalTaskId,
            startTrackingDate: nil
        )
        
        taskService.createTask(newTask)
    }
    
    // Check for recurring tasks that need to be created (called on app launch or periodically)
    func checkAndCreateRecurringTasks() {
        let allTasks = taskService.getAllTasks()
        let now = calendar.startOfDay(for: Date())
        
        for task in allTasks {
            guard let recurrence = task.recurrenceRule,
                  recurrence.isActive,
                  !task.isCompleted else { continue }
            
            // For tasks without deadline, check based on completion date
            if task.deadline == nil {
                // Check if task should have been created today based on recurrence
                if let lastCompletedDate = getLastCompletedDate(for: task) {
                    if let nextDate = recurrence.nextOccurrence(from: lastCompletedDate) {
                        if calendar.isDate(nextDate, inSameDayAs: now) {
                            // Create the task instance for today
                            createTaskInstance(for: task, on: now)
                        }
                    }
                }
            }
        }
    }
    
    private func getLastCompletedDate(for task: Task) -> Date? {
        let history = HistoryService.shared.getHistory(for: .task)
        let originalTaskId = task.originalTaskId ?? task.id
        return history.first { $0.itemId == originalTaskId }?.completedDate
    }
    
    private func createTaskInstance(for task: Task, on date: Date) {
        // Create new task instance with new ID
        let newTask = Task(
            id: UUID(),
            name: task.name,
            description: task.description,
            projectId: task.projectId,
            status: task.status,
            priority: task.priority,
            deadline: task.deadline,
            notes: task.notes,
            subtasks: task.subtasks.map { subtask in
                Subtask(
                    id: UUID(),
                    name: subtask.name,
                    isCompleted: false
                )
            },
            createdDate: date,
            recurrenceRule: task.recurrenceRule,
            originalTaskId: task.originalTaskId ?? task.id,
            startTrackingDate: date
        )
        
        taskService.createTask(newTask)
    }
}

