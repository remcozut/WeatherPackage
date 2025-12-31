import XCTest
@testable import WeatherPackage

final class WeatherPackageTests: XCTestCase {
    
    func testWeatherDataInitialization() {
        // Test that WeatherData can be initialized with valid data
        let timestamp = Date()
        let weatherData = WeatherData(
            location: "Amsterdam",
            temperature: 20.5,
            condition: "Sunny",
            humidity: 65.0,
            windSpeed: 15.5,
            timestamp: timestamp
        )
        
        XCTAssertEqual(weatherData.location, "Amsterdam")
        XCTAssertEqual(weatherData.temperature, 20.5)
        XCTAssertEqual(weatherData.condition, "Sunny")
        XCTAssertEqual(weatherData.humidity, 65.0)
        XCTAssertEqual(weatherData.windSpeed, 15.5)
        XCTAssertEqual(weatherData.timestamp, timestamp)
    }
    
    func testWeatherDataCodable() throws {
        // Test that WeatherData can be encoded and decoded
        let timestamp = Date()
        let originalData = WeatherData(
            location: "London",
            temperature: 15.0,
            condition: "Cloudy",
            humidity: 70.0,
            windSpeed: 10.0,
            timestamp: timestamp
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(originalData)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(WeatherData.self, from: encoded)
        
        XCTAssertEqual(decoded.location, originalData.location)
        XCTAssertEqual(decoded.temperature, originalData.temperature)
        XCTAssertEqual(decoded.condition, originalData.condition)
        XCTAssertEqual(decoded.humidity, originalData.humidity)
        XCTAssertEqual(decoded.windSpeed, originalData.windSpeed)
    }
    
    func testWeatherDataObjectiveCCompatibility() {
        // Test that WeatherData is compatible with Objective-C
        let weatherData = WeatherData(
            location: "Paris",
            temperature: 18.0,
            condition: "Rainy",
            humidity: 80.0,
            windSpeed: 20.0,
            timestamp: Date()
        )
        
        #if canImport(ObjectiveC)
        // Verify it's an NSObject subclass on platforms with Objective-C
        XCTAssertTrue(weatherData is NSObject)
        #endif
        
        // Verify properties are accessible (would be accessible from Obj-C)
        XCTAssertNotNil(weatherData.location)
        XCTAssertNotNil(weatherData.condition)
    }
    
    func testWeatherServiceSharedInstance() {
        // Test that shared instance is accessible
        let service = WeatherService.shared
        XCTAssertNotNil(service)
        
        // Verify it's the same instance
        let service2 = WeatherService.shared
        XCTAssertTrue(service === service2)
    }
    
    func testWeatherServiceInvalidLocation() {
        // Test that service handles invalid location
        let expectation = self.expectation(description: "Invalid location should return error")
        
        WeatherService.shared.fetchWeather(for: "") { weatherData, error in
            XCTAssertNil(weatherData)
            XCTAssertNotNil(error)
            
            if let weatherError = error as? WeatherError {
                XCTAssertEqual(weatherError, .invalidLocation)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testWeatherServiceWhitespaceLocation() {
        // Test that service handles whitespace-only location
        let expectation = self.expectation(description: "Whitespace location should return error")
        
        WeatherService.shared.fetchWeather(for: "   ") { weatherData, error in
            XCTAssertNil(weatherData)
            XCTAssertNotNil(error)
            
            if let weatherError = error as? WeatherError {
                XCTAssertEqual(weatherError, .invalidLocation)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testWeatherErrorLocalizedDescriptions() {
        // Test that all error types have localized descriptions
        XCTAssertFalse(WeatherError.networkError.errorDescription?.isEmpty ?? true)
        XCTAssertFalse(WeatherError.invalidLocation.errorDescription?.isEmpty ?? true)
        XCTAssertFalse(WeatherError.invalidResponse.errorDescription?.isEmpty ?? true)
        XCTAssertFalse(WeatherError.parsingError.errorDescription?.isEmpty ?? true)
        XCTAssertFalse(WeatherError.unknown.errorDescription?.isEmpty ?? true)
    }
}
