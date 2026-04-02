import Foundation

enum WeatherEndpoint: Endpoint {
    
    case forecast(lat: Double, lon: Double, days: Int)
    
    var host: String { "api.weatherapi.com" }
    
    var path: String {
        switch self {
        case .forecast:
            return "/v1/forecast.json"
        }
    }
    
    var queryItems: [URLQueryItem] {
        let apiKey = "fa8b3df74d4042b9aa7135114252304"
        
        switch self {
        case .forecast(let lat, let lon, let days):
            return [
                URLQueryItem(name: "key", value: apiKey),
                URLQueryItem(name: "q", value: "\(lat),\(lon)"),
                URLQueryItem(name: "days", value: "\(days)"),
                URLQueryItem(name: "lang", value: "en")
            ]
        }
    }
}
