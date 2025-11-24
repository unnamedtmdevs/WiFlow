import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.backgroundSecondary, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress / 100)
                .stroke(progressColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            Text("\(Int(progress))%")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(width: size, height: size)
    }

    private var progressColor: Color {
        switch progress {
        case 0..<34:
            return AppColors.lightBlue
        case 34..<67:
            return AppColors.gold
        case 67..<100:
            return AppColors.darkGreen
        default:
            return AppColors.primary
        }
    }
}
