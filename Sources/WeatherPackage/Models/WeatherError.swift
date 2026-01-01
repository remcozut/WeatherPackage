import Foundation

/// Weather service error types compatible with Objective-C for KMP bridge
@objc public enum WeatherError: Int, Error {
    /// Network connectivity error
    case networkError = 0
    
    /// Invalid location provided
    case invalidLocation = 1
    
    /// API returned invalid response
    case invalidResponse = 2
    
    /// Failed to parse response data
    case parsingError = 3
    
    /// Unknown error occurred
    case unknown = 4
}

/// Extension to provide localized descriptions
extension WeatherError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error occurred while fetching weather data"
        case .invalidLocation:
            return "Invalid location provided"
        case .invalidResponse:
            return "Invalid response from weather service"
        case .parsingError:
            return "Failed to parse weather data"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
