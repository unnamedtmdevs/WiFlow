import Foundation

final class ProjectService {
    static let shared = ProjectService()
    private let storage = StorageService.shared

    private init() {}

    func getAllProjects() -> [Project] {
        storage.loadArray(Project.self, forKey: UserDefaultsKeys.projects)
    }

    func getProject(by id: UUID) -> Project? {
        getAllProjects().first(where: { $0.id == id })
    }

    func createProject(_ project: Project) {
        var projects = getAllProjects()
        projects.append(project)
        storage.saveArray(projects, forKey: UserDefaultsKeys.projects)

        let totalCreated = storage.load(Int.self, forKey: UserDefaultsKeys.totalProjectsCreated) ?? 0
        storage.save(totalCreated + 1, forKey: UserDefaultsKeys.totalProjectsCreated)
        
        // Schedule deadline reminder
        if project.deadline != nil {
            NotificationService.shared.scheduleProjectDeadlineReminder(for: project)
        }
        
        NotificationCenter.default.post(name: .projectsDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }

    func updateProject(_ updatedProject: Project) {
        var projects = getAllProjects()
        if let index = projects.firstIndex(where: { $0.id == updatedProject.id }) {
            let oldProject = projects[index]
            var project = updatedProject
            project.lastUpdated = Date()
            projects[index] = project
            storage.saveArray(projects, forKey: UserDefaultsKeys.projects)
            
            // Cancel old reminder
            NotificationService.shared.cancelNotification(for: project.id)
            
            // If project was just completed, save to history
            if project.status == .completed && oldProject.status != .completed {
                HistoryService.shared.saveProjectToHistory(project)
            } else {
                // Schedule new reminder if deadline changed or project is not completed
                if project.deadline != nil && project.status != .completed {
                    NotificationService.shared.scheduleProjectDeadlineReminder(for: project)
                }
            }
            
            NotificationCenter.default.post(name: .projectsDidChange, object: nil)
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
        }
    }

    func deleteProject(_ project: Project) {
        var projects = getAllProjects()
        projects.removeAll(where: { $0.id == project.id })
        storage.saveArray(projects, forKey: UserDefaultsKeys.projects)

        TaskService.shared.deleteTasksForProject(project.id)
        MilestoneService.shared.deleteMilestonesForProject(project.id)
        ResourceService.shared.deleteResourcesForProject(project.id)
        
        // Cancel reminder on deletion
        NotificationService.shared.cancelNotification(for: project.id)
        
        NotificationCenter.default.post(name: .projectsDidChange, object: nil)
        NotificationCenter.default.post(name: .tasksDidChange, object: nil)
        NotificationCenter.default.post(name: .resourcesDidChange, object: nil)
        NotificationCenter.default.post(name: .milestonesDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }

    func calculateProgress(for project: Project) -> Double {
        let tasks = TaskService.shared.getTasksForProject(project.id)
        guard !tasks.isEmpty else { return 0 }

        let completedTasks = tasks.filter { $0.isCompleted }.count
        return Double(completedTasks) / Double(tasks.count) * 100
    }

    func getProjectStats() -> ProjectStats {
        let projects = getAllProjects()
        let tasks = TaskService.shared.getAllTasks()

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekLater = calendar.date(byAdding: .day, value: 7, to: today) ?? today

        let activeProjects = projects.filter { $0.status == .inProgress }.count
        let completedProjects = projects.filter { $0.status == .completed }.count
        let onHoldProjects = projects.filter { $0.status == .onHold }.count
        let planningProjects = projects.filter { $0.status == .planning }.count

        let completedTasks = tasks.filter { $0.isCompleted }.count
        let overdueTasks = tasks.filter { $0.isOverdue }.count

        let upcomingDeadlines = tasks.filter { task in
            guard let deadline = task.deadline, !task.isCompleted else { return false }
            return deadline >= today && deadline <= weekLater
        }.count

        let tasksCompletedToday = tasks.filter { task in
            task.isCompleted && calendar.isDateInToday(task.createdDate)
        }.count

        let projectsUpdatedToday = projects.filter {
            calendar.isDateInToday($0.lastUpdated)
        }.count

        return ProjectStats(
            totalProjects: projects.count,
            activeProjects: activeProjects,
            completedProjects: completedProjects,
            onHoldProjects: onHoldProjects,
            planningProjects: planningProjects,
            totalTasks: tasks.count,
            completedTasks: completedTasks,
            overdueTasks: overdueTasks,
            upcomingDeadlinesCount: upcomingDeadlines,
            tasksCompletedToday: tasksCompletedToday,
            projectsUpdatedToday: projectsUpdatedToday
        )
    }

    func getFilteredProjects(status: ProjectStatus? = nil, category: String? = nil, searchText: String = "") -> [Project] {
        var projects = getAllProjects()

        if let status = status {
            projects = projects.filter { $0.status == status }
        }

        if let category = category {
            projects = projects.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            projects = projects.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        return projects
    }

    func sortProjects(_ projects: [Project], by sortOption: ProjectSortOption) -> [Project] {
        switch sortOption {
        case .deadline:
            return projects.sorted { proj1, proj2 in
                guard let d1 = proj1.deadline else { return false }
                guard let d2 = proj2.deadline else { return true }
                return d1 < d2
            }
        case .creationDate:
            return projects.sorted { $0.createdDate > $1.createdDate }
        case .progress:
            return projects.sorted { calculateProgress(for: $0) > calculateProgress(for: $1) }
        case .status:
            return projects.sorted { $0.status.rawValue < $1.status.rawValue }
        case .alphabetical:
            return projects.sorted { $0.name < $1.name }
        case .priority:
            let priorityOrder: [ProjectPriority] = [.high, .medium, .low]
            return projects.sorted { proj1, proj2 in
                let index1 = priorityOrder.firstIndex(of: proj1.priority) ?? 0
                let index2 = priorityOrder.firstIndex(of: proj2.priority) ?? 0
                return index1 < index2
            }
        }
    }
}

enum ProjectSortOption: String, CaseIterable {
    case deadline = "Deadline"
    case creationDate = "Creation Date"
    case progress = "Progress"
    case status = "Status"
    case alphabetical = "Alphabetical"
    case priority = "Priority"
}
