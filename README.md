# EcoTrax 🚗⛽

> **Drive smart. Track every drop.**

EcoTrax is a beautifully designed, offline-first Flutter application for tracking fuel economy, refill costs, and vehicle service history. It features a premium "Architectural Porcelain" light UI, multi-car support, station-level analytics, and a sleek glassmorphic aesthetic.

## ✨ Features

### 🚙 Multi-Car Support
- Add unlimited vehicles with custom names, models, fuel types (Petrol, Diesel, CNG, EV), and tank sizes.
- Switch between cars instantly — each vehicle maintains its own independent fuel history, service log, and analytics.

### ⛽ Intelligent Refill Tracking
- Log every refill with precision: Trip Meter, Litres, Fuel Density, Price per Litre, Station, and Trip Type (City/Highway/Mixed).
- **Live Calculations**: Watch the estimated cost and projected km/L update in real-time as you type.
- **"Forgot to log" feature**: Forgot your last reading? Use the reset counter to anchor the trip meter without corrupting your lifetime average economy.

### 📊 Deep Analytics
- **Precision Diagnostics**: Instantly view Cost/km, Best Station, Best Density, and Estimated Tank Range.
- **Lifetime Efficiency**: Track your all-time average vs. your last refill's efficiency.
- **Trend Indicators**: Know instantly if your mileage is improving or dropping.

### 📈 Interactive Graphs (Powered by `fl_chart`)
- **Economy Trend**: A smooth, interactive line chart tracking your km/L over time.
- **Station Efficiency**: Horizontal bar charts ranking fuel stations by their average verified economy.
- **Lifetime Metrics**: A comprehensive breakdown of total fuel bought, total distance tracked, and lifetime running costs.

### 🔧 Service & Maintenance Log
- Keep a detailed logbook of all vehicle maintenance (Oil changes, tyre rotations, brake pads, etc.).
- **Bill Photo Uploads**: Attach photos of your invoices directly to the record using the device camera or gallery.

### 📤 Export & Backup
- **CSV Export**: Export your entire fuel log to a CSV file and share it via WhatsApp, Email, or Google Drive.

## 🎨 UI & Design System
- **Theme**: "Architectural Porcelain Light" — a clean, high-contrast light theme with titanium borders and soft shadows.
- **Typography**: `Plus Jakarta Sans` for standard text and `JetBrains Mono` for precise telemetric data (numbers, dates, and measurements).
- **Layout**: Floating bottom navigation pill, bento-box grid layouts, and clear visual hierarchy.

## 🛠 Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter (Dart) |
| **State Management** | `provider` (ChangeNotifier) |
| **Local Storage** | `shared_preferences` (JSON-encoded) |
| **Charts** | `fl_chart` |
| **Image Handling** | `image_picker`, `path_provider` |
| **Sharing / Export** | `csv`, `share_plus` |
| **Fonts & Icons** | `google_fonts`, `material_symbols_icons` |
| **Formatting** | `intl` |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.3.0)
- Android Studio / Xcode (for emulator/simulator)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/gottabealln/EcoTrax-V2.git
   ```
2. Navigate to the project directory:
   ```bash
   cd EcoTrax-V2
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Building the APK
To build a release APK for Android:
```bash
flutter build apk --release
```
The output file will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## 🧮 How Calculations Work
- **Economy (km/L)** = `Distance since last refill ÷ Litres added`
- **Distance** is computed automatically from consecutive trip meter readings.
- **Skipped Entries**: If you use the "Forgot to log" feature, the entry acts as an anchor for distance calculation but is explicitly excluded from all average economy and analytics calculations.
- **Trend**: Compares the average of your last 3 refills against the 3 before that. (±5% threshold to trigger an up/down arrow).

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! 

## 📜 License
This project is licensed under the MIT License.
```
