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

// Example 4: Observing weather updates
print("\n\nStarting weather observation for Berlin (updates every 5 seconds)...")
var updateCount = 0
WeatherService.shared.startObservingWeather(
    for: "Berlin",
    interval: 5.0
) { weatherData, error in
    updateCount += 1
    if let weather = weatherData {
        print("Update #\(updateCount): \(weather.location) - \(weather.temperature)°C at \(weather.timestamp)")
    } else if let error = error {
        print("Update #\(updateCount): Error - \(error.localizedDescription)")
    }
    
    // Stop after 3 updates
    if updateCount >= 3 {
        print("\nStopping weather observation...")
        WeatherService.shared.stopObservingWeather()
        print("Observation stopped. isObserving: \(WeatherService.shared.isObserving)")
    }
}

print("Observation started. isObserving: \(WeatherService.shared.isObserving)")

// Keep the program running to allow async callbacks to complete
RunLoop.main.run(until: Date(timeIntervalSinceNow: 20))
