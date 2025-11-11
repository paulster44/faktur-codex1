# Windows Enablement Notes

Windows desktop support is planned. The current codebase isolates platform responsibilities behind `SecureStorage`, `ShareService`, and `AppPathProvider` interfaces (see `lib/src/core/platform/platform_services.dart`). The default implementations in `ServiceRegistry` throw explicit `WindowsPendingImplementation` errors when invoked on Windows so new code can be plugged in later without side effects on iOS or macOS.

To enable Windows:

1. Enable the Windows target in Flutter:
   ```
   flutter config --enable-windows-desktop
   flutter create .
   ```
2. Provide Windows-specific implementations for:
   * Secure storage (e.g., using the Windows Credential Manager or encrypted files).
   * Share service (integrate with the Windows Share contract or file explorer share UI).
   * Path provider (if additional Windows-specific paths are required).
3. Replace the `WindowsPendingImplementation.todo` calls in `ServiceRegistry` with your Windows logic and register the services at startup.
4. Verify PDF preview/print flows with a Windows-friendly solution (e.g., opening generated PDFs using the default handler).

The remainder of the application is platform-agnostic, so once the services are implemented Faktur should run on Windows without UI changes.
