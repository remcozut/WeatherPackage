import Foundation
import WeatherPackage

/// Example demonstrating how to use WeatherPackage to fetch weather data

// Example 1: Basic weather fetch
print("Fetching weather for Amsterdam...")
WeatherService.shared.fetchWeather(for: "Amsterdam") { weatherData, error in
    if let weather = weatherData {
        print("\n=== Weather in \(weather.location) ===")
        print("Temperature: \(weather.temperature)°C")
        print("Condition: \(weather.condition)")
        print("Humidity: \(weather.humidity)%")
        print("Wind Speed: \(weather.windSpeed) km/h")
        print("Timestamp: \(weather.timestamp)")
    } else if let error = error {
        print("Error fetching weather: \(error.localizedDescription)")
    }
}

// Example 2: Multiple locations
let locations = ["Amsterdam", "London", "Paris", "New York"]

print("\n\nFetching weather for multiple locations...")
for location in locations {
    WeatherService.shared.fetchWeather(for: location) { weatherData, error in
        if let weather = weatherData {
            print("\(weather.location): \(weather.temperature)°C, \(weather.condition)")
        } else if let error = error {
            print("\(location): Error - \(error.localizedDescription)")
        }
    }
}

// Example 3: Error handling
print("\n\nTesting error handling with invalid location...")
WeatherService.shared.fetchWeather(for: "") { weatherData, error in
    if let error = error as? WeatherError {
        switch error {
        case .invalidLocation:
            print("✓ Invalid location error caught correctly")
        case .networkError:
            print("Network error occurred")
        case .invalidResponse:
            print("Invalid response from server")
        case .parsingError:
            print("Failed to parse weather data")
        case .unknown:
            print("Unknown error occurred")
        }
    }
}

// Keep the program running to allow async callbacks to complete
RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
