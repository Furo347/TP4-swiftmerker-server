import ArgumentParser
import Foundation

struct CreateUserCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(commandName: "create-user", abstract: "Create a new user")

	@Option(name: .long)
	var username: String

	@Option(name: .long)
	var email: String

	func run() async throws {
		let api = APIClient()
		do {
			let result = try await api.createUser(CreateUserRequest(username: username, email: email))
			printUserCreated(result)
		} catch {
			handleAPIError(error)
			throw ExitCode.failure
		}
	}
}

struct UsersCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(commandName: "users", abstract: "List users")

	func run() async throws {
		let api = APIClient()
		do {
			let result = try await api.getUsers()
			if result.isEmpty {
				print("No users found.")
				return
			}
			printUsersTable(result)
		} catch {
			handleAPIError(error)
			throw ExitCode.failure
		}
	}
}

struct UserCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(commandName: "user", abstract: "Get a user by ID")

	@Argument(help: "User UUID")
	var id: String

	func run() async throws {
		let api = APIClient()
		do {
			guard let userID = UUID(uuidString: id) else {
				throw APIError.validationFailed("Invalid UUID for user id")
			}
			let result = try await api.getUser(id: userID)
			printUserDetails(result)
		} catch {
			handleAPIError(error)
			throw ExitCode.failure
		}
	}
}

struct UserListingsCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(commandName: "user-listings", abstract: "List listings for a user")

	@Argument(help: "User UUID")
	var userID: String

	func run() async throws {
		let api = APIClient()
		do {
			guard let parsedUserID = UUID(uuidString: userID) else {
				throw APIError.validationFailed("Invalid UUID for user id")
			}
			let result = try await api.getUserListings(userID: parsedUserID)
			if result.isEmpty {
				print("No listings found.")
				return
			}
			let ownerName = result.first?.seller.username ?? "user"
			printUserListings(ownerName, result)
		} catch {
			handleAPIError(error)
			throw ExitCode.failure
		}
	}
}
