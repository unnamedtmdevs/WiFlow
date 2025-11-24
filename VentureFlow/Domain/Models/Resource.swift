import Foundation

enum ResourceType: String, Codable, CaseIterable {
    case file = "File"
    case link = "Link"
    case note = "Note"
    case picture = "Picture"
}

struct Resource: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var type: ResourceType
    var projectId: UUID
    var content: String
    var notes: String
    var createdDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        type: ResourceType,
        projectId: UUID,
        content: String,
        notes: String = "",
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.projectId = projectId
        self.content = content
        self.notes = notes
        self.createdDate = createdDate
    }
}
