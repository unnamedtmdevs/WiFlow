import Foundation

enum HistoryItemType: String, Codable {
    case task = "Task"
    case project = "Project"
}

struct HistoryItem: Identifiable, Codable, Equatable {
    let id: UUID
    let type: HistoryItemType
    let itemId: UUID // ID of the original task or project
    let name: String
    let description: String
    let projectId: UUID? // For tasks
    let projectName: String? // For tasks
    let completedDate: Date
    let completionTime: TimeInterval? // Time taken to complete (if tracked)
    let metadata: [String: String] // Additional metadata (priority, category, etc.)
    
    init(
        id: UUID = UUID(),
        type: HistoryItemType,
        itemId: UUID,
        name: String,
        description: String = "",
        projectId: UUID? = nil,
        projectName: String? = nil,
        completedDate: Date = Date(),
        completionTime: TimeInterval? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.itemId = itemId
        self.name = name
        self.description = description
        self.projectId = projectId
        self.projectName = projectName
        self.completedDate = completedDate
        self.completionTime = completionTime
        self.metadata = metadata
    }
    
    // Computed properties for easy access
    var priority: String? {
        metadata["priority"]
    }
    
    var category: String? {
        metadata["category"]
    }
    
    var status: String? {
        metadata["status"]
    }
}

