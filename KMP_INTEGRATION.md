# Kotlin Multiplatform Integration Guide

This guide explains how to use WeatherPackage in a Kotlin Multiplatform (KMP) project.

## Overview

WeatherPackage is designed to be fully compatible with Kotlin Multiplatform through Objective-C interoperability on Apple platforms. The package uses `@objc` annotations to expose Swift classes and methods to Objective-C, which can then be consumed from Kotlin/Native.

## Prerequisites

- Kotlin Multiplatform Mobile (KMM) or Kotlin Multiplatform project
- Xcode 13+ for iOS development
- CocoaPods or Swift Package Manager integration

## Integration Steps

### 1. Add WeatherPackage to Your iOS Project

#### Option A: Using Swift Package Manager

Add the package to your Xcode project:

1. Open your `.xcodeproj` or `.xcworkspace`
2. File → Add Packages...
3. Enter: `https://github.com/remcozut/WeatherPackage.git`
4. Select version and add to your iOS framework target

#### Option B: Using CocoaPods

If you're using CocoaPods for your KMP project, add to your Podfile:

```ruby
pod 'WeatherPackage', :git => 'https://github.com/remcozut/WeatherPackage.git'
```

### 2. Configure Kotlin/Native Interop

The WeatherPackage classes are automatically exposed to Objective-C on Apple platforms, making them accessible from Kotlin/Native without additional configuration.

### 3. Usage in Kotlin Multiplatform

#### iOS Source Set (iosMain)

```kotlin
// File: shared/src/iosMain/kotlin/com/example/WeatherRepository.kt

import WeatherPackage.WeatherService
import WeatherPackage.WeatherData
import WeatherPackage.WeatherError
import platform.Foundation.NSError

actual class WeatherRepository {
    
    actual suspend fun fetchWeather(location: String): Result<Weather> {
        return suspendCoroutine { continuation ->
            WeatherService.shared.fetchWeather(location) { weatherData, error ->
                when {
                    weatherData != null -> {
                        val weather = Weather(
                            location = weatherData.location,
                            temperature = weatherData.temperature,
                            condition = weatherData.condition,
                            humidity = weatherData.humidity,
                            windSpeed = weatherData.windSpeed,
                            timestamp = weatherData.timestamp.timeIntervalSince1970.toLong()
                        )
                        continuation.resume(Result.success(weather))
                    }
                    error != null -> {
                        continuation.resume(Result.failure(
                            Exception(error.localizedDescription)
                        ))
                    }
                    else -> {
                        continuation.resume(Result.failure(
                            Exception("Unknown error occurred")
                        ))
                    }
                }
            }
        }
    }
}
```

#### Common Source Set (commonMain)

Define the expected interface:

```kotlin
// File: shared/src/commonMain/kotlin/com/example/WeatherRepository.kt

expect class WeatherRepository {
    suspend fun fetchWeather(location: String): Result<Weather>
}

data class Weather(
    val location: String,
    val temperature: Double,
    val condition: String,
    val humidity: Double,
    val windSpeed: Double,
    val timestamp: Long
)
```

#### Android Source Set (androidMain)

Implement the Android version using your preferred networking library:

```kotlin
// File: shared/src/androidMain/kotlin/com/example/WeatherRepository.kt

actual class WeatherRepository {
    actual suspend fun fetchWeather(location: String): Result<Weather> {
        // Android implementation using Retrofit, Ktor, etc.
        // ...
    }
}
```

### 4. Using the Repository in Your App

#### In a Kotlin Multiplatform ViewModel

```kotlin
class WeatherViewModel {
    private val repository = WeatherRepository()
    
    suspend fun loadWeather(location: String) {
        repository.fetchWeather(location)
            .onSuccess { weather ->
                // Update UI state
                println("Temperature: ${weather.temperature}°C")
                println("Condition: ${weather.condition}")
            }
            .onFailure { error ->
                // Handle error
                println("Error: ${error.message}")
            }
    }
}
```

