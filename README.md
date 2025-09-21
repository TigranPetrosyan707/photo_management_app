# PhotoGraphy 📸

A modern Flutter mobile application for comprehensive photo management with intuitive drag-and-drop organization, seamless camera integration, and intelligent storage solutions.

## ✨ Features

### 📱 **Photo Capture & Import**
- **Camera Integration**: Capture photos directly using device camera
- **Gallery Import**: Select multiple photos from device gallery
- **Instant Storage**: Photos saved locally with metadata preservation

### 🖼️ **Photo Management**
- **Grid View**: Clean, organized photo display in chronological order (newest first)
- **Full-Screen View**: Immersive photo viewing with smooth transitions
- **Drag & Drop Reordering**: Intuitive long-press-and-drag to reorganize photos
- **Batch Selection**: Select multiple photos for bulk operations

### 🗑️ **Smart Deletion**
- **Single Photo Deletion**: Delete individual photos with confirmation
- **Bulk Deletion**: Select and delete multiple photos simultaneously
- **Safe Deletion**: Confirmation dialogs prevent accidental deletions

### 🎨 **User Experience**
- **Light & Dark Mode**: System-aware theme switching with persistent preferences
- **Material Design 3**: Modern, clean interface following Google's design principles
- **Smooth Animations**: Hero transitions and fade animations for seamless navigation
- **Error Handling**: Graceful handling of camera permissions and file operations

### 💾 **Data Management**
- **Local Storage**: Photos stored securely on device
- **SQLite Database**: Persistent metadata storage with automatic cleanup
- **Order Preservation**: Photo arrangement saved across app sessions

---

## 🚀 Installation & Setup

### **Prerequisites**

Before installation, ensure you have the following installed on your development machine:

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (3.0.0 or higher)
- **Android Studio** with Android SDK
- **VS Code** or **Android Studio** as IDE
- **Git** for version control

### **Development Environment Setup**

#### **1. Clone Repository**
```bash
git clone https://github.com/TigranPetrosyan707/photo_management_app.git
cd photo_management_app
```

#### **2. Install Dependencies**
```bash
flutter pub get
```

#### **3. Verify Flutter Installation**
```bash
flutter doctor
```
*Ensure all checkmarks are green for your target platform*

---

## 📱 Running on Physical Device (Recommended)

### **Android Device Setup**

#### **Step 1: Enable Developer Options**
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times to enable Developer Options
3. Go to **Settings** → **Developer Options**
4. Enable **USB Debugging**

#### **Step 2: Connect Device**
1. Connect your Android device to computer via **USB cable**
2. Select **File Transfer (MTP)** mode when prompted
3. Accept **USB Debugging** permission on device

#### **Step 3: Verify Device Connection**
```bash
flutter devices
```
*Your device should appear in the list*

#### **Step 4: Run in Debug Mode**
```bash
flutter run --debug
```

### **iOS Device Setup**

#### **Step 1: Development Team Setup**
1. Open `ios/Runner.xcworkspace` in **Xcode**
2. Select **Runner** project → **Signing & Capabilities**
3. Set your **Development Team**
4. Ensure **Bundle Identifier** is unique

#### **Step 2: Device Trust**
1. Connect iPhone/iPad via **Lightning/USB-C cable**
2. Trust the computer when prompted on device
3. Trust the developer profile in **Settings** → **General** → **VPN & Device Management**

#### **Step 3: Run Debug Version**
```bash
flutter run --debug
```

---

## 🛠️ Development Commands

### **Hot Reload** (During Development)
```bash
# Press 'r' in terminal while app is running
r
```

### **Full Restart** (When Hot Reload Fails)
```bash
# Press 'R' in terminal while app is running
R
```
---

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point & configuration
├── models/
│   └── photo.dart           # Photo data model
├── providers/
│   ├── photo_provider.dart  # Photo state management
│   └── theme_provider.dart  # Theme state management
├── screens/
│   ├── photo_gallery_screen.dart    # Main gallery interface
│   └── fullscreen_photo_view.dart   # Full-screen photo viewer
├── services/
│   ├── camera_service.dart          # Camera & gallery operations
│   └── database_service.dart        # SQLite database management
└── widgets/
    ├── empty_photos_widget.dart     # Empty state component
    ├── photo_card.dart              # Individual photo display
    ├── photo_grid.dart              # Photo grid layout
    ├── draggable_photo_card.dart    # Drag & drop component
    ├── add_photo_bottom_sheet.dart  # Photo source selection
    └── delete_confirmation_dialog.dart # Deletion confirmations
```

## 🎯 Usage Guide

### **Adding Photos**
1. Tap the **"+" floating action button**
2. Choose **"Take Photo"** or **"Choose from Gallery"**
3. Photos automatically save with timestamps

### **Organizing Photos**
1. **Long press and drag** any photo to reorder
2. Release over desired position
3. Order automatically saves

### **Selecting & Deleting**
1. Tap **"⋮" menu** → **"Select Photos"**
2. Tap photos to select (circular checkboxes appear)
3. Tap **delete icon** → **confirm deletion**
4. Tap **"✕"** to exit selection mode

### **Theme Switching**
1. Tap **theme icon** in top bar (🌙/☀️)
2. Switches between light and dark modes
3. Preference automatically saved

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Tigran Petrosyan**
- GitHub: [@TigranPetrosyan707](https://github.com/TigranPetrosyan707)
- Repository: [photo_management_app](https://github.com/TigranPetrosyan707/photo_management_app)

---

## 🎉 Acknowledgments

- Flutter Team for the amazing framework
- Material Design for UI/UX guidelines
- Community contributors and testers

---

*Built with ❤️ using Flutter*