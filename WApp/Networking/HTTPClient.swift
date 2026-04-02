import Foundation

protocol HTTPClient {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }
    
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        
        guard let request = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decoding(error)
            }
            
        } catch {
            throw NetworkError.underlying(error)
        }
    }
}
