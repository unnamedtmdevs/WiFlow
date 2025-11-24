import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleDeadlineReminder(for task: Task) {
        // Check if reminders are enabled
        guard SettingsService.shared.deadlineRemindersEnabled else { return }
        
        // Don't schedule for completed tasks
        guard !task.isCompleted else { return }
        
        guard let deadline = task.deadline else { return }
        
        // Check if deadline is in the future
        guard deadline > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Deadline"
        content.body = "Task '\(task.name)' is due soon"
        content.sound = .default

        let reminderDate = Calendar.current.date(byAdding: .hour, value: -24, to: deadline) ?? deadline
        
        // Check if reminder is not in the past
        guard reminderDate > Date() else { return }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleProjectDeadlineReminder(for project: Project) {
        // Check if reminders are enabled
        guard SettingsService.shared.deadlineRemindersEnabled else { return }
        
        // Don't schedule for completed projects
        guard project.status != .completed else { return }
        
        guard let deadline = project.deadline else { return }
        
        // Check if deadline is in the future
        guard deadline > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Project Deadline"
        content.body = "Project '\(project.name)' is due soon"
        content.sound = .default

        let reminderDate = Calendar.current.date(byAdding: .day, value: -3, to: deadline) ?? deadline
        
        // Check if reminder is not in the past
        guard reminderDate > Date() else { return }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: project.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleMilestoneReminder(for milestone: Milestone) {
        let content = UNMutableNotificationContent()
        content.title = "Milestone Approaching"
        content.body = "Milestone '\(milestone.name)' is approaching"
        content.sound = .default

        let reminderDate = Calendar.current.date(byAdding: .day, value: -2, to: milestone.targetDate) ?? milestone.targetDate
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: milestone.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(for id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
    
    // Sync all reminders for existing tasks and projects
    func syncAllReminders() {
        guard SettingsService.shared.deadlineRemindersEnabled else { return }
        
        // Sync reminders for all tasks
        let tasks = TaskService.shared.getAllTasks()
        for task in tasks {
            if task.deadline != nil && !task.isCompleted {
                scheduleDeadlineReminder(for: task)
            }
        }
        
        // Sync reminders for all projects
        let projects = ProjectService.shared.getAllProjects()
        for project in projects {
            if project.deadline != nil && project.status != .completed {
                scheduleProjectDeadlineReminder(for: project)
            }
        }
    }
}
