import Foundation

final class ResourceService {
    static let shared = ResourceService()
    private let storage = StorageService.shared

    private init() {}

    func getAllResources() -> [Resource] {
        storage.loadArray(Resource.self, forKey: UserDefaultsKeys.resources)
    }

    func getResource(by id: UUID) -> Resource? {
        getAllResources().first(where: { $0.id == id })
    }

    func getResourcesForProject(_ projectId: UUID) -> [Resource] {
        getAllResources().filter { $0.projectId == projectId }
    }

    func createResource(_ resource: Resource) {
        var resources = getAllResources()
        resources.append(resource)
        storage.saveArray(resources, forKey: UserDefaultsKeys.resources)
        
        NotificationCenter.default.post(name: .resourcesDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }

    func updateResource(_ updatedResource: Resource) {
        var resources = getAllResources()
        if let index = resources.firstIndex(where: { $0.id == updatedResource.id }) {
            resources[index] = updatedResource
            storage.saveArray(resources, forKey: UserDefaultsKeys.resources)
            
            NotificationCenter.default.post(name: .resourcesDidChange, object: nil)
            NotificationCenter.default.post(name: .dataDidChange, object: nil)
        }
    }

    func deleteResource(_ resource: Resource) {
        var resources = getAllResources()
        resources.removeAll(where: { $0.id == resource.id })
        storage.saveArray(resources, forKey: UserDefaultsKeys.resources)
        
        NotificationCenter.default.post(name: .resourcesDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }

    func deleteResourcesForProject(_ projectId: UUID) {
        var resources = getAllResources()
        resources.removeAll(where: { $0.projectId == projectId })
        storage.saveArray(resources, forKey: UserDefaultsKeys.resources)
        
        NotificationCenter.default.post(name: .resourcesDidChange, object: nil)
        NotificationCenter.default.post(name: .dataDidChange, object: nil)
    }

    func getFilteredResources(
        type: ResourceType? = nil,
        projectId: UUID? = nil,
        searchText: String = ""
    ) -> [Resource] {
        var resources = getAllResources()

        if let type = type {
            resources = resources.filter { $0.type == type }
        }

        if let projectId = projectId {
            resources = resources.filter { $0.projectId == projectId }
        }

        if !searchText.isEmpty {
            resources = resources.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }

        return resources
    }
}
