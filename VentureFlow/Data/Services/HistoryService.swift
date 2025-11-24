import Foundation

final class HistoryService {
    static let shared = HistoryService()
    private let storage = StorageService.shared
    
    private init() {}
    
    func getAllHistory() -> [HistoryItem] {
        storage.loadArray(HistoryItem.self, forKey: UserDefaultsKeys.history)
    }
    
    func getHistory(for type: HistoryItemType? = nil, limit: Int? = nil) -> [HistoryItem] {
        var items = getAllHistory()
        
        if let type = type {
            items = items.filter { $0.type == type }
        }
        
        // Sort by completion date (newest first)
        items.sort { $0.completedDate > $1.completedDate }
        
        if let limit = limit {
            return Array(items.prefix(limit))
        }
        
        return items
    }
    
    func getHistoryForProject(_ projectId: UUID) -> [HistoryItem] {
        getAllHistory().filter { $0.projectId == projectId }
    }
    
    func getHistoryForDateRange(from startDate: Date, to endDate: Date) -> [HistoryItem] {
        getAllHistory().filter { item in
            item.completedDate >= startDate && item.completedDate <= endDate
        }
    }
    
    func addToHistory(_ item: HistoryItem) {
        var history = getAllHistory()
        history.insert(item, at: 0) // Add to beginning (newest first)
        
        // Limit history to last 1000 items to prevent storage issues
        if history.count > 1000 {
            history = Array(history.prefix(1000))
        }
        
        storage.saveArray(history, forKey: UserDefaultsKeys.history)
        
        NotificationCenter.default.post(name: .historyDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }
    
    func saveTaskToHistory(_ task: Task, projectName: String?) {
        let completionTime: TimeInterval?
        if let startDate = task.startTrackingDate {
            completionTime = Date().timeIntervalSince(startDate)
        } else {
            completionTime = nil
        }
        
        let metadata: [String: String] = [
            "priority": task.priority.rawValue,
            "status": task.status.rawValue
        ]
        
        let historyItem = HistoryItem(
            type: .task,
            itemId: task.id,
            name: task.name,
            description: task.description,
            projectId: task.projectId,
            projectName: projectName,
            completedDate: Date(),
            completionTime: completionTime,
            metadata: metadata
        )
        
        addToHistory(historyItem)
    }
    
    func saveProjectToHistory(_ project: Project) {
        let metadata: [String: String] = [
            "priority": project.priority.rawValue,
            "status": project.status.rawValue,
            "category": project.category
        ]
        
        let historyItem = HistoryItem(
            type: .project,
            itemId: project.id,
            name: project.name,
            description: project.description,
            completedDate: Date(),
            metadata: metadata
        )
        
        addToHistory(historyItem)
    }
    
    func deleteHistoryItem(_ item: HistoryItem) {
        var history = getAllHistory()
        history.removeAll(where: { $0.id == item.id })
        storage.saveArray(history, forKey: UserDefaultsKeys.history)
        
        NotificationCenter.default.post(name: .historyDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }
    
    func clearHistory() {
        storage.remove(forKey: UserDefaultsKeys.history)
        NotificationCenter.default.post(name: .historyDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }
    
    func getStatistics() -> (totalCompleted: Int, tasksCompleted: Int, projectsCompleted: Int, thisWeek: Int, thisMonth: Int) {
        let history = getAllHistory()
        let tasksCompleted = history.filter { $0.type == .task }.count
        let projectsCompleted = history.filter { $0.type == .project }.count
        
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        
        let thisWeek = history.filter { $0.completedDate >= weekStart }.count
        let thisMonth = history.filter { $0.completedDate >= monthStart }.count
        
        return (
            totalCompleted: history.count,
            tasksCompleted: tasksCompleted,
            projectsCompleted: projectsCompleted,
            thisWeek: thisWeek,
            thisMonth: thisMonth
        )
    }
}

