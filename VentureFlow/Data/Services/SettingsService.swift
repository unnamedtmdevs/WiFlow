import Foundation

final class SettingsService {
    static let shared = SettingsService()
    private let storage = StorageService.shared
    
    private init() {}
    
    // Animations
    var animationsEnabled: Bool {
        get {
            UserDefaults.standard.object(forKey: UserDefaultsKeys.animationsEnabled) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.animationsEnabled)
        }
    }
    
    // Haptic Feedback
    var hapticFeedbackEnabled: Bool {
        get {
            UserDefaults.standard.object(forKey: UserDefaultsKeys.hapticFeedbackEnabled) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.hapticFeedbackEnabled)
        }
    }
    
    // Deadline Reminders
    var deadlineRemindersEnabled: Bool {
        get {
            UserDefaults.standard.object(forKey: UserDefaultsKeys.deadlineRemindersEnabled) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.deadlineRemindersEnabled)
        }
    }
}

