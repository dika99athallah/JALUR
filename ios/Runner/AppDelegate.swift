import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var resolvedKey: String?

    if let plistKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !plistKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      resolvedKey = plistKey
    } else {
      let environment = ProcessInfo.processInfo.environment
      if let iosKey = environment["GOOGLE_MAPS_IOS_SDK_KEY"], !iosKey.isEmpty {
        resolvedKey = iosKey
      } else if let legacyIosKey = environment["GOOGLE_MAPS_IOS_KEY"], !legacyIosKey.isEmpty {
        resolvedKey = legacyIosKey
      } else if let sdkFallback = environment["GOOGLE_MAPS_SDK_KEY"], !sdkFallback.isEmpty {
        resolvedKey = sdkFallback
      } else if let sharedServices = environment["GOOGLE_MAPS_SERVICES_KEY"], !sharedServices.isEmpty {
        resolvedKey = sharedServices
      } else if let sharedKey = environment["GOOGLE_MAPS_API_KEY"], !sharedKey.isEmpty {
        resolvedKey = sharedKey
      }
    }

    if let apiKey = resolvedKey {
      GMSServices.provideAPIKey(apiKey)
    } else {
      NSLog("[AppDelegate] Google Maps API key not provided")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
