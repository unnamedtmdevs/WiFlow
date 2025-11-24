import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ResourceDetailView: View {
    @Environment(\.dismiss) var dismiss
    let resource: Resource
    let onUpdate: () -> Void
    
    @State private var project: Project?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: AppSpacing.lg) {
                            resourceHeaderSection
                            
                            resourceInfoSection
                            
                            resourceContentSection
                            
                            Spacer(minLength: AppSpacing.xl)
                        }
                        .frame(maxWidth: 600)
                        .padding(AppTheme.screenPadding)
                        Spacer()
                    }
                }
            }
            .navigationTitle(resource.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            .onAppear {
                loadProject()
            }
        }
    }
    
    private var resourceHeaderSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    colorForType(resource.type).opacity(0.3),
                                    colorForType(resource.type).opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: iconForType(resource.type))
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(colorForType(resource.type))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    StatusBadge(text: resource.type.rawValue, color: colorForType(resource.type))
                    
                    if let project = project {
                        HStack(spacing: 4) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 12))
                            Text(project.name)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding(AppTheme.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppColors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        colorForType(resource.type).opacity(0.2),
                                        colorForType(resource.type).opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
    
    private var resourceInfoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                InfoItem(
                    icon: "calendar",
                    title: "Created",
                    value: resource.createdDate.formatted()
                )
                
                if let project = project {
                    InfoItem(
                        icon: "folder.fill",
                        title: "Project",
                        value: project.name
                    )
                }
            }
        }
    }
    
    private var resourceContentSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(
                resource.type == .link ? "URL" :
                resource.type == .note ? "Content" :
                resource.type == .picture ? "Picture" :
                "File Information"
            )
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            if resource.type == .link {
                linkContentView
            } else if resource.type == .file {
                fileContentView
            } else if resource.type == .picture {
                pictureContentView
            } else {
                noteContentView
            }
        }
    }
    
    private var linkContentView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let url = URL(string: resource.content) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "safari.fill")
                            .font(.system(size: 18))
                        Text(resource.content)
                            .font(.system(size: 15, weight: .medium))
                            .lineLimit(2)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(AppColors.primary)
                    .padding(AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(AppColors.primary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            } else {
                Text(resource.content)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(AppColors.backgroundSecondary)
                    )
            }
        }
    }
    
    private var fileContentView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if resource.content.hasPrefix("bookmark:") {
                Text("File is stored using security-scoped bookmark")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(AppColors.backgroundSecondary)
                    )
            } else {
                HStack {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 20))
                        .foregroundColor(colorForType(resource.type))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("File Path")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        Text((resource.content as NSString).lastPathComponent)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        openFile()
                    }) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(AppColors.backgroundSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            colorForType(resource.type).opacity(0.2),
                                            colorForType(resource.type).opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
            }
        }
    }
    
    private var noteContentView: some View {
        Text(resource.content)
            .font(.system(size: 15))
            .foregroundColor(AppColors.textPrimary)
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(AppColors.backgroundSecondary)
            )
    }
    
    private func loadProject() {
        project = ProjectService.shared.getProject(by: resource.projectId)
    }
    
    private func openFile() {
        let fileURL = URL(fileURLWithPath: resource.content)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // Start accessing security-scoped resource if needed
            let hasAccess = fileURL.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }
            
            let activityVC = UIActivityViewController(
                activityItems: [fileURL],
                applicationActivities: nil
            )
            
            // Get the root view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                // For iPad support
                if UIDevice.current.userInterfaceIdiom == .pad {
                    activityVC.popoverPresentationController?.sourceView = window
                    activityVC.popoverPresentationController?.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                    activityVC.popoverPresentationController?.permittedArrowDirections = []
                }
                
                var presentingViewController = rootViewController
                while let presented = presentingViewController.presentedViewController {
                    presentingViewController = presented
                }
                presentingViewController.present(activityVC, animated: true)
            }
        }
    }
    
    private var pictureContentView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if let image = loadImage(from: resource.content) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 400)
                    .cornerRadius(AppTheme.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppColors.orange.opacity(0.3),
                                        AppColors.orange.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: AppColors.orange.opacity(0.2), radius: 10, x: 0, y: 5)
                
                if !resource.notes.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Note")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(resource.notes)
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(AppSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .fill(AppColors.backgroundSecondary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                            .stroke(AppColors.orange.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                }
            } else {
                HStack {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.textSecondary)
                    Text("Image not found")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(AppColors.backgroundSecondary)
                )
            }
        }
        .padding(AppTheme.cardPadding)
        .cardStyle()
    }
    
    private func loadImage(from path: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        return UIImage(data: imageData)
    }
    
    private func iconForType(_ type: ResourceType) -> String {
        switch type {
        case .file: return "doc.fill"
        case .link: return "link"
        case .note: return "note.text"
        case .picture: return "photo.fill"
        }
    }
    
    private func colorForType(_ type: ResourceType) -> Color {
        switch type {
        case .file: return AppColors.primary
        case .link: return AppColors.lightBlue
        case .note: return AppColors.gold
        case .picture: return AppColors.orange
        }
    }
}

struct InfoItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(AppColors.backgroundSecondary)
        )
    }
}

