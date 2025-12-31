package com.example.weather

/**
 * Common data model for weather information
 */
data class Weather(
    val location: String,
    val temperature: Double,
    val condition: String,
    val humidity: Double,
    val windSpeed: Double,
    val timestamp: Long
) {
    fun getFormattedTemperature(): String = "${temperature}°C"
    fun getFormattedHumidity(): String = "${humidity}%"
    fun getFormattedWindSpeed(): String = "${windSpeed} km/h"
}

/**
 * Expected weather repository interface
 * Platform-specific implementations in iosMain and androidMain
 */
expect class WeatherRepository {
    suspend fun fetchWeather(location: String): Result<Weather>
    suspend fun startObservingWeather(location: String, intervalSeconds: Long, onUpdate: (Weather?, String?) -> Unit)
    fun stopObservingWeather()
    fun isObserving(): Boolean
}

/**
 * Weather ViewModel for shared business logic
 */
class WeatherViewModel(private val repository: WeatherRepository) {
    
    private var currentWeather: Weather? = null
    private var errorMessage: String? = null
    private var isLoading = false
    
    suspend fun loadWeather(location: String) {
        isLoading = true
        errorMessage = null
        
        repository.fetchWeather(location).fold(
            onSuccess = { weather ->
                currentWeather = weather
                isLoading = false
            },
            onFailure = { error ->
                errorMessage = error.message ?: "Unknown error"
                isLoading = false
            }
        )
    }
    
    suspend fun startLiveUpdates(location: String, intervalSeconds: Long = 60) {
        repository.startObservingWeather(location, intervalSeconds) { weather, error ->
            if (weather != null) {
                currentWeather = weather
                errorMessage = null
            } else if (error != null) {
                errorMessage = error
            }
        }
    }
    
    fun stopLiveUpdates() {
        repository.stopObservingWeather()
    }
    
    fun getCurrentWeather(): Weather? = currentWeather
    fun getError(): String? = errorMessage
    fun loading(): Boolean = isLoading
    fun isObservingWeather(): Boolean = repository.isObserving()
}
