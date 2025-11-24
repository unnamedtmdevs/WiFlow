import Foundation

enum ProjectStatus: String, Codable, CaseIterable {
    case planning = "Planning"
    case inProgress = "In Progress"
    case onHold = "On Hold"
    case completed = "Completed"
}

enum ProjectPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct Project: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    var status: ProjectStatus
    var priority: ProjectPriority
    var category: String
    var tags: [String]
    var startDate: Date
    var deadline: Date?
    var notes: String
    var taskIds: [UUID]
    var milestoneIds: [UUID]
    var resourceIds: [UUID]
    var createdDate: Date
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        status: ProjectStatus = .planning,
        priority: ProjectPriority = .medium,
        category: String = "Personal",
        tags: [String] = [],
        startDate: Date = Date(),
        deadline: Date? = nil,
        notes: String = "",
        taskIds: [UUID] = [],
        milestoneIds: [UUID] = [],
        resourceIds: [UUID] = [],
        createdDate: Date = Date(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.status = status
        self.priority = priority
        self.category = category
        self.tags = tags
        self.startDate = startDate
        self.deadline = deadline
        self.notes = notes
        self.taskIds = taskIds
        self.milestoneIds = milestoneIds
        self.resourceIds = resourceIds
        self.createdDate = createdDate
        self.lastUpdated = lastUpdated
    }
}
