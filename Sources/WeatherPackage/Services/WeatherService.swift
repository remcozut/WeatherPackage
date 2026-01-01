import Foundation
import Alamofire

/// Weather service to fetch weather data from the API
/// Compatible with Objective-C for use in KMP via Objective-C bridge on Apple platforms
#if canImport(ObjectiveC)
@objc public class WeatherService: NSObject {
    
    /// Base URL for the weather API
    private let baseURL = "http://services.locatienet.com/api/rs/1.0/weather"
    
    /// Shared singleton instance
    @objc public static let shared = WeatherService()
    
    /// Session manager for network requests
    private let session: Session
    
    /// Timer for periodic weather updates
    private var updateTimer: Timer?
    
    /// Current location being observed
    private var observedLocation: String?
    
    /// Update handler for weather observations
    private var updateHandler: ((WeatherData?, Error?) -> Void)?
    
    /// Initialize with default session
    @objc public override init() {
        self.session = Session.default
        super.init()
    }
    
    /// Initialize with custom session (useful for testing)
    init(session: Session) {
        self.session = session
        super.init()
    }
    
    /// Fetch weather data for a given location
    /// - Parameters:
    ///   - location: The location to fetch weather data for
    ///   - completion: Completion handler with WeatherData or Error
    @objc public func fetchWeather(
        for location: String,
        completion: @escaping (WeatherData?, Error?) -> Void
    ) {
        guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(nil, WeatherError.invalidLocation)
            return
        }
        
        let parameters: [String: String] = ["location": location]
        
        session.request(
            baseURL,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
        .validate()
        .responseDecodable(of: WeatherData.self) { response in
            switch response.result {
            case .success(let weatherData):
                completion(weatherData, nil)
                
            case .failure(let error):
                let weatherError = self.mapError(error)
                completion(nil, weatherError)
            }
        }
    }
    
    /// Start observing weather updates for a given location
    /// - Parameters:
    ///   - location: The location to observe weather data for
    ///   - interval: Time interval between updates in seconds (default: 60 seconds)
    ///   - updateHandler: Handler called with each weather update or error
    @objc public func startObservingWeather(
        for location: String,
        interval: TimeInterval = 60.0,
        updateHandler: @escaping (WeatherData?, Error?) -> Void
    ) {
        // Stop any existing observation
        stopObservingWeather()
        
        // Store the location and handler
        observedLocation = location
        self.updateHandler = updateHandler
        
        // Fetch immediately
        fetchWeather(for: location, completion: updateHandler)
        
        // Set up timer for periodic updates
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            self?.fetchWeather(for: location, completion: updateHandler)
        }
    }
    
    /// Stop observing weather updates
    @objc public func stopObservingWeather() {
        updateTimer?.invalidate()
        updateTimer = nil
        observedLocation = nil
        updateHandler = nil
    }
    
    /// Check if currently observing weather updates
    @objc public var isObserving: Bool {
        return updateTimer != nil && observedLocation != nil
    }
    
    /// Map Alamofire errors to WeatherError
    private func mapError(_ error: AFError) -> Error {
        if error.isResponseValidationError {
            return WeatherError.invalidResponse
        } else if error.isResponseSerializationError {
            return WeatherError.parsingError
        } else if error.isSessionTaskError {
            return WeatherError.networkError
        } else {
            return WeatherError.unknown
        }
    }
}
#else
// Non-Apple platforms (Linux, etc.) - regular Swift class without Objective-C interop
public class WeatherService {
    
    /// Base URL for the weather API
    private let baseURL = "http://services.locatienet.com/api/rs/1.0/weather"
    
    /// Shared singleton instance
    public static let shared = WeatherService()
    
    /// Session manager for network requests
    private let session: Session
    
    /// Timer for periodic weather updates
    private var updateTimer: Timer?
    
    /// Current location being observed
    private var observedLocation: String?
    
    /// Update handler for weather observations
    private var updateHandler: ((WeatherData?, Error?) -> Void)?
    
    /// Initialize with default session
    public init() {
        self.session = Session.default
    }
    
    /// Initialize with custom session (useful for testing)
    init(session: Session) {
        self.session = session
    }
    
    /// Fetch weather data for a given location
    /// - Parameters:
    ///   - location: The location to fetch weather data for
    ///   - completion: Completion handler with WeatherData or Error
    public func fetchWeather(
        for location: String,
        completion: @escaping (WeatherData?, Error?) -> Void
    ) {
        guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(nil, WeatherError.invalidLocation)
            return
        }
        
        let parameters: [String: String] = ["location": location]
        
        session.request(
            baseURL,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
        .validate()
        .responseDecodable(of: WeatherData.self) { response in
            switch response.result {
            case .success(let weatherData):
                completion(weatherData, nil)
                
            case .failure(let error):
                let weatherError = self.mapError(error)
                completion(nil, weatherError)
            }
        }
    }
    
    /// Start observing weather updates for a given location
    /// - Parameters:
    ///   - location: The location to observe weather data for
    ///   - interval: Time interval between updates in seconds (default: 60 seconds)
    ///   - updateHandler: Handler called with each weather update or error
    public func startObservingWeather(
        for location: String,
        interval: TimeInterval = 60.0,
        updateHandler: @escaping (WeatherData?, Error?) -> Void
    ) {
        // Stop any existing observation
        stopObservingWeather()
        
        // Store the location and handler
        observedLocation = location
        self.updateHandler = updateHandler
        
        // Fetch immediately
        fetchWeather(for: location, completion: updateHandler)
        
        // Set up timer for periodic updates
        updateTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            self?.fetchWeather(for: location, completion: updateHandler)
        }
    }
    
    /// Stop observing weather updates
    public func stopObservingWeather() {
        updateTimer?.invalidate()
        updateTimer = nil
        observedLocation = nil
        updateHandler = nil
    }
    
    /// Check if currently observing weather updates
    public var isObserving: Bool {
        return updateTimer != nil && observedLocation != nil
    }
    
    /// Map Alamofire errors to WeatherError
    private func mapError(_ error: AFError) -> Error {
        if error.isResponseValidationError {
            return WeatherError.invalidResponse
        } else if error.isResponseSerializationError {
            return WeatherError.parsingError
        } else if error.isSessionTaskError {
            return WeatherError.networkError
        } else {
            return WeatherError.unknown
        }
    }
}
#endif

