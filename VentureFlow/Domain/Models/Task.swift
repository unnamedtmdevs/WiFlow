import Foundation

enum TaskStatus: String, Codable, CaseIterable {
    case toDo = "To Do"
    case inProgress = "In Progress"
    case completed = "Completed"
}

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var projectId: UUID
    var status: TaskStatus
    var priority: TaskPriority
    var deadline: Date?
    var notes: String
    var subtasks: [Subtask]
    var createdDate: Date
    var recurrenceRule: RecurrenceRule?
    var originalTaskId: UUID? // ID of the original recurring task
    var startTrackingDate: Date? // When task tracking started (for completion time)

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        projectId: UUID,
        status: TaskStatus = .toDo,
        priority: TaskPriority = .medium,
        deadline: Date? = nil,
        notes: String = "",
        subtasks: [Subtask] = [],
        createdDate: Date = Date(),
        recurrenceRule: RecurrenceRule? = nil,
        originalTaskId: UUID? = nil,
        startTrackingDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.projectId = projectId
        self.status = status
        self.priority = priority
        self.deadline = deadline
        self.notes = notes
        self.subtasks = subtasks
        self.createdDate = createdDate
        self.recurrenceRule = recurrenceRule
        self.originalTaskId = originalTaskId
        self.startTrackingDate = startTrackingDate
    }

    var isCompleted: Bool {
        status == .completed
    }

    var isOverdue: Bool {
        guard let deadline = deadline, !isCompleted else { return false }
        return deadline < Date()
    }

    var daysUntilDeadline: Int? {
        guard let deadline = deadline else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: deadline).day
    }
}

struct Subtask: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var isCompleted: Bool

    init(id: UUID = UUID(), name: String, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
    }
}
