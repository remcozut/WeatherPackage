package com.example.weather

import WeatherPackage.WeatherService
import WeatherPackage.WeatherData
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine
import platform.Foundation.NSError

/**
 * iOS implementation of WeatherRepository using WeatherPackage
 */
actual class WeatherRepository {
    
    private val weatherService = WeatherService.shared
    
    /**
     * Fetch weather data once for a given location
     */
    actual suspend fun fetchWeather(location: String): Result<Weather> {
        return suspendCoroutine { continuation ->
            weatherService.fetchWeather(location) { weatherData, error ->
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
    
    /**
     * Start observing weather updates at regular intervals
     */
    actual suspend fun startObservingWeather(
        location: String,
        intervalSeconds: Long,
        onUpdate: (Weather?, String?) -> Unit
    ) {
        weatherService.startObservingWeather(
            location,
            interval = intervalSeconds.toDouble()
        ) { weatherData, error ->
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
                    onUpdate(weather, null)
                }
                error != null -> {
                    onUpdate(null, error.localizedDescription)
                }
                else -> {
                    onUpdate(null, "Unknown error occurred")
                }
            }
        }
    }
    
    /**
     * Stop observing weather updates
     */
    actual fun stopObservingWeather() {
        weatherService.stopObservingWeather()
    }
    
    /**
     * Check if currently observing weather updates
     */
    actual fun isObserving(): Boolean {
        return weatherService.isObserving
    }
}
