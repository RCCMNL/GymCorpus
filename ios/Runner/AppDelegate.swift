import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let timezoneChannel = FlutterMethodChannel(
        name: "gym_corpus/device_timezone",
        binaryMessenger: controller.binaryMessenger
      )
      timezoneChannel.setMethodCallHandler { call, result in
        if call.method == "getLocalTimezone" {
          result(TimeZone.current.identifier)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }

      let settingsChannel = FlutterMethodChannel(
        name: "gym_corpus/system_settings",
        binaryMessenger: controller.binaryMessenger
      )
      settingsChannel.setMethodCallHandler { call, result in
        if call.method == "openNotificationSettings" {
          guard let url = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(url) else {
            result(false)
            return
          }

          UIApplication.shared.open(url, options: [:]) { success in
            result(success)
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
