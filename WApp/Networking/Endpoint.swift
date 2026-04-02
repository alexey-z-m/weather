import Foundation

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    
    var scheme: String { "https" }
    var method: String { "GET" }
    
    var urlRequest: URLRequest? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        
        return request
    }
}
