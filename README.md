# QR Code Generator + Scanner App

A complete Flutter application to generate and scan QR codes.  
This app supports text, URL, and contact QR code generation, as well as scanning and sharing QR codes.  
Built with modern Flutter packages and Material Design.

## Features

- Generate QR codes for:
  - Plain text
  - URLs (with validation)
  - Contacts (vCard format)
- Scan QR codes using the device camera
- Save scanned contacts directly to your device (with permission)
- Open scanned URLs in the browser
- Share QR codes as images
- Modern UI with [Google Fonts](https://pub.dev/packages/google_fonts)
- Cross-platform: Android, iOS, Windows, macOS, Linux, Web

## Screenshots

<!-- Add screenshots here if you have them -->

## Dependencies

This project uses the following Flutter packages:

- [cupertino_icons](https://pub.dev/packages/cupertino_icons): iOS style icons
- [flutter_contacts](https://pub.dev/packages/flutter_contacts): Read/write device contacts
- [google_fonts](https://pub.dev/packages/google_fonts): Custom fonts
- [path_provider](https://pub.dev/packages/path_provider): Access device file paths
- [permission_handler](https://pub.dev/packages/permission_handler): Handle permissions
- [qr_flutter](https://pub.dev/packages/qr_flutter): Generate QR codes
- [screenshot](https://pub.dev/packages/screenshot): Capture widget screenshots
- [url_launcher](https://pub.dev/packages/url_launcher): Open URLs in browser
- [share_plus](https://pub.dev/packages/share_plus): Share files and text
- [mobile_scanner](https://pub.dev/packages/mobile_scanner): Scan QR codes with camera

## Getting Started

1. **Clone this repository:**
   ```sh
   git clone https://github.com/ShamsulHaque12/QR_Code.git
   cd qr_code
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

4. **Build for release (optional):**
   ```sh
   flutter build apk      # Android
   flutter build ios      # iOS
   flutter build web      # Web
   flutter build windows  # Windows
   flutter build macos    # macOS
   flutter build linux    # Linux
   ```

## Project Structure

- `lib/`
  - `main.dart` — App entry point
  - `home_screen.dart` — Home screen UI
  - `qr_genarator_screen.dart` — QR code generator UI and logic
  - `qr_scan_screen.dart` — QR code scanner UI and logic
- `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/` — Platform-specific code
- `pubspec.yaml` — Project configuration and dependencies

## Permissions

This app requests the following permissions:

- **Camera**: For scanning QR codes
- **Contacts**: To save scanned contacts
- **Storage**: To save and share QR code images (if required)

Make sure to grant these permissions for full functionality.

## Contributing

Pull requests are welcome! Please open issues for suggestions or bugs.


**Made with Flutter ❤️**
