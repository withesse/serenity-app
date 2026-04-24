// Siri / Shortcuts donation bridge. Paired with a MethodChannel in Dart
// (channel: "serenity/siri") so session start/complete events can donate
// an NSUserActivity, and voice invocations can launch the app via deep
// link.
//
// Integration (Xcode steps — these can't be scripted from Flutter):
//   1. In AppDelegate.swift, register this handler:
//        import serenity_app
//        override func application(_ app: UIApplication, ...) {
//          let controller = window?.rootViewController as! FlutterViewController
//          SiriBridge.register(with: controller.binaryMessenger)
//          ...
//        }
//      Call it from application(_:didFinishLaunchingWithOptions:).
//   2. Add the "Siri" capability to the Runner target.
//   3. In Info.plist, add NSUserActivityTypes array with:
//        "com.serenity.serenity_app.beginSession"
//   4. Dart side (in player_controller.dart) after loadSession:
//        MethodChannel('serenity/siri').invokeMethod(
//          'donate',
//          {'sessionId': state.sessionId, 'title': state.title},
//        );
//      iOS then surfaces "Begin Midnight Harbour" in Siri / Shortcuts,
//      and "Hey Siri, midnight harbour" deep-links into /player/<id>.

import Foundation
import Intents
import Flutter

final class SiriBridge {
    static func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "serenity/siri",
            binaryMessenger: messenger
        )
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "donate":
                guard let args = call.arguments as? [String: Any],
                      let id = args["sessionId"] as? String,
                      let title = args["title"] as? String else {
                    result(FlutterError(code: "bad_args", message: nil, details: nil))
                    return
                }
                donate(sessionId: id, title: title)
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private static func donate(sessionId: String, title: String) {
        let activity = NSUserActivity(
            activityType: "com.serenity.serenity_app.beginSession"
        )
        activity.title = "Begin \(title)"
        activity.suggestedInvocationPhrase = "Start meditation"
        activity.isEligibleForPrediction = true
        activity.isEligibleForSearch = true
        activity.userInfo = ["sessionId": sessionId]
        // Deep-link payload — when the user invokes the shortcut, iOS opens
        // this URL and Flutter's go_router catches it.
        activity.webpageURL = URL(string: "serenity://player/\(sessionId)")
        activity.persistentIdentifier =
            NSUserActivityPersistentIdentifier(sessionId)
        activity.becomeCurrent()
    }
}
