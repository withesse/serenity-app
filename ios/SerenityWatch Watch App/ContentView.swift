// Minimal Apple Watch companion — shows the current streak and lets the
// user start the active session from the wrist. Communicates with the
// phone via WCSession.
//
// Integration (Xcode only — cannot be scaffolded from Flutter):
//   1. In Xcode: File ▸ New ▸ Target ▸ Watch App
//        • Product name: SerenityWatch
//        • Interface: SwiftUI
//        • Life cycle: SwiftUI App
//   2. Replace the generated ContentView with this file.
//   3. In the main iOS target, implement WCSessionDelegate to push streak /
//      tonight-session updates whenever progress_store changes. Easiest is
//      a lightweight MethodChannel in Flutter that hands data to a Swift
//      `WatchBridge` singleton which calls `WCSession.default.updateApplicationContext`.
//   4. Swift → Flutter path: tapping "Begin" sends a userInfo message to
//      the phone; the phone's delegate routes the payload to the deep-link
//      plumbing (serenity://player/<id>).

import SwiftUI
import WatchConnectivity

final class WatchSession: NSObject, ObservableObject, WCSessionDelegate {
    @Published var streak: Int = 0
    @Published var sessionId: String = "drifting-into-stillness"
    @Published var sessionTitle: String = "Tonight's session"

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) {}

    func session(_ session: WCSession, didReceiveApplicationContext ctx: [String: Any]) {
        DispatchQueue.main.async {
            if let s = ctx["streak"] as? Int { self.streak = s }
            if let id = ctx["sessionId"] as? String { self.sessionId = id }
            if let t = ctx["sessionTitle"] as? String { self.sessionTitle = t }
        }
    }

    func begin() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["action": "begin", "sessionId": sessionId], replyHandler: nil)
    }
}

struct ContentView: View {
    @StateObject private var watch = WatchSession()

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "moon.stars.fill").foregroundColor(.yellow)
                Text("\(watch.streak)").font(.title2).bold()
                Text("night").font(.caption2).foregroundColor(.secondary)
            }
            Text(watch.sessionTitle)
                .font(.headline).multilineTextAlignment(.center)
                .lineLimit(2)
            Button(action: watch.begin) {
                Label("Begin", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(8)
    }
}
