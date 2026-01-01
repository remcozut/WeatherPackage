package com.example.weather.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.weather.Weather
import com.example.weather.WeatherRepository
import com.example.weather.WeatherViewModel
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    WeatherScreen()
                }
            }
        }
    }
}

@Composable
fun WeatherScreen(viewModel: AndroidWeatherViewModel = viewModel()) {
    var location by remember { mutableStateOf("Amsterdam") }
    var isObserving by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    
    LaunchedEffect(Unit) {
        viewModel.loadWeather(location)
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Weather KMP Sample") }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Location Input
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                OutlinedTextField(
                    value = location,
                    onValueChange = { location = it },
                    label = { Text("Enter location") },
                    modifier = Modifier.weight(1f)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Button(
                    onClick = {
                        scope.launch {
                            viewModel.loadWeather(location)
                        }
                    }
                ) {
                    Text("Search")
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Live Updates Toggle
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Live Updates (60s)", style = MaterialTheme.typography.h6)
                Switch(
                    checked = isObserving,
                    onCheckedChange = { checked ->
                        isObserving = checked
                        scope.launch {
                            if (checked) {
                                viewModel.startLiveUpdates(location, 60)
                            } else {
                                viewModel.stopLiveUpdates()
                            }
                        }
                    }
                )
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Loading Indicator
            if (viewModel.isLoading) {
                CircularProgressIndicator()
                Spacer(modifier = Modifier.height(16.dp))
            }
            
            // Error Message
            viewModel.errorMessage?.let { error ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    backgroundColor = Color.Red.copy(alpha = 0.1f)
                ) {
                    Text(
                        text = "Error: $error",
                        modifier = Modifier.padding(16.dp),
                        color = Color.Red
                    )
                }
                Spacer(modifier = Modifier.height(16.dp))
            }
            
            // Weather Information
            viewModel.currentWeather?.let { weather ->
                WeatherCard(weather)
            }
        }
    }
}

@Composable
fun WeatherCard(weather: Weather) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = 4.dp,
        backgroundColor = Color(0xFFE3F2FD)
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = weather.location,
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = weather.getFormattedTemperature(),
                fontSize = 56.sp,
                fontWeight = FontWeight.Light
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = weather.condition,
                fontSize = 20.sp,
                color = Color.Gray
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("💧", fontSize = 24.sp)
                    Text(weather.getFormattedHumidity())
                }
                
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("💨", fontSize = 24.sp)
                    Text(weather.getFormattedWindSpeed())
                }
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = "Last updated: ${formatTimestamp(weather.timestamp)}",
                fontSize = 12.sp,
                color = Color.Gray
            )
        }
    }
}

private fun formatTimestamp(timestamp: Long): String {
    val date = Date(timestamp * 1000)
    val formatter = SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.getDefault())
    return formatter.format(date)
}

@androidx.lifecycle.ViewModel
class AndroidWeatherViewModel : androidx.lifecycle.ViewModel() {
    private val repository = WeatherRepository()
    private val viewModel = WeatherViewModel(repository)
    
    var currentWeather by mutableStateOf<Weather?>(null)
        private set
    
    var errorMessage by mutableStateOf<String?>(null)
        private set
    
    var isLoading by mutableStateOf(false)
        private set
    
    suspend fun loadWeather(location: String) {
        isLoading = true
        viewModel.loadWeather(location)
        updateState()
        isLoading = false
    }
    
    suspend fun startLiveUpdates(location: String, intervalSeconds: Long) {
        viewModel.startLiveUpdates(location, intervalSeconds)
        // Start polling for updates
        kotlinx.coroutines.delay(1000)
        while (viewModel.isObservingWeather()) {
            updateState()
            kotlinx.coroutines.delay(1000)
        }
    }
    
    fun stopLiveUpdates() {
        viewModel.stopLiveUpdates()
        updateState()
    }
    
    private fun updateState() {
        currentWeather = viewModel.getCurrentWeather()
        errorMessage = viewModel.getError()
    }
}
