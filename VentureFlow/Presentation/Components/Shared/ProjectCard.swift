import SwiftUI

struct ProjectCard: View {
    let project: Project
    let progress: Double
    let taskCount: Int
    let completedTaskCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            onTap()
        }) {
            HStack(spacing: 0) {
                // Left colored accent bar
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6)
                
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        // Project icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [accentColor.opacity(0.3), accentColor.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "folder.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(accentColor)
                        }
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(project.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                                .lineLimit(2)
                            
                            HStack(spacing: AppSpacing.sm) {
                                // Task count
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                    Text("\(taskCount)")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                // Deadline
                                if let deadline = project.deadline {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(deadlineColor(deadline))
                                        Text(deadlineText(deadline))
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(deadlineColor(deadline))
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Progress indicator
                    if taskCount > 0 {
                        HStack(spacing: AppSpacing.sm) {
                            // Circular progress
                            ZStack {
                                Circle()
                                    .stroke(AppColors.backgroundSecondary, lineWidth: 6)
                                    .frame(width: 48, height: 48)
                                
                                Circle()
                                    .trim(from: 0, to: progress / 100)
                                    .stroke(
                                        LinearGradient(
                                            colors: [accentColor, accentColor.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 48, height: 48)
                                
                                Text("\(Int(progress))%")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(completedTaskCount) of \(taskCount) tasks")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text(project.status.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                        }
                    } else {
                        Text("No tasks yet")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.leading, 4)
                    }
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
                            colors: [
                                accentColor.opacity(0.2),
                                accentColor.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: accentColor.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var accentColor: Color {
        project.status.color
    }
    
    private var progressColor: Color {
        switch progress {
        case 0..<34:
            return AppColors.primary
        case 34..<67:
            return AppColors.gold
        case 67..<100:
            return AppColors.darkGreen
        default:
            return AppColors.primary
        }
    }

    private func deadlineColor(_ deadline: Date) -> Color {
        let days = Date().daysUntil(deadline)
        if days < 0 {
            return AppColors.orange
        } else if days <= 7 {
            return AppColors.orange
        } else {
            return AppColors.textSecondary
        }
    }

    private func deadlineText(_ deadline: Date) -> String {
        let days = Date().daysUntil(deadline)
        if days < 0 {
            return "\(abs(days))d late"
        } else if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else if days <= 7 {
            return "\(days)d"
        } else {
            return deadline.formatted(date: .abbreviated, time: .omitted)
        }
    }
}
