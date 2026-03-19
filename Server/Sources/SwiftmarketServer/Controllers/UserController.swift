import Fluent
import Vapor
import Foundation

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
        users.get(":userID", use: get)
    }

    func create(req: Request) async throws -> Response {
        try CreateUserRequest.validate(content: req)
        let createUser = try req.content.decode(CreateUserRequest.self)

        let user = User(username: createUser.username, email: createUser.email, createdAt: Date())
        try await user.save(on: req.db)

        let response = try UserResponse(user: user)
        let httpResponse = Response(status: .created)
        try httpResponse.content.encode(response)
        return httpResponse
    }

    func getAll(req: Request) async throws -> [UserResponse] {
        let users = try await User.query(on: req.db).all()
        return try users.map { try UserResponse(user: $0) }
    }

    func get(req: Request) async throws -> UserResponse {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }

        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        return try UserResponse(user: user)
    }

    func getListings(req: Request) async throws -> [ListingResponse] {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }

        let listings = try await Listing.query(on: req.db)
            .filter(\.$seller.$id == userID)
            .with(\.$seller)
            .all()

        return try listings.map { listing in
            return try ListingResponse(listing: listing, seller: listing.seller)
        }
    }
}