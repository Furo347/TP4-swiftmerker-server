import Foundation

func printError(_ message: String) {
    fputs("\(message)\n", stderr)
}

func handleAPIError(_ error: Error) {
    if let apiErr = error as? APIError {
        printError(apiErr.message)
    } else {
        printError("Error: \(error.localizedDescription)")
    }
}

func printSeparator(_ count: Int = 65) {
    print(String(repeating: "-", count: count))
}

func pad(_ value: String, _ width: Int) -> String {
    if value.count >= width {
        return String(value.prefix(width))
    }
    return value + String(repeating: " ", count: width - value.count)
}

func formatDate(_ date: Date?) -> String {
    guard let date else { return "N/A" }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func formatPrice(_ value: Double) -> String {
    String(format: "%.2fEUR", value)
}

func printUserCreated(_ user: UserResponse) {
    print("User created successfully.")
    print("ID:       \(user.id.uuidString)")
    print("Username: \(user.username)")
    print("Email:    \(user.email)")
}

func printUsersTable(_ users: [UserResponse]) {
    print("Users (\(users.count))")
    printSeparator()
    print("\(pad("ID", 36))  \(pad("Username", 10))  Email")
    for user in users {
        print("\(pad(user.id.uuidString, 36))  \(pad(user.username, 10))  \(user.email)")
    }
}

func printUserDetails(_ user: UserResponse) {
    print(user.username)
    print("Email:        \(user.email)")
    print("Member since: \(formatDate(user.createdAt))")
}

func printListingCreated(_ listing: ListingResponse) {
    print("Listing created successfully.")
    print("ID:          \(listing.id.uuidString)")
    print("Title:       \(listing.title)")
    print("Price:       \(formatPrice(listing.price))")
    print("Category:    \(listing.category)")
}

func printListingsPage(_ page: PagedListingResponse) {
    print("Listings (page \(page.page)/\(page.totalPages) - \(page.totalCount) results)")
    printSeparator()
    print("\(pad("ID", 36))  \(pad("Title", 18))  \(pad("Price", 9))  \(pad("Category", 12))  Seller")
    for listing in page.items {
        let title = String(listing.title.prefix(18))
        print("\(pad(listing.id.uuidString, 36))  \(pad(title, 18))  \(pad(formatPrice(listing.price), 9))  \(pad(listing.category, 12))  \(listing.seller.username)")
    }
    if page.page < page.totalPages {
        printSeparator()
        print("Next page: swiftmarket listings --page \(page.page + 1)")
    }
}

func printFilteredListings(_ listings: [ListingResponse]) {
    print("Listings (\(listings.count) results)")
    printSeparator()
    print("\(pad("ID", 36))  \(pad("Title", 18))  \(pad("Price", 9))  \(pad("Category", 12))  Seller")
    for listing in listings {
        let title = String(listing.title.prefix(18))
        print("\(pad(listing.id.uuidString, 36))  \(pad(title, 18))  \(pad(formatPrice(listing.price), 9))  \(pad(listing.category, 12))  \(listing.seller.username)")
    }
}

func printListingDetails(_ listing: ListingResponse) {
    print(listing.title)
    printSeparator(41)
    print("Price:       \(formatPrice(listing.price))")
    print("Category:    \(listing.category)")
    print("Description: \(listing.description)")
    print("Seller:      \(listing.seller.username) (\(listing.seller.email))")
    print("Posted:      \(formatDate(listing.createdAt))")
}

func printUserListings(_ username: String, _ listings: [ListingResponse]) {
    print("Listings by \(username) (\(listings.count))")
    printSeparator()
    print("\(pad("ID", 36))  \(pad("Title", 18))  \(pad("Price", 9))  Category")
    for listing in listings {
        let title = String(listing.title.prefix(18))
        print("\(pad(listing.id.uuidString, 36))  \(pad(title, 18))  \(pad(formatPrice(listing.price), 9))  \(listing.category)")
    }
}
