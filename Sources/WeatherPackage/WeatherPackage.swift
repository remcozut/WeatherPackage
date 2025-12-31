import Foundation

/// WeatherPackage - A Swift Package for fetching weather data
/// Compatible with Kotlin Multiplatform via Objective-C bridge
///
/// This package provides a simple interface to fetch weather information
/// for any location using the Locatie Net weather API.
///
/// Example usage:
/// ```swift
/// WeatherService.shared.fetchWeather(for: "Amsterdam") { weatherData, error in
///     if let weather = weatherData {
///         print("Temperature: \(weather.temperature)°C")
///         print("Condition: \(weather.condition)")
///     } else if let error = error {
///         print("Error: \(error.localizedDescription)")
///     }
/// }
/// ```

// Export main classes for public use
@_exported import Foundation

// Re-export models
public typealias Weather = WeatherData
