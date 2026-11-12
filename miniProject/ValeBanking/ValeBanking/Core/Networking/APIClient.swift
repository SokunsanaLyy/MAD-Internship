//
//  APIClient.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 1/11/2026.
//
import Foundation

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - APIError

enum APIError: LocalizedError {
    case network
    case unauthorized(String)
    case server(statusCode: Int, message: String?)
    case decoding
    
    var errorDescription: String? {
        switch self {
        case .network:
            return "Can't reach Vale right now. Check your connection and try again."
        case .unauthorized(let message):
            return message
        case .server(let code, let message):
            return message ?? "Something went wrong on our side (error \(code)). Please try again."
        case .decoding:
            return "We couldn't read the response from the server."
        }
    }
}

// MARK: - APIClient

final class APIClient {
    
    static let shared = APIClient()
    
    var onUnauthorized: (() -> Void)?
    
    private let baseURL = AppConfig.apiBaseURL
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = AppConfig.requestTimeout
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        return URLSession(configuration: config)
    }()
    
    private init() {}
    
    //MARK: - Public
    func get<Response: Decodable>(_ path: String) async throws -> Response {
        let request = makeRequest(.get, path, authorized: true)
        return try decode(try await perform(request, authorized: true))
    }
    
    func send<Body: Encodable, Response: Decodable>(_ method: HTTPMethod,
                                                     _ path: String,
                                                     body: Body,
                                                     authorized: Bool = true,
                                                     headers: [String: String] = [:]) async throws -> Response {
        var request = makeRequest(method, path, authorized: authorized, headers: headers)
        request.httpBody = try? JSONEncoder().encode(body)
        return try decode(try await perform(request, authorized: authorized))
    }
    
    /// For endpoints that return no body (204), like logout.
    func sendWithoutResponse(_ method: HTTPMethod, _ path: String) async throws {
        _ = try await perform(makeRequest(method, path, authorized: true), authorized: true)
    }

    // MARK: - Private

    private func makeRequest(_ method: HTTPMethod,
                             _ path: String,
                             authorized: Bool,
                             headers: [String: String] = [:]) -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if authorized, let token = KeychainStore.read(KeychainKey.accessToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        return request
    }

    private func perform(_ request: URLRequest, authorized: Bool) async throws -> Data {
        // 1. Send (throws only when the network fails)
        let result: (Data, URLResponse)
        do {
            result = try await session.data(for: request)
        } catch {
            throw APIError.network
        }
        let (data, response) = result

        guard let http = response as? HTTPURLResponse else {
            throw APIError.server(statusCode: -1, message: nil)
        }

        #if DEBUG
        // Log only method, path and status. Never log tokens, passwords or response bodies.
        print("[API] \(request.httpMethod ?? "") /\(request.url?.lastPathComponent ?? "") → \(http.statusCode)")
        #endif

        // 2. Check the status code
        switch http.statusCode {
        case 200...299:
            return data
        case 401:
            let message = errorMessage(from: data) ?? "Please sign in again."
            if authorized { onUnauthorized?() }      // expired or invalid token → log out
            throw APIError.unauthorized(message)
        default:
            throw APIError.server(statusCode: http.statusCode, message: errorMessage(from: data))
        }
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    private func errorMessage(from data: Data) -> String? {
        (try? JSONDecoder().decode(APIErrorBody.self, from: data))?.message
    }
}
