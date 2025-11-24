import SwiftUI

struct TaskCard: View {
    let task: Task
    let projectName: String
    let onComplete: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            onTap()
        }) {
            HStack(spacing: 0) {
                // Left colored accent bar based on priority
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [priorityColor, priorityColor.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6)
                
                HStack(spacing: AppSpacing.md) {
                    // Checkbox for completion
                    Button(action: {
                        HapticsService.shared.success()
                        withAnimation(SettingsService.shared.animationsEnabled ? .spring(response: 0.4, dampingFraction: 0.6) : .none) {
                            onComplete()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    task.isCompleted ?
                                    LinearGradient(
                                        colors: [AppColors.darkGreen, AppColors.darkGreen.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [
                                            AppColors.backgroundSecondary,
                                            AppColors.backgroundSecondary.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            task.isCompleted ? Color.clear : priorityColor.opacity(0.3),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(
                                    color: task.isCompleted ? AppColors.darkGreen.opacity(0.4) : Color.clear,
                                    radius: task.isCompleted ? 8 : 0,
                                    x: 0,
                                    y: task.isCompleted ? 4 : 0
                                )
                                .scaleEffect(task.isCompleted && SettingsService.shared.animationsEnabled ? 1.1 : 1.0)
                                .animation(
                                    SettingsService.shared.animationsEnabled ?
                                    .spring(response: 0.3, dampingFraction: 0.6) : .none,
                                    value: task.isCompleted
                                )
                            
                            if task.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppColors.background)
                                    .scaleEffect(SettingsService.shared.animationsEnabled ? 1.0 : 1.0)
                                    .animation(
                                        SettingsService.shared.animationsEnabled ?
                                        .spring(response: 0.3, dampingFraction: 0.6).delay(0.1) : .none,
                                        value: task.isCompleted
                                    )
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Task content
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text(task.name)
                            .font(.system(size: 17, weight: task.isCompleted ? .medium : .bold))
                            .foregroundColor(task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                            .strikethrough(task.isCompleted)
                            .lineLimit(2)
                        
                        HStack(spacing: AppSpacing.sm) {
                            // Project name
                            HStack(spacing: 4) {
                                Image(systemName: "folder.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary)
                                Text(projectName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            // Deadline
                            if let deadline = task.deadline {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(deadlineColor(deadline))
                                    Text(deadlineText(deadline))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(deadlineColor(deadline))
                                }
                            }
                            
                            Spacer()
                            
                            // Recurrence indicator
                            if task.recurrenceRule?.isActive == true {
                                HStack(spacing: 4) {
                                    Image(systemName: "repeat")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            
                            // Priority indicator
                            Circle()
                                .fill(priorityColor.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }

                    Spacer()
                }
                .padding(AppSpacing.lg)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: task.isCompleted ?
                            [
                                AppColors.darkGreen.opacity(0.15),
                                AppColors.darkGreen.opacity(0.05)
                            ] :
                            [
                                priorityColor.opacity(0.2),
                                priorityColor.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .opacity(task.isCompleted ? 0.7 : 1.0)
            .shadow(color: priorityColor.opacity(0.08), radius: 8, x: 0, y: 4)
            .scaleEffect(SettingsService.shared.animationsEnabled ? 1.0 : 1.0)
            .animation(
                SettingsService.shared.animationsEnabled ?
                .spring(response: 0.4, dampingFraction: 0.7) : .none,
                value: task.isCompleted
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var priorityColor: Color {
        task.priority.color
    }

    private func deadlineColor(_ deadline: Date) -> Color {
        if task.isOverdue {
            return AppColors.orange
        }
        let days = Date().daysUntil(deadline)
        if days <= 7 {
            return AppColors.orange
        }
        return AppColors.lightBlue
    }

    private func deadlineText(_ deadline: Date) -> String {
        let days = Date().daysUntil(deadline)
        if days < 0 {
            return "\(abs(days))d late"
        } else if days == 0 {
            return "Today"
        } else {
            return "\(days)d"
        }
    }
}
