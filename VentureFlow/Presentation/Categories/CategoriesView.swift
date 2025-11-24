import SwiftUI

struct CategoriesView: View {
    @State private var categories: [Category] = []
    @State private var showCreateCategory = false
    @State private var selectedCategory: Category?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    HStack {
                        Spacer()
                        VStack(spacing: AppSpacing.md) {
                            if categories.isEmpty {
                                EmptyStateView(
                                    icon: "tag.fill",
                                    message: "No categories yet. Create your first category!"
                                )
                                .padding(.top, AppSpacing.xxl)
                            } else {
                                ForEach(categories) { category in
                                    CategoryCardView(category: category) {
                                        HapticsService.shared.impact(.light)
                                        selectedCategory = category
                                    }
                                    .contextMenu {
                                        Button {
                                            HapticsService.shared.impact(.light)
                                            selectedCategory = category
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        
                                        if !Category.defaultCategories.contains(where: { $0.name == category.name }) {
                                            Button(role: .destructive) {
                                                deleteCategory(category)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
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
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticsService.shared.impact()
                        showCreateCategory = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .onAppear {
                loadCategories()
            }
            .onReceive(NotificationCenter.default.publisher(for: .categoriesDidChange)) { _ in
                loadCategories()
            }
            .sheet(isPresented: $showCreateCategory) {
                CreateCategoryView(onSave: {
                    loadCategories()
                })
            }
            .sheet(item: $selectedCategory) { category in
                EditCategoryView(category: category, onSave: {
                    loadCategories()
                    selectedCategory = nil
                })
            }
        }
    }
    
    private func loadCategories() {
        categories = CategoryService.shared.getAllCategories()
    }
    
    private func deleteCategory(_ category: Category) {
        HapticsService.shared.warning()
        let success = CategoryService.shared.deleteCategory(category)
        if success {
            loadCategories()
        }
    }
}

struct CategoryCardView: View {
    let category: Category
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            HapticsService.shared.impact(.light)
            onTap()
        }) {
            HStack(spacing: 0) {
                // Left colored accent bar
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: category.color))
                    .frame(width: 6)
                
                HStack(spacing: AppSpacing.md) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: category.color).opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color(hex: category.color))
                    }
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack {
                            Text(category.name)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            if Category.defaultCategories.contains(where: { $0.name == category.name }) {
                                Text("Default")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.backgroundSecondary)
                                    .cornerRadius(6)
                            }
                        }
                        
                        Text("\(getProjectsCount()) projects")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(AppSpacing.lg)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: category.color).opacity(0.2),
                                Color(hex: category.color).opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color(hex: category.color).opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getProjectsCount() -> Int {
        ProjectService.shared.getAllProjects().filter { $0.category == category.name }.count
    }
}

