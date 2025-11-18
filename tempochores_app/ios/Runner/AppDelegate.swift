import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Let FlutterAppDelegate build the UIWindow/FlutterViewController first.
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let flutterRegistry = window?.rootViewController as? FlutterPluginRegistry {
      GeneratedPluginRegistrant.register(with: flutterRegistry)
    } else {
      // Fallback so hot-reload/dev builds still work if the view controller
      // has not been attached yet.
      GeneratedPluginRegistrant.register(with: self)
    }

    return result
  }
}