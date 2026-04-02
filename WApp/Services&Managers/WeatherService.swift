import Foundation

protocol WeatherServiceProtocol {
    func fetchForecast(
        lat: Double,
        lon: Double,
        days: Int
    ) async throws -> ForecastResponse
}

final class WeatherService: WeatherServiceProtocol {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func fetchForecast(lat: Double, lon: Double, days: Int = 3) async throws -> ForecastResponse {
        let endpoint = WeatherEndpoint.forecast(lat: lat,lon: lon,days: days)
        return try await client.send(endpoint)
    }
}


//import Foundation
//
//final class WeatherService {
//    
//    private let apiKey = "fa8b3df74d4042b9aa7135114252304"
//    private let baseURL = "https://api.weatherapi.com/v1/forecast.json"
//    
//    func fetchWeather(
//        latitude: Double,
//        longitude: Double,
//        days: Int = 3,
//        completion: @escaping (Result<ForecastResponse, Error>) -> Void
//    ) {
//        
//        let urlString = "\(baseURL)?key=\(apiKey)&q=\(latitude),\(longitude)&days=\(days)"
//        
//        guard let url = URL(string: urlString) else {
//            completion(.failure(URLError(.badURL)))
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            
//            if let error = error {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//                return
//            }
//            
//            guard let data = data else {
//                DispatchQueue.main.async {
//                    completion(.failure(URLError(.badServerResponse)))
//                }
//                return
//            }
//            
//            do {
//                let decoded = try JSONDecoder().decode(ForecastResponse.self, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(decoded))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//            
//        }.resume()
//    }
//}
