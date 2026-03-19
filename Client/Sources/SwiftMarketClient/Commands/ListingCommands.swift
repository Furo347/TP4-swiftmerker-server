import ArgumentParser
import Foundation

struct ListingsCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(commandName: "listings", abstract: "List listings")

	@Option(name: .long, help: "Page number (default: 1)")
	var page: Int = 1

	@Option(name: .long, help: "Optional category filter")
	var category: String?

	@Option(name: .long, help: "Optional query filter")
	var query: String?

	func run() async throws {
		let api = APIClient()
		do {
			let result = try await api.getListings(page: page, category: category, query: query)
			print("Page \(result.page)/\(result.totalPages) - total \(result.totalCount)")
			if result.items.isEmpty {
				print("No listings found.")
				return
			}
			result.items.forEach(printListing)
		} catch {
			handleAPIError(error)
			throw ExitCode.failure
		}
	}
}

struct ListingCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(commandName: "listing", abstract: "Get a listing by ID")

	@Argument(help: "Listing UUID")
	var id: String

	func run() async throws {
		let api = APIClient()
		do {
			guard let listingID = UUID(uuidString: id) else {
				throw APIError.validationFailed("Invalid UUID for listing id")
			}
			let result = try await api.getListing(id: listingID)
			printListing(result)
		} catch {
			handleAPIError(error)
			throw ExitCode.failure
		}
	}
}

struct PostCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(commandName: "post", abstract: "Create a listing")

	@Option(name: .long)
	var title: String

	@Option(name: .long)
	var description: String

	@Option(name: .long)
	var price: Double

	@Option(name: .long)
	var category: String

	@Option(name: .long, help: "Seller UUID")
	var sellerID: String

	func run() async throws {
		let api = APIClient()
		do {
			guard let parsedSellerID = UUID(uuidString: sellerID) else {
				throw APIError.validationFailed("Invalid UUID for sellerID")
			}

			let payload = CreateListingRequest(
				title: title,
				description: description,
				price: price,
				category: category,
				sellerID: parsedSellerID
			)
			let result = try await api.createListing(payload)
			printListing(result)
		} catch {
			handleAPIError(error)
			throw ExitCode.failure
		}
	}
}

struct DeleteCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(commandName: "delete", abstract: "Delete a listing")

	@Argument(help: "Listing UUID")
	var id: String

	func run() async throws {
		let api = APIClient()
		do {
			guard let listingID = UUID(uuidString: id) else {
				throw APIError.validationFailed("Invalid UUID for listing id")
			}
			try await api.deleteListing(id: listingID)
			print("Listing deleted.")
		} catch {
			handleAPIError(error)
			throw ExitCode.failure
		}
	}
}
