# Personalized Weather Dashboard (project_224109v)

This is a Flutter application created for the IN3510 (Wireless Communication & Mobile Networks) course assignment. The app generates weather information from the Open-Meteo API by deriving geographic coordinates from a student index number.

## Features

- **Coordinate Derivation:** Calculates latitude and longitude from a given student index number.
- **Live Weather Data:** Fetches and displays current temperature, wind speed, and weather code from the Open-Meteo API.
- **Data Display:** Clearly shows the student index, derived coordinates, the full request URL, and the last update time.
- **Offline Caching:** Saves the last successful weather data locally. If the device is offline, it displays the cached data with an indicator.
- **Error Handling:** Shows user-friendly error messages for invalid index formats or network failures.

## How to Use

1.  Launch the application on an Android device/emulator.
2.  The student index is pre-filled. You can change it if needed.
3.  The app automatically calculates the coordinates.
4.  Press the "Fetch Weather" button to get the latest weather data.
5.  To test the caching feature, disable the network connection and restart the app or press the button again. The previously fetched data will be displayed with a "(cached)" label.

## Technologies Used

- **Framework:** Flutter
- **Language:** Dart
- **Dependencies:**
    - `http`: For making API requests.
    - `shared_preferences`: For local data caching.
    - `intl`: For date and time formatting.
