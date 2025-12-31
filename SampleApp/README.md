# Weather KMP Sample App

A Kotlin Multiplatform Mobile (KMP) sample application demonstrating integration with the WeatherPackage Swift library for iOS.

## Overview

This sample app showcases:
- ✅ Kotlin Multiplatform Mobile architecture
- ✅ Shared business logic between iOS and Android
- ✅ WeatherPackage integration on iOS via Objective-C bridge
- ✅ Real-time weather updates with configurable intervals
- ✅ SwiftUI for iOS and Jetpack Compose for Android

## Project Structure

```
SampleApp/
├── shared/                          # Shared KMP module
│   ├── src/
│   │   ├── commonMain/             # Common Kotlin code
│   │   │   └── kotlin/
│   │   │       └── com/example/weather/
│   │   │           └── WeatherRepository.kt
│   │   ├── iosMain/                # iOS-specific implementation
│   │   │   └── kotlin/
│   │   │       └── com/example/weather/
│   │   │           └── WeatherRepository.kt  # Uses WeatherPackage
│   │   └── androidMain/            # Android-specific implementation
│   │       └── kotlin/
│   │           └── com/example/weather/
│   │               └── WeatherRepository.kt
│   └── build.gradle.kts
├── iosApp/                          # iOS SwiftUI app
│   └── iosApp/
│       ├── WeatherKMPSampleApp.swift
│       └── ContentView.swift
├── androidApp/                      # Android Compose app
│   └── src/main/
│       ├── java/com/example/weather/android/
│       │   └── MainActivity.kt
│       └── AndroidManifest.xml
├── build.gradle.kts
└── settings.gradle.kts
```

## Features

### Shared Module (`shared`)

The shared module contains:

1. **Common Data Model** (`Weather`):
   - Platform-agnostic weather data representation
   - Helper methods for formatting

2. **Weather Repository Interface** (`WeatherRepository`):
   - `fetchWeather(location)` - One-time weather fetch
   - `startObservingWeather(location, interval)` - Live updates
   - `stopObservingWeather()` - Stop live updates
   - `isObserving()` - Check observation status

3. **Shared ViewModel** (`WeatherViewModel`):
   - Business logic for weather operations
   - State management

### iOS Implementation

The iOS implementation (`iosMain`) uses the **WeatherPackage** Swift library:

```kotlin
actual class WeatherRepository {
    private val weatherService = WeatherService.shared
    
    actual suspend fun fetchWeather(location: String): Result<Weather> {
        return suspendCoroutine { continuation ->
            weatherService.fetchWeather(location) { weatherData, error ->
                // Convert WeatherPackage.WeatherData to common Weather model
            }
        }
    }
    
    actual suspend fun startObservingWeather(...) {
        weatherService.startObservingWeather(location, interval) { ... }
    }
}
```

### Android Implementation

The Android implementation uses standard HTTP networking:

```kotlin
actual class WeatherRepository {
    actual suspend fun fetchWeather(location: String): Result<Weather> {
        // Uses HttpURLConnection or Retrofit
    }
    
    actual suspend fun startObservingWeather(...) {
        // Uses Kotlin Coroutines with delay
    }
}
```

## Setup

### Prerequisites

- Xcode 13+ (for iOS)
- Android Studio Arctic Fox or later
- Kotlin 1.9.20+
- Gradle 8.0+

### iOS Setup

1. **Add WeatherPackage dependency:**

   The iOS app needs to reference the WeatherPackage. You can do this by:
   
   - Opening the `iosApp.xcodeproj` in Xcode
   - File → Add Packages...
   - Add local package: `../../` (points to the WeatherPackage root)
   - Or use the GitHub URL: `https://github.com/remcozut/WeatherPackage.git`

2. **Build the shared framework:**

   ```bash
   cd SampleApp
   ./gradlew :shared:embedAndSignAppleFrameworkForXcode
   ```

3. **Open iOS app in Xcode:**

   ```bash
   open iosApp/iosApp.xcodeproj
   ```

4. **Run the app** on simulator or device

### Android Setup

1. **Open in Android Studio:**

   - Open `SampleApp` directory in Android Studio
   - Wait for Gradle sync to complete

2. **Run the app:**

   - Click Run → Run 'androidApp'
   - Or use: `./gradlew :androidApp:installDebug`

## Usage

### One-time Weather Fetch

Both iOS and Android apps support fetching weather once:

1. Enter a location name (e.g., "Amsterdam", "London")
2. Tap the search button
3. View current weather information

### Live Weather Updates

Enable real-time weather monitoring:

