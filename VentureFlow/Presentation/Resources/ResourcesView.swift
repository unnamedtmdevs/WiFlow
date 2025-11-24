import SwiftUI

struct ResourcesView: View {
    @State private var resources: [Resource] = []
    @State private var searchText = ""
    @State private var selectedType: ResourceType?
    @State private var showCreateResource = false
    @State private var selectedResource: Resource?

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            // Decorative element
            VStack {
                Spacer()
                HStack {
                    Circle()
                        .fill(AppColors.gold.opacity(0.08))
                        .frame(width: 150, height: 150)
                        .blur(radius: 40)
                        .offset(x: -30, y: 60)
                    Spacer()
                }
            }

            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    HStack {
                        Spacer()
                        VStack(spacing: AppSpacing.md) {
                            if filteredResources.isEmpty {
                                EmptyStateView(
                                    icon: "paperclip",
                                    message: "No resources yet. Add your first resource!"
                                )
                                .padding(.top, AppSpacing.xxl)
                            } else {
                                ForEach(filteredResources) { resource in
                                    ResourceCardView(
                                        resource: resource,
                                        projectName: getProjectName(for: resource),
                                        onTap: {
                                            selectedResource = resource
                                        }
                                    )
                                }
                            }

                            Spacer(minLength: AppSpacing.xl)
                        }
                        .frame(maxWidth: 600)
                        .padding(AppTheme.screenPadding)
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            loadResources()
        }
        .onReceive(NotificationCenter.default.publisher(for: .resourcesDidChange)) { _ in
            loadResources()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataDidChange)) { _ in
            loadResources()
        }
        .sheet(isPresented: $showCreateResource) {
            CreateResourceView(onSave: {
                loadResources()
            })
        }
        .sheet(item: $selectedResource) { resource in
            ResourceDetailView(resource: resource, onUpdate: {
                loadResources()
            })
        }
    }

    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Resources")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()

                Button(action: {
                    HapticsService.shared.impact()
                    showCreateResource = true
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                            .shadow(color: AppColors.primary.opacity(0.4), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.background)
                    }
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, AppSpacing.lg)

            searchBar

            typeFilters
        }
        .background(AppColors.background)
    }

    private var searchBar: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.primary)
            }

            TextField("Search resources...", text: $searchText)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppColors.primary.opacity(0.2),
                                    AppColors.primary.opacity(0.05)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, AppTheme.screenPadding)
    }

    private var typeFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                FilterChip(
                    title: "All",
                    isSelected: selectedType == nil,
                    onTap: {
                        selectedType = nil
                    }
                )

                ForEach(ResourceType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.rawValue,
                        isSelected: selectedType == type,
                        onTap: {
                            selectedType = type
                        }
                    )
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.vertical, AppSpacing.md)
        }
        .background(
            LinearGradient(
                colors: [
                    AppColors.backgroundSecondary.opacity(0.6),
                    AppColors.backgroundSecondary.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var filteredResources: [Resource] {
        ResourceService.shared.getFilteredResources(
            type: selectedType,
            searchText: searchText
        )
    }

    private func loadResources() {
        resources = ResourceService.shared.getAllResources()
    }

    private func getProjectName(for resource: Resource) -> String {
        ProjectService.shared.getProject(by: resource.projectId)?.name ?? "Unknown"
    }
}

struct ResourceCardView: View {
    let resource: Resource
    let projectName: String
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            onTap()
        }) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: iconForType(resource.type))
                    .font(.system(size: AppTheme.iconSizeMedium))
                    .foregroundColor(colorForType(resource.type))

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(resource.name)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)

                    Text(projectName)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                StatusBadge(text: resource.type.rawValue, color: colorForType(resource.type))
            }

            if resource.type == .picture {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    if let image = loadImage(from: resource.content) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        HStack {
                            Image(systemName: "photo.fill")
                                .foregroundColor(AppColors.textSecondary)
                            Text("Image not found")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.vertical, AppSpacing.sm)
                    }
                    
                    if !resource.notes.isEmpty {
                        Text(resource.notes)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                }
            } else if !resource.content.isEmpty {
                Text(resource.content)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(3)
            }

            Text(resource.createdDate.formatted())
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
            }
            .padding(AppTheme.cardPadding)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
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
