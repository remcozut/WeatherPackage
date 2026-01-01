package com.example.weather

import kotlinx.coroutines.*
import java.net.HttpURLConnection
import java.net.URL
import org.json.JSONObject

/**
 * Android implementation of WeatherRepository
 * Uses simple HTTP requests (in production, use Retrofit or Ktor)
 */
actual class WeatherRepository {
    
    private val baseUrl = "http://services.locatienet.com/api/rs/1.0/weather"
    private var observingJob: Job? = null
    
    /**
     * Fetch weather data once for a given location
     */
    actual suspend fun fetchWeather(location: String): Result<Weather> {
        return withContext(Dispatchers.IO) {
            try {
                val url = URL("$baseUrl?location=$location")
                val connection = url.openConnection() as HttpURLConnection
                connection.requestMethod = "GET"
                connection.connectTimeout = 10000
                connection.readTimeout = 10000
                
                if (connection.responseCode == 200) {
                    val response = connection.inputStream.bufferedReader().use { it.readText() }
                    val json = JSONObject(response)
                    
                    val weather = Weather(
                        location = json.getString("location"),
                        temperature = json.getDouble("temperature"),
                        condition = json.getString("condition"),
                        humidity = json.getDouble("humidity"),
                        windSpeed = json.getDouble("wind_speed"),
                        timestamp = json.optLong("timestamp", System.currentTimeMillis() / 1000)
                    )
                    Result.success(weather)
                } else {
                    Result.failure(Exception("HTTP error: ${connection.responseCode}"))
                }
            } catch (e: Exception) {
                Result.failure(e)
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
        // Stop any existing observation
        stopObservingWeather()
        
        // Start new observation
        observingJob = CoroutineScope(Dispatchers.Default).launch {
            while (isActive) {
                fetchWeather(location).fold(
                    onSuccess = { weather -> onUpdate(weather, null) },
                    onFailure = { error -> onUpdate(null, error.message) }
                )
                delay(intervalSeconds * 1000)
            }
        }
    }
    
    /**
     * Stop observing weather updates
     */
    actual fun stopObservingWeather() {
        observingJob?.cancel()
        observingJob = null
    }
    
    /**
     * Check if currently observing weather updates
     */
    actual fun isObserving(): Boolean {
        return observingJob?.isActive == true
    }
}
