import Foundation

public struct UserProfile: Codable, Equatable {
    public var id: UUID
    public var appleUserId: String
    public var displayName: String?
    public var isPremium: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        appleUserId: String,
        displayName: String? = nil,
        isPremium: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.appleUserId = appleUserId
        self.displayName = displayName
        self.isPremium = isPremium
        self.createdAt = createdAt
        self.updatedAt = Date()
    }
}
