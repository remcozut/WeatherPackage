# Quick Start Guide - Weather KMP Sample App

Get up and running with the Weather KMP Sample App in just a few minutes!

## 🚀 Quick Setup

### iOS App

#### Option 1: Using Xcode (Recommended for Testing)

1. **Navigate to the sample app:**
   ```bash
   cd SampleApp/iosApp
   ```

2. **Open in Xcode:**
   ```bash
   open iosApp.xcodeproj
   ```

3. **Add WeatherPackage dependency:**
   - In Xcode: File → Add Packages...
   - Click "Add Local..." 
   - Navigate to and select the WeatherPackage root directory (two levels up)
   - Click "Add Package"

4. **Build and Run:**
   - Select a simulator or device
   - Press Cmd+R or click the Play button

#### Option 2: Using CocoaPods

1. **Install dependencies:**
   ```bash
   cd SampleApp/iosApp
   pod install
   ```

2. **Open workspace:**
   ```bash
   open iosApp.xcworkspace
   ```

3. **Build and Run** (Cmd+R)

### Android App

1. **Open in Android Studio:**
   - Launch Android Studio
   - File → Open
   - Navigate to and select `SampleApp` directory
   - Wait for Gradle sync

2. **Run the app:**
   - Click the green "Run" button
   - Or: Run → Run 'androidApp'
   - Select a device/emulator

## 📱 Using the App

### Fetch Weather Once

1. Enter a location (e.g., "Amsterdam", "Tokyo", "New York")
2. Tap the search/magnifying glass button
3. View the weather information displayed

### Live Weather Updates

1. Toggle the "Live Updates" switch to ON
2. Weather refreshes automatically every 60 seconds
3. Toggle OFF when you're done

## 🏗️ Project Structure Overview

```
SampleApp/
├── shared/              # Shared Kotlin code (iOS + Android)
│   ├── commonMain/     # Common interfaces & models
│   ├── iosMain/        # iOS impl using WeatherPackage
│   └── androidMain/    # Android impl using HTTP
├── iosApp/             # iOS SwiftUI app
└── androidApp/         # Android Compose app
```

## 🔑 Key Features Demonstrated

✅ **Kotlin Multiplatform** - Shared code between iOS and Android  
✅ **WeatherPackage Integration** - Swift package used from Kotlin/Native  
✅ **Objective-C Bridge** - Seamless Swift ↔ Kotlin interop  
✅ **Real-time Updates** - Live weather observation  
✅ **Modern UI** - SwiftUI (iOS) and Jetpack Compose (Android)  

## 🧪 Testing

### iOS
```bash
# In Xcode
Cmd+U
```

### Android
```bash
cd SampleApp
./gradlew :androidApp:testDebugUnitTest
```

## 🐛 Common Issues

### iOS: "Cannot find 'WeatherPackage' in scope"

**Solution:** Add WeatherPackage as a dependency:
1. Xcode → File → Add Packages
2. Add local package (navigate to WeatherPackage root)

### Android: "Unable to resolve dependency"

**Solution:** Ensure you're in the `SampleApp` directory when running Gradle commands

### Network Error on Android

**Solution:** Check AndroidManifest.xml has:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 📚 Learn More

- [Full README](README.md) - Detailed documentation
- [WeatherPackage Docs](../README.md) - Swift package documentation
- [KMP Integration Guide](../KMP_INTEGRATION.md) - Integration details

## 💡 Next Steps

1. **Explore the Code:**
   - Check `shared/src/commonMain` for shared business logic
   - Look at `iosMain` to see WeatherPackage integration
   - Compare with `androidMain` for platform differences

2. **Customize:**
   - Change update intervals
   - Add more weather data fields
   - Customize the UI

3. **Extend:**
   - Add weather forecasts
   - Implement location search
   - Add weather maps

Happy coding! 🎉
