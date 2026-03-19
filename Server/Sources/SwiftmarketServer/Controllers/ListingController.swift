import Fluent
import Vapor
import Foundation

struct ListingController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let listings = routes.grouped("listings")
        listings.post(use: create)
        listings.get(use: getAll)
        listings.get(":listingID", use: get)
        listings.delete(":listingID", use: delete)
    }

    func create(req: Request) async throws -> Response {
        try CreateListingRequest.validate(content: req)
        let createListing = try req.content.decode(CreateListingRequest.self)

        guard createListing.price > 0 else {
            throw Abort(.unprocessableEntity, reason: "Price must be greater than 0")
        }

        let sellerID: UUID
        if let userIDHeader = req.headers.first(name: "X-User-ID") {
            guard let parsedHeaderID = UUID(uuidString: userIDHeader) else {
                throw Abort(.badRequest, reason: "Invalid X-User-ID header")
            }
            guard parsedHeaderID == createListing.sellerID else {
                throw Abort(.unprocessableEntity, reason: "X-User-ID must match sellerID")
            }
            sellerID = parsedHeaderID
        } else {
            sellerID = createListing.sellerID
        }

        let listing = Listing(title: createListing.title, description: createListing.description, price: createListing.price, category: createListing.category, sellerID: sellerID, createdAt: Date())
        try await listing.save(on: req.db)

        let seller = try await listing.$seller.get(on: req.db)
        let response = try ListingResponse(listing: listing, seller: seller)
        let httpResponse = Response(status: .created)
        try httpResponse.content.encode(response)
        return httpResponse
    }

    func get(req: Request) async throws -> ListingResponse {
        guard let listingID = req.parameters.get("listingID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid listing ID")
        }

        guard let listing = try await Listing.find(listingID, on: req.db) else {
            throw Abort(.notFound, reason: "Listing not found")
        }

        let seller = try await listing.$seller.get(on: req.db)
        return try ListingResponse(listing: listing, seller: seller)
    }

    func getAll(req: Request) async throws -> PagedListingResponse {
        let page = req.query[Int.self, at: "page"] ?? 1
        guard page > 0 else {
            throw Abort(.badRequest, reason: "Page must be greater than 0")
        }
        let requestedCategory = req.query[String.self, at: "category"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let requestedQuery = req.query[String.self, at: "query"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        let pageSize = 20
        let offset = (page - 1) * pageSize

        let allListings = try await Listing.query(on: req.db)
            .with(\.$seller)
            .all()

        let filteredListings = allListings.filter { listing in
            let matchesCategory: Bool
            if let requestedCategory, !requestedCategory.isEmpty {
                matchesCategory = listing.category.lowercased() == requestedCategory.lowercased()
            } else {
                matchesCategory = true
            }

            let matchesQuery: Bool
            if let requestedQuery, !requestedQuery.isEmpty {
                let title = listing.title.lowercased()
                let description = listing.description.lowercased()
                matchesQuery = title.contains(requestedQuery) || description.contains(requestedQuery)
            } else {
                matchesQuery = true
            }

            return matchesCategory && matchesQuery
        }

        let totalCount = filteredListings.count
        let totalPages = (totalCount + pageSize - 1) / pageSize

        let pageListings: ArraySlice<Listing>
        if offset >= totalCount {
            pageListings = []
        } else {
            pageListings = filteredListings[offset..<min(offset + pageSize, totalCount)]
        }

        let items = try pageListings.map { listing in
            return try ListingResponse(listing: listing, seller: listing.seller)
        }
        
        return PagedListingResponse(items: items, page: page, totalPages: totalPages, totalCount: totalCount)
    }

    func getByCategory(req: Request) async throws -> [ListingResponse] {
        guard let category = req.parameters.get("category") else {
            throw Abort(.badRequest, reason: "Missing category parameter")
        }

        let listings = try await Listing.query(on: req.db)
            .filter(\.$category == category)
            .with(\.$seller)
            .all()

        return try listings.map { listing in
            return try ListingResponse(listing: listing, seller: listing.seller)
        }
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let listingID = req.parameters.get("listingID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid listing ID")
        }

        guard let listing = try await Listing.find(listingID, on: req.db) else {
            throw Abort(.notFound, reason: "Listing not found")
        }

        try await listing.delete(on: req.db)
        return .noContent
    }
}