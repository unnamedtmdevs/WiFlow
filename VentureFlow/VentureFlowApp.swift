import SwiftUI

@main
struct VentureFlowApp: App {
    init() {
        setupNavigationBarAppearance()
        NotificationService.shared.requestAuthorization { granted in
            if granted {
                // Sync all reminders after authorization
                NotificationService.shared.syncAllReminders()
            }
        }
        // Check for recurring tasks on app launch
        RecurrenceService.shared.checkAndCreateRecurringTasks()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }

    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
