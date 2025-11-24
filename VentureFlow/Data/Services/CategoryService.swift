import Foundation

final class CategoryService {
    static let shared = CategoryService()
    private let storage = StorageService.shared
    
    private init() {
        initializeDefaultCategories()
    }
    
    private func initializeDefaultCategories() {
        let existingCategories = getAllCategories()
        if existingCategories.isEmpty {
            let defaultCategories = Category.defaultCategories
            storage.saveArray(defaultCategories, forKey: UserDefaultsKeys.categories)
        }
    }
    
    func getAllCategories() -> [Category] {
        let categories = storage.loadArray(Category.self, forKey: UserDefaultsKeys.categories)
        return categories.isEmpty ? Category.defaultCategories : categories
    }
    
    func getCategory(by id: UUID) -> Category? {
        getAllCategories().first(where: { $0.id == id })
    }
    
    func getCategory(by name: String) -> Category? {
        getAllCategories().first(where: { $0.name == name })
    }
    
    func createCategory(_ category: Category) {
        var categories = getAllCategories()
        // Check if category with same name already exists
        guard !categories.contains(where: { $0.name.lowercased() == category.name.lowercased() }) else {
            return
        }
        categories.append(category)
        storage.saveArray(categories, forKey: UserDefaultsKeys.categories)
        
        NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }
    
    func updateCategory(_ updatedCategory: Category) {
        var categories = getAllCategories()
        if let index = categories.firstIndex(where: { $0.id == updatedCategory.id }) {
            categories[index] = updatedCategory
            storage.saveArray(categories, forKey: UserDefaultsKeys.categories)
            
            NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
        }
    }
    
    func deleteCategory(_ category: Category) -> Bool {
        // Check if category is used in projects
        let projects = ProjectService.shared.getAllProjects()
        let projectsUsingCategory = projects.filter { $0.category == category.name }
        
        if !projectsUsingCategory.isEmpty {
            // Update all projects using this category to first available category or "Personal"
            let availableCategories = getAllCategories()
            let fallbackCategory = availableCategories.first(where: { $0.name == "Personal" })?.name ?? 
                                  availableCategories.first?.name ?? "Personal"
            
            for project in projectsUsingCategory {
                var updatedProject = project
                updatedProject.category = fallbackCategory
                ProjectService.shared.updateProject(updatedProject)
            }
        }
        
        var categories = getAllCategories()
        // Don't delete default categories
        if Category.defaultCategories.contains(where: { $0.name == category.name }) {
            return false
        }
        
        categories.removeAll(where: { $0.id == category.id })
        storage.saveArray(categories, forKey: UserDefaultsKeys.categories)
        
        NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
        
        return true
    }
    
    func getCategoryNames() -> [String] {
        getAllCategories().map { $0.name }
    }
}

