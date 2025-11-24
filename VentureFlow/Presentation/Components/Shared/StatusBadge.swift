import SwiftUI

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(AppTypography.caption)
            .foregroundColor(AppColors.background)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(color)
            .cornerRadius(8)
    }
}

extension ProjectStatus {
    var color: Color {
        switch self {
        case .planning:
            return AppColors.lightBlue
        case .inProgress:
            return AppColors.primary
        case .onHold:
            return AppColors.gold
        case .completed:
            return AppColors.darkGreen
        }
    }
}

extension TaskStatus {
    var color: Color {
        switch self {
        case .toDo:
            return AppColors.lightBlue
        case .inProgress:
            return AppColors.gold
        case .completed:
            return AppColors.darkGreen
        }
    }
}

extension ProjectPriority {
    var color: Color {
        switch self {
        case .low:
            return AppColors.lightBlue
        case .medium:
            return AppColors.gold
        case .high:
            return AppColors.orange
        }
    }
}

extension TaskPriority {
    var color: Color {
        switch self {
        case .low:
            return AppColors.lightBlue
        case .medium:
            return AppColors.gold
        case .high:
            return AppColors.orange
        }
    }
}
