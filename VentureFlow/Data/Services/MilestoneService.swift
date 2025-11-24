import Foundation

final class MilestoneService {
    static let shared = MilestoneService()
    private let storage = StorageService.shared

    private init() {}

    func getAllMilestones() -> [Milestone] {
        storage.loadArray(Milestone.self, forKey: UserDefaultsKeys.milestones)
    }

    func getMilestone(by id: UUID) -> Milestone? {
        getAllMilestones().first(where: { $0.id == id })
    }

    func getMilestonesForProject(_ projectId: UUID) -> [Milestone] {
        getAllMilestones().filter { $0.projectId == projectId }
    }

    func createMilestone(_ milestone: Milestone) {
        var milestones = getAllMilestones()
        milestones.append(milestone)
        storage.saveArray(milestones, forKey: UserDefaultsKeys.milestones)
    }

    func updateMilestone(_ updatedMilestone: Milestone) {
        var milestones = getAllMilestones()
        if let index = milestones.firstIndex(where: { $0.id == updatedMilestone.id }) {
            milestones[index] = updatedMilestone
            storage.saveArray(milestones, forKey: UserDefaultsKeys.milestones)
        }
    }

    func deleteMilestone(_ milestone: Milestone) {
        var milestones = getAllMilestones()
        milestones.removeAll(where: { $0.id == milestone.id })
        storage.saveArray(milestones, forKey: UserDefaultsKeys.milestones)
    }

    func deleteMilestonesForProject(_ projectId: UUID) {
        var milestones = getAllMilestones()
        milestones.removeAll(where: { $0.projectId == projectId })
        storage.saveArray(milestones, forKey: UserDefaultsKeys.milestones)
    }

    func calculateMilestoneProgress(for projectId: UUID) -> Double {
        let milestones = getMilestonesForProject(projectId)
        guard !milestones.isEmpty else { return 0 }

        let completedMilestones = milestones.filter { $0.isCompleted }.count
        return Double(completedMilestones) / Double(milestones.count) * 100
    }
}
