import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct CreateResourceView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: () -> Void

    @State private var name = ""
    @State private var type: ResourceType = .note
    @State private var selectedProjectId: UUID?
    @State private var content = ""
    @State private var projects: [Project] = []
    @State private var selectedFileURL: URL?
    @State private var selectedFileName: String?
    @State private var showFilePicker = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showImageSourcePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var pictureNote = ""

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    HStack {
                        Spacer()
                        VStack(spacing: AppSpacing.lg) {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Resource Name")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            TextField("Enter resource name", text: $name)
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(AppSpacing.md)
                                .background(AppColors.backgroundSecondary)
                                .cornerRadius(AppTheme.cornerRadius)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Type")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            HStack(spacing: AppSpacing.sm) {
                                ForEach(ResourceType.allCases, id: \.self) { t in
                                    Button(action: {
                                        HapticsService.shared.impact(.light)
                                        type = t
                                        // Clear selections when changing type
                                        if t != .file {
                                            selectedFileURL = nil
                                            selectedFileName = nil
                                        }
                                        if t != .picture {
                                            selectedImage = nil
                                            pictureNote = ""
                                        }
                                    }) {
                                        Text(t.rawValue)
                                            .font(AppTypography.caption)
                                            .foregroundColor(type == t ? AppColors.background : AppColors.textPrimary)
                                            .padding(.horizontal, AppSpacing.md)
                                            .padding(.vertical, AppSpacing.sm)
                                            .frame(maxWidth: .infinity)
                                            .background(type == t ? colorForType(t) : AppColors.backgroundSecondary)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Project")
                                .font(AppTypography.body)
                                .foregroundColor(AppColors.textSecondary)

                            if projects.isEmpty {
                                Text("No projects available. Create a project first.")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(AppSpacing.md)
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.backgroundSecondary)
                                    .cornerRadius(AppTheme.cornerRadius)
                            } else {
                                Menu {
                                    ForEach(projects) { project in
                                        Button(action: {
                                            selectedProjectId = project.id
                                        }) {
                                            HStack {
                                                Text(project.name)
                                                if selectedProjectId == project.id {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedProjectId == nil ? "Select project" : projects.first(where: { $0.id == selectedProjectId })?.name ?? "Select project")
                                            .font(AppTypography.body)
                                            .foregroundColor(selectedProjectId == nil ? AppColors.textSecondary : AppColors.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding(AppSpacing.md)
                                    .background(AppColors.backgroundSecondary)
                                    .cornerRadius(AppTheme.cornerRadius)
                                }
                            }
                        }

                        if type == .file {
                            fileSelectionSection
                        } else if type == .picture {
                            pictureSelectionSection
                        } else {
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                Text(type == .link ? "URL" : "Content")
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textSecondary)

                                TextEditor(text: $content)
                                    .font(AppTypography.body)
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(height: 100)
                                    .padding(AppSpacing.sm)
                                    .background(AppColors.backgroundSecondary)
                                    .cornerRadius(AppTheme.cornerRadius)
                            }
                        }

                        Button(action: saveResource) {
                            Text("Create Resource")
                                .primaryButtonStyle()
                        }
                        .disabled(
                            name.isEmpty ||
                            selectedProjectId == nil ||
                            (type == .file && selectedFileName == nil) ||
                            (type == .picture && selectedImage == nil) ||
                            (type != .file && type != .picture && content.isEmpty)
                        )
                        .opacity(
                            (name.isEmpty ||
                             selectedProjectId == nil ||
                             (type == .file && selectedFileName == nil) ||
                             (type == .picture && selectedImage == nil) ||
                             (type != .file && type != .picture && content.isEmpty)) ? 0.5 : 1.0
                        )

                            Spacer(minLength: AppSpacing.xl)
                        }
                        .frame(maxWidth: 600)
                        .padding(AppTheme.screenPadding)
                        Spacer()
                    }
                }
            }
            .navigationTitle("New Resource")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            .onAppear {
                loadProjects()
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [UTType.item],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        handleSelectedFile(url: url)
                    }
                case .failure:
                    break
                }
            }
            .sheet(isPresented: $showImagePicker) {
                if imagePickerSourceType == .photoLibrary {
                    PHPicker(
                        selectedImage: $selectedImage,
                        isPresented: $showImagePicker,
                        onImageSelected: { image in
                            handleSelectedImage(image)
                        }
                    )
                } else {
                    ImagePicker(
                        selectedImage: $selectedImage,
                        isPresented: $showImagePicker,
                        sourceType: imagePickerSourceType,
                        onImageSelected: { image in
                            handleSelectedImage(image)
                        }
                    )
                }
            }
        }
    }
    
    private func handleSelectedFile(url: URL) {
        // Get file name first
        let fileName = url.lastPathComponent
        
        // Request access to security-scoped resource
        // This is necessary when accessing files outside app's sandbox
        let hasAccess = url.startAccessingSecurityScopedResource()
        
        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        // Copy file to app's documents directory for permanent access
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let resourcesDirectory = documentsPath.appendingPathComponent("Resources", isDirectory: true)
        
        // Create Resources directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: resourcesDirectory.path) {
            try? FileManager.default.createDirectory(at: resourcesDirectory, withIntermediateDirectories: true)
        }
        
        let destinationURL = resourcesDirectory.appendingPathComponent("\(UUID().uuidString)_\(fileName)")
        
        do {
            // Copy file to app's directory
            // This requires that we have access (which we requested above)
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            // Store path in content
            selectedFileURL = destinationURL
            selectedFileName = fileName
            content = destinationURL.path
            
            // Auto-fill name if empty
            if name.isEmpty {
                name = (fileName as NSString).deletingPathExtension
            }
        } catch {
            // In iOS, we can't use security-scoped bookmarks like in macOS
            // Try alternative approach: save file name and path reference
            // Note: Access to the file will be granted automatically by iOS when using fileImporter
            selectedFileName = fileName
            content = url.lastPathComponent
            
            // Auto-fill name if empty
            if name.isEmpty {
                name = (fileName as NSString).deletingPathExtension
            }
        }
    }

    private func handleSelectedImage(_ image: UIImage) {
        // Save image to documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let resourcesDirectory = documentsPath.appendingPathComponent("Resources", isDirectory: true)
        
        // Create Resources directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: resourcesDirectory.path) {
            try? FileManager.default.createDirectory(at: resourcesDirectory, withIntermediateDirectories: true)
        }
        
        let imageFileName = "\(UUID().uuidString).jpg"
        let imageURL = resourcesDirectory.appendingPathComponent(imageFileName)
        
        // Convert UIImage to JPEG data
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            do {
                try imageData.write(to: imageURL)
                content = imageURL.path
                
                // Auto-fill name if empty
                if name.isEmpty {
                    name = "Image \(Date().formatted(date: .abbreviated, time: .omitted))"
                }
            } catch {
                // Error saving image
            }
        }
    }
    
    private func saveResource() {
        guard let projectId = selectedProjectId else { return }
        
        let resourceNotes = type == .picture ? pictureNote : (type == .note ? content : "")
        
        let resource = Resource(
            name: name,
            type: type,
            projectId: projectId,
            content: content,
            notes: resourceNotes
        )

        ResourceService.shared.createResource(resource)
        HapticsService.shared.success()
        onSave()
        dismiss()
    }

    private func loadProjects() {
        projects = ProjectService.shared.getAllProjects()
    }

    private func colorForType(_ type: ResourceType) -> Color {
        switch type {
        case .file: return AppColors.primary
        case .link: return AppColors.lightBlue
        case .note: return AppColors.gold
        case .picture: return AppColors.orange
        }
    }
    
    private var fileSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("File")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
            
            if let fileName = selectedFileName {
                HStack {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primary)
                    
                    Text(fileName)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedFileURL = nil
                        selectedFileName = nil
                        content = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(AppSpacing.md)
                .background(AppColors.backgroundSecondary)
                .cornerRadius(AppTheme.cornerRadius)
            } else {
                Button(action: {
                    showFilePicker = true
                }) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 20))
                        Text("Select File")
                            .font(AppTypography.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(AppColors.primary)
                    .padding(AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .fill(AppColors.backgroundSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                AppColors.primary.opacity(0.3),
                                                AppColors.primary.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    )
                }
            }
        }
    }
    
    private var pictureSelectionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Picture")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
            
            if let image = selectedImage {
                VStack(spacing: AppSpacing.md) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(AppTheme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(AppColors.orange.opacity(0.3), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Note")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                        
                        TextEditor(text: $pictureNote)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(height: 100)
                            .padding(AppSpacing.sm)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(AppColors.orange.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        selectedImage = nil
                        content = ""
                        pictureNote = ""
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                            Text("Remove Picture")
                                .font(AppTypography.body)
                        }
                        .foregroundColor(AppColors.orange)
                        .padding(.vertical, AppSpacing.sm)
                        .padding(.horizontal, AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppColors.backgroundSecondary)
                        )
                    }
                }
            } else {
                HStack(spacing: AppSpacing.md) {
                    Button(action: {
                        imagePickerSourceType = .camera
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showImagePicker = true
                        }
                    }) {
                        VStack(spacing: AppSpacing.sm) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                            Text("Camera")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(AppColors.orange)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppColors.backgroundSecondary)
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
                        )
                    }
                    .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                    
                    Button(action: {
                        imagePickerSourceType = .photoLibrary
                        showImagePicker = true
                    }) {
                        VStack(spacing: AppSpacing.sm) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                            Text("Gallery")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(AppColors.orange)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppColors.backgroundSecondary)
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
                        )
                    }
                }
            }
        }
    }
}
