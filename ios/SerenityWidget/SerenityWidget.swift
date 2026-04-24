// Home-screen widget — tonight's recommended session, streak, and a tap to
// jump straight into the player. Paired with an App Group for sharing state
// with the main app.
//
// Integration steps (can't be done from the Flutter side alone — need Xcode):
//   1. In Xcode: File ▸ New ▸ Target ▸ Widget Extension.
//        • Product name: SerenityWidget
//        • Bundle id: com.serenity.serenity_app.SerenityWidget
//        • Include Configuration Intent: NO
//   2. Replace the generated stub with this file.
//   3. Add an App Group ("group.com.serenity.serenity_app") to both the
//      Runner target and SerenityWidget target. The main app writes
//      "tonight_session_id" / "tonight_session_title" / "streak" into
//      UserDefaults(suiteName:) after each home-screen refresh; this
//      widget reads them on each timeline entry.
//   4. Dart side: call a `shared_preferences_ios` or custom MethodChannel
//      writer whenever the Home tab rebuilds.

import WidgetKit
import SwiftUI

struct SerenityEntry: TimelineEntry {
    let date: Date
    let sessionId: String
    let title: String
    let streak: Int
}

struct SerenityTimelineProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.com.serenity.serenity_app")

    func placeholder(in context: Context) -> SerenityEntry {
        SerenityEntry(
            date: Date(),
            sessionId: "drifting-into-stillness",
            title: "Drifting into Stillness",
            streak: 7
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SerenityEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SerenityEntry>) -> Void) {
        // Refresh once an hour — the recommendation shifts on hour boundaries
        // (morning / afternoon / evening / night) so anything finer is wasted
        // budget.
        let now = Date()
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: now)!
        let timeline = Timeline(entries: [makeEntry()], policy: .after(nextHour))
        completion(timeline)
    }

    private func makeEntry() -> SerenityEntry {
        SerenityEntry(
            date: Date(),
            sessionId: defaults?.string(forKey: "tonight_session_id") ?? "drifting-into-stillness",
            title: defaults?.string(forKey: "tonight_session_title") ?? "Tonight's session",
            streak: defaults?.integer(forKey: "streak") ?? 0
        )
    }
}

struct SerenityWidgetView: View {
    let entry: SerenityEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("TONIGHT")
                .font(.caption2).bold()
                .foregroundColor(.white.opacity(0.6))
            Text(entry.title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.yellow)
                Text("\(entry.streak) night streak")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(14)
        .widgetURL(URL(string: "serenity://player/\(entry.sessionId)"))
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.06, blue: 0.15),
                         Color(red: 0.15, green: 0.10, blue: 0.30)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
}

@main
struct SerenityWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "SerenityWidget",
            provider: SerenityTimelineProvider()
        ) { entry in
            SerenityWidgetView(entry: entry)
        }
        .configurationDisplayName("Tonight's Session")
        .description("Your recommended session and current streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
