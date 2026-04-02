import Foundation

struct ForecastResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}

struct Location: Codable {
    let name: String
    let country: String
    let lat: Double
    let lon: Double
}

struct Current: Codable {
    let temp_c: Double
    let condition: Condition
    let wind_kph: Double
    let humidity: Int
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let day: Day
    let hour: [Hour]
}

struct Day: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: Condition
}

struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}

struct Hour: Codable {
    let time: String
    let temp_c: Double
    let condition: Condition
}
