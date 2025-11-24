import Foundation

struct ProjectStats: Codable {
    var totalProjects: Int
    var activeProjects: Int
    var completedProjects: Int
    var onHoldProjects: Int
    var planningProjects: Int
    var totalTasks: Int
    var completedTasks: Int
    var overdueTasks: Int
    var upcomingDeadlinesCount: Int
    var tasksCompletedToday: Int
    var projectsUpdatedToday: Int

    init(
        totalProjects: Int = 0,
        activeProjects: Int = 0,
        completedProjects: Int = 0,
        onHoldProjects: Int = 0,
        planningProjects: Int = 0,
        totalTasks: Int = 0,
        completedTasks: Int = 0,
        overdueTasks: Int = 0,
        upcomingDeadlinesCount: Int = 0,
        tasksCompletedToday: Int = 0,
        projectsUpdatedToday: Int = 0
    ) {
        self.totalProjects = totalProjects
        self.activeProjects = activeProjects
        self.completedProjects = completedProjects
        self.onHoldProjects = onHoldProjects
        self.planningProjects = planningProjects
        self.totalTasks = totalTasks
        self.completedTasks = completedTasks
        self.overdueTasks = overdueTasks
        self.upcomingDeadlinesCount = upcomingDeadlinesCount
        self.tasksCompletedToday = tasksCompletedToday
        self.projectsUpdatedToday = projectsUpdatedToday
    }
}

struct Category: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var color: String
    var icon: String

    init(id: UUID = UUID(), name: String, color: String, icon: String) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
    }

    static let defaultCategories = [
        Category(name: "Work", color: "FF4500", icon: "briefcase.fill"),
        Category(name: "Personal", color: "00FF00", icon: "person.fill"),
        Category(name: "Learning", color: "FFD700", icon: "book.fill"),
        Category(name: "Hobby", color: "ADD8E6", icon: "star.fill")
    ]
}
