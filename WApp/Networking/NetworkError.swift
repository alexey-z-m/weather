import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decoding(Error)
    case underlying(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error with status code \(code)"
        case .decoding:
            return "Failed to decode response"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
