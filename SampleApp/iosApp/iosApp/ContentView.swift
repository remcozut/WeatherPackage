import SwiftUI
import shared

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModelWrapper()
    @State private var location: String = "Amsterdam"
    @State private var isObserving: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Location Input
                    HStack {
                        TextField("Enter location", text: $location)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                        
                        Button(action: {
                            Task {
                                await viewModel.loadWeather(location: location)
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    
                    // Live Updates Toggle
                    Toggle(isOn: $isObserving) {
                        Text("Live Updates (60s)")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    .onChange(of: isObserving) { newValue in
                        Task {
                            if newValue {
                                await viewModel.startLiveUpdates(location: location, intervalSeconds: 60)
                            } else {
                                viewModel.stopLiveUpdates()
                            }
                        }
                    }
                    
                    // Loading Indicator
                    if viewModel.isLoading {
                        ProgressView("Loading weather...")
                            .padding()
                    }
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    // Weather Information
                    if let weather = viewModel.currentWeather {
                        VStack(spacing: 16) {
                            Text(weather.location)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(weather.getFormattedTemperature())
                                .font(.system(size: 60, weight: .light))
                            
                            Text(weather.condition)
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 40) {
                                VStack {
                                    Image(systemName: "humidity.fill")
                                        .font(.title2)
                                    Text(weather.getFormattedHumidity())
                                        .font(.caption)
                                }
                                
                                VStack {
                                    Image(systemName: "wind")
                                        .font(.title2)
                                    Text(weather.getFormattedWindSpeed())
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(.blue)
                            .padding()
                            
                            Text("Last updated: \(formatTimestamp(weather.timestamp))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Weather KMP Sample")
        }
        .task {
            await viewModel.loadWeather(location: location)
        }
    }
    
    private func formatTimestamp(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// SwiftUI wrapper for Kotlin ViewModel
@MainActor
class WeatherViewModelWrapper: ObservableObject {
    @Published var currentWeather: Weather?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let repository = WeatherRepository()
    private var viewModel: WeatherViewModel
    
    init() {
        viewModel = WeatherViewModel(repository: repository)
    }
    
    func loadWeather(location: String) async {
        isLoading = true
        do {
            try await viewModel.loadWeather(location: location)
            currentWeather = viewModel.getCurrentWeather()
            errorMessage = viewModel.getError()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func startLiveUpdates(location: String, intervalSeconds: Int64) async {
        do {
            try await viewModel.startLiveUpdates(location: location, intervalSeconds: intervalSeconds)
            // Poll for updates
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                Task { @MainActor in
                    self.currentWeather = self.viewModel.getCurrentWeather()
                    self.errorMessage = self.viewModel.getError()
                    if !self.viewModel.isObservingWeather() {
                        timer.invalidate()
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func stopLiveUpdates() {
        viewModel.stopLiveUpdates()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
