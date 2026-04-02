import Foundation
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {
    
    @Published private(set) var forecast: ForecastResponse?
    @Published private(set) var errorMessage: String?
    
    private let service: WeatherServiceProtocol
    
    init(service: WeatherServiceProtocol) {
        self.service = service
    }
    
    func load(lat: Double, lon: Double) async {
        do {
            forecast = try await service.fetchForecast(
                lat: lat,
                lon: lon,
                days: 3
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
