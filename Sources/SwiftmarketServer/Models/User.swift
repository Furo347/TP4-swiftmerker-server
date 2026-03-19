import Fluent
import Vapor
import Foundation

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "email")
    var email: String

    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID = UUID(), username: String, email: String, createdAt: Date) {
        self.id = id
        self.username = username
        self.email = email
        self.createdAt = createdAt
    }
}