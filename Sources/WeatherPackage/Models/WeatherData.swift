import Foundation

/// Weather data model compatible with Objective-C for KMP bridge on Apple platforms
#if canImport(ObjectiveC)
@objc public class WeatherData: NSObject, Codable {
    /// Location name
    @objc public let location: String
    
    /// Temperature in Celsius
    @objc public let temperature: Double
    
    /// Weather condition description
    @objc public let condition: String
    
    /// Humidity percentage
    @objc public let humidity: Double
    
    /// Wind speed in km/h
    @objc public let windSpeed: Double
    
    /// Timestamp of the weather data
    @objc public let timestamp: Date
    
    private enum CodingKeys: String, CodingKey {
        case location
        case temperature
        case condition
        case humidity
        case windSpeed = "wind_speed"
        case timestamp
    }
    
    @objc public init(
        location: String,
        temperature: Double,
        condition: String,
        humidity: Double,
        windSpeed: Double,
        timestamp: Date
    ) {
        self.location = location
        self.temperature = temperature
        self.condition = condition
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.timestamp = timestamp
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        location = try container.decode(String.self, forKey: .location)
        temperature = try container.decode(Double.self, forKey: .temperature)
        condition = try container.decode(String.self, forKey: .condition)
        humidity = try container.decode(Double.self, forKey: .humidity)
        windSpeed = try container.decode(Double.self, forKey: .windSpeed)
        
        // Handle timestamp as either ISO8601 string or Unix timestamp
        if let timestampString = try? container.decode(String.self, forKey: .timestamp) {
            let formatter = ISO8601DateFormatter()
            timestamp = formatter.date(from: timestampString) ?? Date()
        } else if let timestampDouble = try? container.decode(Double.self, forKey: .timestamp) {
            timestamp = Date(timeIntervalSince1970: timestampDouble)
        } else {
            timestamp = Date()
        }
        
        super.init()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location, forKey: .location)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(condition, forKey: .condition)
        try container.encode(humidity, forKey: .humidity)
        try container.encode(windSpeed, forKey: .windSpeed)
        try container.encode(timestamp.timeIntervalSince1970, forKey: .timestamp)
    }
}
#else
// Non-Apple platforms (Linux, etc.) - regular Swift class without Objective-C interop
public class WeatherData: Codable {
    /// Location name
    public let location: String
    
    /// Temperature in Celsius
    public let temperature: Double
    
    /// Weather condition description
    public let condition: String
    
    /// Humidity percentage
    public let humidity: Double
    
    /// Wind speed in km/h
    public let windSpeed: Double
    
    /// Timestamp of the weather data
    public let timestamp: Date
    
    private enum CodingKeys: String, CodingKey {
        case location
        case temperature
        case condition
        case humidity
        case windSpeed = "wind_speed"
        case timestamp
    }
    
    public init(
        location: String,
        temperature: Double,
        condition: String,
        humidity: Double,
        windSpeed: Double,
        timestamp: Date
    ) {
        self.location = location
        self.temperature = temperature
        self.condition = condition
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.timestamp = timestamp
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        location = try container.decode(String.self, forKey: .location)
        temperature = try container.decode(Double.self, forKey: .temperature)
        condition = try container.decode(String.self, forKey: .condition)
        humidity = try container.decode(Double.self, forKey: .humidity)
        windSpeed = try container.decode(Double.self, forKey: .windSpeed)
        
        // Handle timestamp as either ISO8601 string or Unix timestamp
        if let timestampString = try? container.decode(String.self, forKey: .timestamp) {
            let formatter = ISO8601DateFormatter()
            timestamp = formatter.date(from: timestampString) ?? Date()
        } else if let timestampDouble = try? container.decode(Double.self, forKey: .timestamp) {
            timestamp = Date(timeIntervalSince1970: timestampDouble)
        } else {
            timestamp = Date()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(location, forKey: .location)
        try container.encode(temperature, forKey: .temperature)
        try container.encode(condition, forKey: .condition)
        try container.encode(humidity, forKey: .humidity)
        try container.encode(windSpeed, forKey: .windSpeed)
        try container.encode(timestamp.timeIntervalSince1970, forKey: .timestamp)
    }
}
#endif

