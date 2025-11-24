import Foundation

enum UserDefaultsKeys {
    static let hasSeenOnboarding = "hasSeenOnboarding"
    static let projects = "projects"
    static let tasks = "tasks"
    static let milestones = "milestones"
    static let resources = "resources"
    static let categories = "categories"
    static let defaultPriority = "defaultPriority"
    static let defaultCategory = "defaultCategory"
    static let deadlineRemindersEnabled = "deadlineRemindersEnabled"
    static let reminderFrequency = "reminderFrequency"
    static let reminderTime = "reminderTime"
    static let totalProjectsCreated = "totalProjectsCreated"
    static let totalTasksCompleted = "totalTasksCompleted"
    static let dateFormat = "dateFormat"
    static let animationsEnabled = "animationsEnabled"
    static let hapticFeedbackEnabled = "hapticFeedbackEnabled"
    static let history = "history"
}

final class StorageService {
    static let shared = StorageService()
    private let defaults = UserDefaults.standard

    private init() {}

    func save<T: Codable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            defaults.set(encoded, forKey: key)
        }
    }

    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func saveArray<T: Codable>(_ array: [T], forKey key: String) {
        if let encoded = try? JSONEncoder().encode(array) {
            defaults.set(encoded, forKey: key)
        }
    }

    func loadArray<T: Codable>(_ type: T.Type, forKey key: String) -> [T] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([T].self, from: data)) ?? []
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    func clearAll() {
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }

    func exportToJSON() -> String? {
        let exportData: [String: Any] = [
            "projects": loadArray(Project.self, forKey: UserDefaultsKeys.projects),
            "tasks": loadArray(Task.self, forKey: UserDefaultsKeys.tasks),
            "milestones": loadArray(Milestone.self, forKey: UserDefaultsKeys.milestones),
            "resources": loadArray(Resource.self, forKey: UserDefaultsKeys.resources),
            "categories": loadArray(Category.self, forKey: UserDefaultsKeys.categories)
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
