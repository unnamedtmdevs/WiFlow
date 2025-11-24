import Foundation

enum MilestoneStatus: String, Codable, CaseIterable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
}

struct Milestone: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var projectId: UUID
    var targetDate: Date
    var status: MilestoneStatus
    var associatedTaskIds: [UUID]
    var notes: String
    var createdDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        projectId: UUID,
        targetDate: Date,
        status: MilestoneStatus = .notStarted,
        associatedTaskIds: [UUID] = [],
        notes: String = "",
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.projectId = projectId
        self.targetDate = targetDate
        self.status = status
        self.associatedTaskIds = associatedTaskIds
        self.notes = notes
        self.createdDate = createdDate
    }

    var isCompleted: Bool {
        status == .completed
    }

    var isOverdue: Bool {
        guard !isCompleted else { return false }
        return targetDate < Date()
    }
}
