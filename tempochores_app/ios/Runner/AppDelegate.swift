import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private lazy var flutterEngine = FlutterEngine(name: "tempochores_engine")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if !flutterEngine.isRunning {
      flutterEngine.run()
    }
    GeneratedPluginRegistrant.register(with: flutterEngine)

    if window == nil {
      window = UIWindow(frame: UIScreen.main.bounds)
    }
    if !(window?.rootViewController is FlutterViewController) {
      window?.rootViewController = FlutterViewController(
        engine: flutterEngine,
        nibName: nil,
        bundle: nil
      )
    }
    window?.makeKeyAndVisible()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
