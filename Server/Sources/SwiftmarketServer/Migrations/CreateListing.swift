import Fluent
import Vapor

struct CreateListing: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Listing.schema)
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("price", .double, .required)
            .field("category", .string, .required)
            .field("sellerID", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("createdAt", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Listing.schema).delete()
    }
}