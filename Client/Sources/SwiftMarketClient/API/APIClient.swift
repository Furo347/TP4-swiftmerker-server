import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        baseURL: String = "http://localhost:8080",
        session: URLSession = .shared
    ) {
        self.baseURL = URL(string: baseURL) ?? URL(string: "http://localhost:8080")!
        self.session = session

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    func createUser(_ body: CreateUserRequest) async throws -> UserResponse {
        try await post(path: "users", body: body)
    }

    func getUsers() async throws -> [UserResponse] {
        try await get(path: "users")
    }

    func getUser(id: UUID) async throws -> UserResponse {
        try await get(path: "users/\(id.uuidString)")
    }

    func getUserListings(userID: UUID) async throws -> [ListingResponse] {
        try await get(path: "users/\(userID.uuidString)/listings")
    }

    func createListing(_ body: CreateListingRequest) async throws -> ListingResponse {
        try await post(path: "listings", body: body)
    }

    func getListings(page: Int, category: String? = nil, query: String? = nil) async throws -> PagedListingResponse {
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "page", value: String(page))]
        if let category, !category.isEmpty {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        if let query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        return try await get(path: "listings", queryItems: queryItems)
    }

    func getListing(id: UUID) async throws -> ListingResponse {
        try await get(path: "listings/\(id.uuidString)")
    }

    func deleteListing(id: UUID) async throws {
        let request = try makeRequest(path: "listings/\(id.uuidString)", method: "DELETE")
        do {
            let (data, response) = try await session.data(for: request)
            try validate(response: response, data: data)
        } catch {
            throw mapError(error)
        }
    }

    private func get<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        let request = try makeRequest(path: path, method: "GET", queryItems: queryItems)
        do {
            let (data, response) = try await session.data(for: request)
            try validate(response: response, data: data)
            return try decoder.decode(T.self, from: data)
        } catch {
            throw mapError(error)
        }
    }

    private func post<B: Encodable, T: Decodable>(
        path: String,
        body: B
    ) async throws -> T {
        var request = try makeRequest(path: path, method: "POST")
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await session.data(for: request)
            try validate(response: response, data: data)
            return try decoder.decode(T.self, from: data)
        } catch {
            throw mapError(error)
        }
    }

    private func makeRequest(
        path: String,
        method: String,
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        let endpoint = baseURL.appendingPathComponent(path)
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func validate(response: URLResponse, data: Data = Data()) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.serverError("Invalid server response")
        }

        guard (200...299).contains(http.statusCode) else {
            let reason = decodeServerReason(from: data) ?? "HTTP \(http.statusCode)"
            switch http.statusCode {
            case 404:
                throw APIError.notFound(reason)
            case 409:
                throw APIError.conflict(reason)
            case 422:
                throw APIError.validationFailed(reason)
            default:
                throw APIError.serverError(reason)
            }
        }
    }

    private func decodeServerReason(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }
        if let serverError = try? decoder.decode(ServerError.self, from: data),
           let reason = serverError.reason,
           !reason.isEmpty {
            return reason
        }
        if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
            return raw
        }
        return nil
    }

    private func mapError(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }

        if error is DecodingError {
            return .decodingError(error)
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .cannotFindHost, .cannotConnectToHost, .networkConnectionLost, .notConnectedToInternet, .timedOut:
                return .connectionFailed
            default:
                return .serverError(urlError.localizedDescription)
            }
        }

        return .serverError(error.localizedDescription)
    }
}
