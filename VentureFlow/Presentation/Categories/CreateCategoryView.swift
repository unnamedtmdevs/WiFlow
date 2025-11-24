import SwiftUI

struct CreateCategoryView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: () -> Void
    
    @State private var name = ""
    @State private var selectedColor = "00FF00"
    @State private var selectedIcon = "folder.fill"
    
    private let availableColors = ["00FF00", "FF4500", "FFD700", "ADD8E6", "FF69B4", "00CED1", "FF6347", "9370DB"]
    private let availableIcons = ["folder.fill", "briefcase.fill", "book.fill", "star.fill", "heart.fill", "gamecontroller.fill", "music.note", "paintbrush.fill", "camera.fill", "sportscourt.fill"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                scrollContent
            }
            .navigationTitle("New Category")
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
        }
    }
    
    private var scrollContent: some View {
        ScrollView {
            HStack {
                Spacer()
                mainContent
                Spacer()
            }
            .frame(maxWidth: 600)
            .padding(AppTheme.screenPadding)
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: AppSpacing.lg) {
            categoryNameSection
            colorPickerSection
            iconPickerSection
            createButton
            Spacer(minLength: AppSpacing.xl)
        }
    }
    
    private var categoryNameSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Category Name")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
            
            TextField("Enter category name", text: $name)
                .font(AppTypography.body)
                .foregroundColor(AppColors.textPrimary)
                .padding(AppSpacing.md)
                .background(AppColors.backgroundSecondary)
                .cornerRadius(AppTheme.cornerRadius)
        }
    }
    
    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Color")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
            
            colorPicker
        }
    }
    
    private var colorPicker: some View {
        HStack(spacing: AppSpacing.md) {
            ForEach(availableColors, id: \.self) { color in
                colorButton(color: color)
            }
        }
    }
    
    private func colorButton(color: String) -> some View {
        let isSelected = selectedColor == color
        let strokeColor = isSelected ? AppColors.textPrimary : Color.clear
        let shadowColor = isSelected ? Color(hex: color).opacity(0.4) : Color.clear
        let shadowRadius: CGFloat = isSelected ? 8 : 0
        let shadowY: CGFloat = isSelected ? 4 : 0
        
        return Button(action: {
            HapticsService.shared.impact(.light)
            selectedColor = color
        }) {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(strokeColor, lineWidth: 3)
                )
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
        }
    }
    
    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Icon")
                .font(AppTypography.body)
                .foregroundColor(AppColors.textSecondary)
            
            iconGrid
        }
    }
    
    private var createButton: some View {
        Button(action: saveCategory) {
            Text("Create Category")
                .primaryButtonStyle()
        }
        .disabled(name.isEmpty)
        .opacity(name.isEmpty ? 0.5 : 1.0)
    }
    
    private var iconGrid: some View {
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.md), count: 5)
        let iconColor = Color(hex: selectedColor)
        
        return LazyVGrid(columns: gridColumns, spacing: AppSpacing.md) {
            ForEach(availableIcons, id: \.self) { icon in
                iconButton(icon: icon, iconColor: iconColor)
            }
        }
    }
    
    private func iconButton(icon: String, iconColor: Color) -> some View {
        let isSelected = selectedIcon == icon
        let backgroundFill = isSelected ? iconColor.opacity(0.3) : AppColors.backgroundSecondary
        let foregroundColor = isSelected ? iconColor : AppColors.textSecondary
        let strokeColor = isSelected ? iconColor : Color.clear
        
        return Button(action: {
            HapticsService.shared.impact(.light)
            selectedIcon = icon
        }) {
            ZStack {
                Circle()
                    .fill(backgroundFill)
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(foregroundColor)
            }
            .overlay(
                Circle()
                    .stroke(strokeColor, lineWidth: 2)
            )
        }
    }
    
    private func saveCategory() {
        let category = Category(
            name: name,
            color: selectedColor,
            icon: selectedIcon
        )
        CategoryService.shared.createCategory(category)
        HapticsService.shared.success()
        onSave()
        dismiss()
    }
}

