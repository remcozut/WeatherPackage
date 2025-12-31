# WeatherPackage

A Swift Package for fetching weather data that is compatible with Kotlin Multiplatform (KMP) via Objective-C bridge.

## Features

- ✅ Fetch weather information for any location
- ✅ Observe real-time weather updates with configurable intervals
- ✅ Compatible with Objective-C for use in KMP projects
- ✅ Built with Alamofire for robust networking
- ✅ Cross-platform support (iOS, macOS, tvOS, watchOS, Linux)
- ✅ Type-safe weather data models
- ✅ Comprehensive error handling

## Requirements

- Swift 5.5+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/remcozut/WeatherPackage.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Packages...
2. Enter the repository URL: `https://github.com/remcozut/WeatherPackage.git`
3. Click "Add Package"

## Usage

### Swift

#### One-time Fetch

```swift
import WeatherPackage

// Fetch weather for a location
WeatherService.shared.fetchWeather(for: "Amsterdam") { weatherData, error in
    if let weather = weatherData {
        print("Location: \(weather.location)")
        print("Temperature: \(weather.temperature)°C")
        print("Condition: \(weather.condition)")
        print("Humidity: \(weather.humidity)%")
        print("Wind Speed: \(weather.windSpeed) km/h")
    } else if let error = error {
        print("Error: \(error.localizedDescription)")
    }
}
```

#### Observe Weather Updates

```swift
import WeatherPackage

// Start observing weather updates every 60 seconds
WeatherService.shared.startObservingWeather(
    for: "Amsterdam",
    interval: 60.0
) { weatherData, error in
    if let weather = weatherData {
        print("Updated temperature: \(weather.temperature)°C")
    }
}

// Check if currently observing
if WeatherService.shared.isObserving {
    print("Currently observing weather updates")
}

// Stop observing when done
WeatherService.shared.stopObservingWeather()
```

### Kotlin Multiplatform (via Objective-C bridge)

On Apple platforms, the package is fully compatible with Objective-C, making it accessible from Kotlin Multiplatform projects:

#### One-time Fetch

```kotlin
// iOS source set
WeatherService.shared().fetchWeather(for = "Amsterdam") { weatherData, error ->
    weatherData?.let {
        println("Location: ${it.location}")
        println("Temperature: ${it.temperature}°C")
        println("Condition: ${it.condition}")
        println("Humidity: ${it.humidity}%")
        println("Wind Speed: ${it.windSpeed} km/h")
    }
    error?.let {
        println("Error: ${it.localizedDescription}")
    }
}
```

#### Observe Weather Updates

```kotlin
// Start observing weather updates every 60 seconds
WeatherService.shared().startObservingWeather(
    for = "Amsterdam",
    interval = 60.0
) { weatherData, error ->
    weatherData?.let {
        println("Updated temperature: ${it.temperature}°C")
    }
}

// Check if currently observing
if (WeatherService.shared().isObserving) {
    println("Currently observing weather updates")
}

// Stop observing when done
WeatherService.shared().stopObservingWeather()
```

## API

### WeatherService

The main service class for fetching weather data.

#### Properties

- `shared`: Singleton instance of WeatherService
- `isObserving`: Boolean indicating whether weather updates are currently being observed

#### Methods

- `fetchWeather(for location: String, completion: @escaping (WeatherData?, Error?) -> Void)`
  - Fetches weather data for the specified location once
  - Parameters:
    - `location`: The name of the location (e.g., "Amsterdam", "New York")
    - `completion`: Completion handler called with either weather data or an error

- `startObservingWeather(for location: String, interval: TimeInterval = 60.0, updateHandler: @escaping (WeatherData?, Error?) -> Void)`
  - Starts observing weather updates for a location at regular intervals
  - Parameters:
    - `location`: The name of the location to observe
    - `interval`: Time interval between updates in seconds (default: 60 seconds)
    - `updateHandler`: Handler called with each weather update or error
  - Note: Calling this method while already observing will stop the previous observation

- `stopObservingWeather()`
  - Stops the current weather observation
  - Cleans up timers and handlers

### WeatherData

Model representing weather information.

#### Properties

- `location: String` - Name of the location
- `temperature: Double` - Temperature in Celsius
- `condition: String` - Weather condition description
- `humidity: Double` - Humidity percentage
- `windSpeed: Double` - Wind speed in km/h
- `timestamp: Date` - Timestamp of the weather data

### WeatherError

Error types that can occur when fetching weather data.

#### Cases

- `networkError` - Network connectivity error
- `invalidLocation` - Invalid location provided
- `invalidResponse` - API returned invalid response
- `parsingError` - Failed to parse response data
- `unknown` - Unknown error occurred

## API Endpoint

This package uses the Locatie Net Weather API:
- Base URL: `http://services.locatienet.com/api/rs/1.0/weather`
- Query parameter: `location` - The location to fetch weather data for

## Platform Support

The package is designed to work across platforms:

- **Apple Platforms** (iOS, macOS, tvOS, watchOS): Full support with Objective-C interoperability for KMP
- **Linux**: Full Swift support (without Objective-C interoperability)

## Dependencies

- [Alamofire](https://github.com/Alamofire/Alamofire) (5.6.0+) - HTTP networking library
- [Swift Algorithms](https://github.com/apple/swift-algorithms) (1.0.0+) - Swift algorithms and data structures

## Testing

Run the test suite:

```bash
swift test
```

## License

[Add your license information here]

## Author

[Add your author information here]
