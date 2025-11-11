# Faktur

Faktur is an original invoicing experience for iOS and macOS. The project embraces Clean Architecture with Riverpod-powered presentation logic, a Drift database, and an opinionated Material 3 interface designed specifically for this app.

## Project Structure

```
lib/
└── src
    ├── app/                  # FakturApp root widget
    ├── core/                 # Design tokens, platform abstractions
    ├── data/                 # Drift database, repositories, services
    ├── domain/               # Entities, value objects, use cases
    └── presentation/         # Riverpod controllers, routes, screens, widgets
```

* Database migrations and table definitions live in `lib/src/data/local/faktur_database.dart`.
* Riverpod providers for repositories and use cases are consolidated under `lib/src/presentation/state/providers.dart`.
* Adaptive navigation ensures macOS uses a sidebar while iOS uses bottom navigation.

## Getting Started

### Prerequisites

* Flutter 3.19 (stable channel) or newer.
* Xcode 15+ with command line tools for iOS/macOS targets.
* Cocoapods 1.12+ for iOS builds.

### Install Dependencies

```
flutter pub get
```

Generate Drift code before running the app:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running on iOS

```
flutter run -d ios
```

Use the iOS Simulator from Xcode or a connected device. Faktur supports native PDF preview, share, and printing through the `printing` package on Apple platforms.

### Running on macOS

Enable macOS in Flutter (if not already):

```
flutter config --enable-macos-desktop
flutter create .
```

Run the desktop build:

```
flutter run -d macos
```

### Testing

```
flutter test
```

Unit tests cover money arithmetic and invoice total calculations with partial payments.

## Features Overview

* Clients – create, edit, list, and search with Drift-backed persistence.
* Catalog – maintain billable items and tax defaults.
* Invoices – auto-numbering (`INV-{YYYY}-{SEQ}`), tax and discount calculations, overdue detection, and workflow states (Draft → Sent → Partial/Paid/Void).
* Payments – record multiple partial payments; balances and statuses adjust automatically.
* Dashboard – outstanding totals, overdue alerts, recent payments, and top clients by revenue.
* PDF – original layout generated via the `pdf` package and distributed through the adaptive share service.
* Data export/import – JSON and CSV exporters live in the domain layer with validation hooks for UI integration.
* Settings – business profile configuration, encryption toggle placeholder, and manual backup stubs.

## Encryption & Secure Storage

Faktur uses `flutter_secure_storage` for secrets on iOS and macOS. Windows support is intentionally blocked with explicit TODO errors so the platform-specific implementation can be added later without polluting other platforms.

## Drift Encryption (SQLCipher)

A feature flag can wrap the database connection with SQLCipher. Hook into `_openConnection()` inside `lib/src/data/local/faktur_database.dart` to enable encryption once SQLCipher binaries are available.

## Code Style & Tooling

* Static analysis: `analysis_options.yaml` extends `flutter_lints` with documentation-friendly rules.
* Architecture: Clean Architecture ensures presentation stays independent from data sources.
* State: Riverpod for declarative state, plus dedicated providers for repositories and use cases.

## Contributing

1. Fork and clone the repository.
2. Create a feature branch (`git checkout -b feature/awesome`).
3. Run tests before submitting (`flutter test`).
4. Open a pull request with screenshots for visual changes.

## License

See [LEGAL_NOTICES.md](LEGAL_NOTICES.md) for the originality statement and licensing notes.
