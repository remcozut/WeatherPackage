# Changelog

All notable changes to WeatherPackage will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-31

### Added
- Initial release of WeatherPackage
- `WeatherService` class with singleton pattern for fetching weather data
- `WeatherData` model representing weather information (temperature, condition, humidity, wind speed, location, timestamp)
- `WeatherError` enum for typed error handling
- Full Objective-C compatibility for Kotlin Multiplatform (KMP) integration via `@objc` annotations
- Platform-specific implementations (iOS/macOS with Objective-C bridge, Linux without)
- Comprehensive unit test coverage
- Integration with Alamofire for robust HTTP networking
- Support for iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+
- Cross-platform support including Linux
- Comprehensive documentation including README and KMP integration guide
- Usage examples demonstrating basic and advanced scenarios
- Error handling for network errors, invalid locations, parsing errors, and more
- Codable conformance for easy JSON serialization/deserialization

### Features
- Fetch weather data by location name
- Automatic retry and error handling via Alamofire
- Thread-safe singleton instance
- Flexible timestamp parsing (ISO8601 string or Unix timestamp)
- Localized error descriptions

### Documentation
- README with installation and usage instructions
- KMP_INTEGRATION guide for Kotlin Multiplatform developers
- Example code demonstrating common use cases
- API documentation in source code

### Dependencies
- Alamofire 5.6.0+
- Swift Algorithms 1.0.0+

[1.0.0]: https://github.com/remcozut/WeatherPackage/releases/tag/1.0.0
