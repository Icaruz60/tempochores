import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Ensure we have a concrete FlutterViewController before registering plugins.
    let flutterRegistry: FlutterPluginRegistry
    if let existingController = window?.rootViewController as? FlutterPluginRegistry {
      flutterRegistry = existingController
    } else {
      let controller = FlutterViewController()
      let newWindow = UIWindow(frame: UIScreen.main.bounds)
      newWindow.rootViewController = controller
      newWindow.makeKeyAndVisible()
      window = newWindow
      flutterRegistry = controller
    }

    GeneratedPluginRegistrant.register(with: flutterRegistry)
    return result
  }
}