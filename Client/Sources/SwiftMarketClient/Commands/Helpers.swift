import Foundation

func printError(_ message: String) {
    fputs("\(message)\n", stderr)
}

func handleAPIError(_ error: Error) {
    if let apiErr = error as? APIError {
        printError(apiErr.message)
    } else {
        printError(error.localizedDescription)
    }
}

func printUser(_ user: UserResponse) {
    print("\(user.id.uuidString) | \(user.username) | \(user.email)")
}

func printListing(_ listing: ListingResponse) {
    print("\(listing.id.uuidString) | \(listing.title) | \(listing.category) | \(listing.price)")
}