## Platform-Specific Considerations

### iOS (via Objective-C Bridge)

On iOS, the WeatherPackage classes are exposed as:

- `WeatherService` → `WeatherPackageWeatherService` (with module prefix)
- `WeatherData` → `WeatherPackageWeatherData`
- `WeatherError` → `WeatherPackageWeatherError`

You can use these directly in Kotlin/Native:

```kotlin
import WeatherPackage.WeatherService as ObjCWeatherService
import WeatherPackage.WeatherData as ObjCWeatherData
```

### Memory Management

Kotlin/Native uses automatic reference counting (ARC) for Objective-C objects, so you don't need to manually manage memory when using WeatherPackage from Kotlin.

### Threading

The WeatherService uses Alamofire, which handles threading automatically. Callbacks are executed on the main thread by default. If you need to perform background work, use Kotlin coroutines:

```kotlin
viewModelScope.launch(Dispatchers.IO) {
    val result = repository.fetchWeather("Amsterdam")
    withContext(Dispatchers.Main) {
        // Update UI
    }
}
```

## Error Handling

WeatherError enum cases map to Kotlin exceptions:

```kotlin
fun handleWeatherError(error: NSError?) {
    when (error?.code?.toInt()) {
        0 -> println("Network error")
        1 -> println("Invalid location")
        2 -> println("Invalid response")
        3 -> println("Parsing error")
        4 -> println("Unknown error")
        else -> println("Unexpected error")
    }
}
```

## Testing

### Testing iOS Code

You can test the iOS implementation using `XCTest` or by creating test doubles:

```kotlin
// File: shared/src/iosTest/kotlin/com/example/WeatherRepositoryTest.kt

class WeatherRepositoryTest {
    @Test
    fun testFetchWeather() = runBlocking {
        val repository = WeatherRepository()
        val result = repository.fetchWeather("Amsterdam")
        assertTrue(result.isSuccess)
    }
}
```

## Complete Example

Here's a complete example of a KMP module using WeatherPackage:

```kotlin
// commonMain
expect class PlatformWeatherService {
    suspend fun getWeather(location: String): WeatherResult
}

sealed class WeatherResult {
    data class Success(val weather: WeatherInfo) : WeatherResult()
    data class Error(val message: String) : WeatherResult()
}

data class WeatherInfo(
    val location: String,
    val temperatureCelsius: Double,
    val description: String
)

// iosMain
import WeatherPackage.WeatherService
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

actual class PlatformWeatherService {
    actual suspend fun getWeather(location: String): WeatherResult {
        return suspendCoroutine { continuation ->
            WeatherService.shared.fetchWeather(location) { data, error ->
                if (data != null) {
                    continuation.resume(
                        WeatherResult.Success(
                            WeatherInfo(
                                location = data.location,
                                temperatureCelsius = data.temperature,
                                description = data.condition
                            )
                        )
                    )
                } else {
                    continuation.resume(
                        WeatherResult.Error(
                            error?.localizedDescription ?: "Unknown error"
                        )
                    )
                }
            }
        }
    }
}
```

## Troubleshooting

### Issue: Cannot find WeatherPackage module

**Solution**: Ensure the WeatherPackage is added to your iOS framework target in Xcode.

### Issue: Linker errors on iOS

**Solution**: Make sure your iOS deployment target matches the minimum requirements (iOS 13.0+).

### Issue: Callbacks not executing

**Solution**: Check that you're properly managing the Kotlin coroutine lifecycle and not cancelling the coroutine before the callback completes.

## Further Reading

- [Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform.html)
- [Kotlin/Native Interoperability](https://kotlinlang.org/docs/native-objc-interop.html)
- [Alamofire Documentation](https://github.com/Alamofire/Alamofire)

## Support

For issues related to WeatherPackage, please open an issue on the GitHub repository.
For KMP-specific questions, refer to the Kotlin Multiplatform documentation.
