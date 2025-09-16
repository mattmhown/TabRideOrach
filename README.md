# 3-Pane Layout Orchestrator (Optimized for Lenovo Tab Plus)

A specialized Android application designed to create and manage 3-pane multi-window layouts on Lenovo tablets, addressing common issues with split-screen and window positioning.

## 🎯 Features

- **Direct Freeform Launching**: Uses Shizuku to launch apps directly in freeform mode, avoiding split-screen activation
- **Precise Window Positioning**: System-level window management for accurate placement
- **Template Management**: Create and save multiple layout configurations
- **Floating Reset Bubble**: One-tap layout restoration from anywhere
- **Quick Settings Tile**: System-integrated reset button
- **Lenovo-Specific Optimizations**: Custom adjustments for various Tab Plus models

## 📋 Requirements

1. **Shizuku** app installed (available on Play Store)
2. **Wireless Debugging** enabled in Developer Options
3. **Overlay permission** for floating controls
4. Android 9+ (API 28+)

## 🔧 Setup Instructions

### One-time Setup:
1. Install [Shizuku](https://shizuku.rikka.app/) from Play Store
2. Enable Developer Options:
   - Settings > About Tablet > Build Number (tap 7 times)
   - Settings > System > Developer Options > Enable "Wireless Debugging"
3. Open Shizuku app and tap "Start" next to Wireless Debugging
4. Open this app and tap "Grant Shizuku Access"
5. Tap "Enable Freeform Flags" once

### Daily Use:
1. Just open Shizuku and tap "Start" (no PC needed after reboot)
2. Use the floating bubble or QS tile to reset layout anytime
3. Configure different app templates for different workflows

## 🚀 Lenovo Tab Plus Optimizations

- **Model-specific Adjustments**: Tailored for TB-X606F/X606X, TB-X306X and other models
- **Enhanced Gesture Control**: Improved swipe/drag recognition for precise positioning
- **Battery Optimization**: Handles Lenovo's aggressive power management
- **UI Adaptations**: Custom layouts for 16:10 aspect ratio screens

## 🏗️ Building from Source

1. Clone this repository
2. Open in Android Studio
3. Build APK with Gradle:
   ```bash
   ./gradlew assembleRelease