1. Toggle "Live Updates" switch
2. Weather data refreshes automatically every 60 seconds
3. Toggle off to stop updates

## Key Implementation Details

### iOS - WeatherPackage Integration

The iOS implementation bridges WeatherPackage (Swift) to Kotlin/Native:

```kotlin
// In iosMain/kotlin/WeatherRepository.kt
import WeatherPackage.WeatherService
import WeatherPackage.WeatherData

actual class WeatherRepository {
    private val weatherService = WeatherService.shared
    
    actual suspend fun fetchWeather(location: String): Result<Weather> {
        return suspendCoroutine { continuation ->
            weatherService.fetchWeather(location) { weatherData, error ->
                when {
                    weatherData != null -> {
                        // Convert to common Weather model
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
                        continuation.resume(Result.failure(Exception(error.localizedDescription)))
                    }
                }
            }
        }
    }
}
```

### Android - HTTP Integration

The Android implementation uses standard HTTP networking:

```kotlin
// In androidMain/kotlin/WeatherRepository.kt
actual class WeatherRepository {
    actual suspend fun fetchWeather(location: String): Result<Weather> {
        return withContext(Dispatchers.IO) {
            try {
                val url = URL("http://services.locatienet.com/api/rs/1.0/weather?location=$location")
                val connection = url.openConnection() as HttpURLConnection
                // ... HTTP request
                val weather = parseResponse(response)
                Result.success(weather)
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
}
```

### Shared Business Logic

Both platforms share the same ViewModel:

```kotlin
// In commonMain/kotlin/WeatherViewModel.kt
class WeatherViewModel(private val repository: WeatherRepository) {
    suspend fun loadWeather(location: String) {
        repository.fetchWeather(location).fold(
            onSuccess = { weather -> currentWeather = weather },
            onFailure = { error -> errorMessage = error.message }
        )
    }
    
    suspend fun startLiveUpdates(location: String, intervalSeconds: Long) {
        repository.startObservingWeather(location, intervalSeconds) { weather, error ->
            // Update state
        }
    }
}
```

## API Reference

### WeatherRepository (Common Interface)

```kotlin
expect class WeatherRepository {
    suspend fun fetchWeather(location: String): Result<Weather>
    suspend fun startObservingWeather(location: String, intervalSeconds: Long, onUpdate: (Weather?, String?) -> Unit)
    fun stopObservingWeather()
    fun isObserving(): Boolean
}
```

### Weather (Common Model)

```kotlin
data class Weather(
    val location: String,
    val temperature: Double,
    val condition: String,
    val humidity: Double,
    val windSpeed: Double,
    val timestamp: Long
)
```

### WeatherViewModel (Shared Logic)

```kotlin
class WeatherViewModel(private val repository: WeatherRepository) {
    suspend fun loadWeather(location: String)
    suspend fun startLiveUpdates(location: String, intervalSeconds: Long = 60)
    fun stopLiveUpdates()
    fun getCurrentWeather(): Weather?
    fun getError(): String?
    fun isObservingWeather(): Boolean
}
```

## Testing

### Run Shared Tests

```bash
cd SampleApp
./gradlew :shared:testDebugUnitTest
```

### iOS Tests

Open in Xcode and run tests (Cmd+U)

### Android Tests

```bash
./gradlew :androidApp:testDebugUnitTest
```

## Troubleshooting

### iOS Build Issues

1. **WeatherPackage not found:**
   - Ensure WeatherPackage is added to the iOS project
   - Check Swift Package Manager dependencies
   - Clean build folder (Cmd+Shift+K)

2. **Framework not found:**
   - Run `./gradlew :shared:embedAndSignAppleFrameworkForXcode`
   - Check Build Phases → Embed Frameworks

### Android Build Issues

1. **Internet permission:**
   - Ensure AndroidManifest.xml includes `<uses-permission android:name="android.permission.INTERNET" />`

2. **Network on main thread:**
   - All network calls use `Dispatchers.IO`
   - Check coroutine scopes

## Architecture Benefits

### Code Sharing
- ~70% of code shared between iOS and Android
- Business logic written once in Kotlin
- Platform-specific implementations only for networking

### Type Safety
- Shared models ensure consistency
- Compile-time verification across platforms

### Maintainability
- Single source of truth for business logic
- Changes propagate to both platforms
- Easier testing and debugging

## License

This sample app is provided as-is for demonstration purposes.

## Related Documentation

- [WeatherPackage README](../README.md)
- [KMP Integration Guide](../KMP_INTEGRATION.md)
- [Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform.html)
