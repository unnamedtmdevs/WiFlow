import Foundation

enum RecurrenceFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case none = "None"
    
    var description: String {
        switch self {
        case .daily: return "Every day"
        case .weekly: return "Every week"
        case .monthly: return "Every month"
        case .yearly: return "Every year"
        case .none: return "No repetition"
        }
    }
}

struct RecurrenceRule: Codable, Equatable {
    var frequency: RecurrenceFrequency
    var interval: Int // e.g., every 2 days, every 3 weeks
    var endDate: Date? // Optional end date for recurrence
    var occurrences: Int? // Optional number of occurrences
    var weekdays: [Int]? // For weekly: [1-7] where 1 = Sunday
    var dayOfMonth: Int? // For monthly: 1-31
    
    init(
        frequency: RecurrenceFrequency = .none,
        interval: Int = 1,
        endDate: Date? = nil,
        occurrences: Int? = nil,
        weekdays: [Int]? = nil,
        dayOfMonth: Int? = nil
    ) {
        self.frequency = frequency
        self.interval = interval
        self.endDate = endDate
        self.occurrences = occurrences
        self.weekdays = weekdays
        self.dayOfMonth = dayOfMonth
    }
    
    func nextOccurrence(from date: Date) -> Date? {
        guard frequency != .none else { return nil }
        
        let calendar = Calendar.current
        var nextDate = calendar.startOfDay(for: date)
        
        switch frequency {
        case .daily:
            nextDate = calendar.date(byAdding: .day, value: interval, to: nextDate) ?? nextDate
        case .weekly:
            if let weekdays = weekdays, !weekdays.isEmpty {
                // Find next weekday
                var found = false
                var daysToAdd = 1
                while !found && daysToAdd < 14 {
                    if let candidate = calendar.date(byAdding: .day, value: daysToAdd, to: nextDate) {
                        let weekday = calendar.component(.weekday, from: candidate)
                        if weekdays.contains(weekday) {
                            nextDate = candidate
                            found = true
                        }
                    }
                    daysToAdd += 1
                }
            } else {
                nextDate = calendar.date(byAdding: .day, value: interval * 7, to: nextDate) ?? nextDate
            }
        case .monthly:
            if let dayOfMonth = dayOfMonth {
                // Find next occurrence on the same day of month
                var components = calendar.dateComponents([.year, .month], from: nextDate)
                components.day = dayOfMonth
                if let candidate = calendar.date(from: components), candidate > nextDate {
                    nextDate = candidate
                } else {
                    components.month = (components.month ?? 0) + interval
                    nextDate = calendar.date(from: components) ?? nextDate
                }
            } else {
                nextDate = calendar.date(byAdding: .month, value: interval, to: nextDate) ?? nextDate
            }
        case .yearly:
            nextDate = calendar.date(byAdding: .year, value: interval, to: nextDate) ?? nextDate
        case .none:
            return nil
        }
        
        // Check if we've exceeded end date or occurrences
        if let endDate = endDate, nextDate > endDate {
            return nil
        }
        
        return nextDate
    }
    
    var isActive: Bool {
        frequency != .none
    }
}

