import SwiftUI
import Combine

// MARK: - Main View

struct ChurchCalendar: View {


    @State private var selectedTab = 0
    @StateObject private var service = CalendarService()
    @State private var selectedEvent: CalendarEvent?
    @State private var currentMonth = Date()
    @AppStorage("appFontSize") var appFontSize: Double = 16

    var body: some View {
        ScrollView {
            VStack {
                AddCalendarButton(appFontSize: appFontSize)

                Picker("", selection: $selectedTab) {
                    Text("Calendar")
                        .font(.system(size: appFontSize))
                        .tag(0)

                    Text("List")
                        .font(.system(size: appFontSize))
                        .tag(1)
                }
                
                .pickerStyle(.segmented)
                

                if selectedTab == 0 {
                    CalendarGridView(events: service.events)
                } else {
                    ListViewSection(
                        currentMonth: $currentMonth,
                        events: currentMonthEvents,
                        selectedEvent: $selectedEvent,
                        appFontSize: appFontSize
                    )
                }
            }
        }
        .padding(.horizontal)
        .onAppear { service.fetchEvents() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Church Calendar")
                    .font(.system(size: appFontSize, weight: .semibold))
            }
        }
        .sheet(item: $selectedEvent) { EventDetailView(event: $0) }
    }

    // MARK: - Computed

    var currentMonthEvents: [CalendarEvent] {
        let calendar = Calendar.current
        let formatter = ISO8601DateFormatter()

        return service.events.compactMap { event -> (CalendarEvent, Date)? in
            guard let dateTime = event.start.dateTime,
                  let date = formatter.date(from: dateTime) else { return nil }
            return (event, date)
        }
        .filter { (_, date) in
            calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) &&
            calendar.isDate(date, equalTo: currentMonth, toGranularity: .year)
        }
        .sorted { $0.1 < $1.1 }
        .map { $0.0 }
    }
}

// MARK: - Reusable Components

struct AddCalendarButton: View {
    let appFontSize: Double

    var body: some View {
        Button(action: addToGoogleCalendar) {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: appFontSize, weight: .semibold))

                Text("Add Church Calendar to My Google Calendar")
                    .font(.system(size: appFontSize, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal)
    }
}

struct MonthHeaderView: View {
    let title: String
    let onPrev: () -> Void
    let onNext: () -> Void
    let fontSize: Double

    var body: some View {
        HStack {
            Button(action: onPrev) {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(title)
                .font(.system(size: fontSize, weight: .semibold))

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
}

struct EventRowView: View {
    let event: CalendarEvent
    let appFontSize: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6 * (appFontSize / 16)) {
            Text(event.summary ?? "No Title")
                .font(.system(size: 14 * (appFontSize / 16), weight: .semibold))
                .foregroundColor(.blue)

            Text(formatDate(event.start))
                .font(.system(size: 12 * (appFontSize / 16)))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10 * (appFontSize / 16))
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private func formatDate(_ eventDate: CalendarEvent.EventDate) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let dateTime = eventDate.dateTime,
           let date = isoFormatter.date(from: dateTime) ?? ISO8601DateFormatter().date(from: dateTime) {
            let display = DateFormatter()
            display.dateStyle = .medium
            display.timeStyle = .short
            display.timeZone = .current
            return display.string(from: date)
        }

        return eventDate.date ?? ""
    }
}

// MARK: - List Section

struct ListViewSection: View {
    @Binding var currentMonth: Date
    let events: [CalendarEvent]
    @Binding var selectedEvent: CalendarEvent?
    let appFontSize: Double

    var body: some View {
        VStack {
            MonthHeaderView(
                title: monthTitle(),
                onPrev: { changeMonth(by: -1) },
                onNext: { changeMonth(by: 1) },
                fontSize: appFontSize + 2
            )

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10 * (appFontSize / 16)) {
                        ForEach(events) { event in
                            EventRowView(event: event, appFontSize: appFontSize)
                                .id(event.id)
                                .onTapGesture { selectedEvent = event }
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear { scrollToToday(proxy: proxy) }
                .onChange(of: currentMonth) { _ in scrollToToday(proxy: proxy) }
            }
        }
    }

    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }

    private func monthTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentMonth)
    }

    private func scrollToToday(proxy: ScrollViewProxy) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let calendar = Calendar.current
        let today = Date()

        if let todayEvent = events.first(where: {
            guard let dateTime = $0.start.dateTime,
                  let date = formatter.date(from: dateTime) ?? ISO8601DateFormatter().date(from: dateTime) else { return false }
            return calendar.isDate(date, inSameDayAs: today)
        }) {
            DispatchQueue.main.async {
                proxy.scrollTo(todayEvent.id, anchor: .top)
            }
            return
        }

        if let upcoming = events.first(where: {
            guard let dateTime = $0.start.dateTime,
                  let date = formatter.date(from: dateTime) ?? ISO8601DateFormatter().date(from: dateTime) else { return false }
            return date > today
        }) {
            DispatchQueue.main.async {
                proxy.scrollTo(upcoming.id, anchor: .top)
            }
        }
    }
}

// MARK: - Existing Code (Unchanged Logic)

struct CalendarGridView: View {
    let events: [CalendarEvent]
    @State private var selectedEvent: CalendarEvent?
    @State private var currentMonth = Date()
    @AppStorage("fontSize") private var fontSize: Double = 1.0
    @AppStorage("appFontSize") private var appFontSize: Double = 16
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        let days = generateDaysInMonth()

        VStack {
            MonthHeaderView(
                title: monthTitle(),
                onPrev: { changeMonth(by: -1) },
                onNext: { changeMonth(by: 1) },
                fontSize: appFontSize
            )

            LazyVGrid(columns: columns, spacing: 10 * fontSize) {
                ForEach(days, id: \.self) { date in
                    CalendarDayCell(
                        date: date,
                        events: eventsForDate(date),
                        fontSize: fontSize,
                        appFontSize: appFontSize,
                        onTap: { selectedEvent = $0 }
                    )
                }
            }
        }
        .sheet(item: $selectedEvent) { EventDetailView(event: $0) }
    }

    // helpers unchanged

    func generateDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let now = currentMonth

        guard let range = calendar.range(of: .day, in: .month, for: now),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return []
        }

        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
    }

    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        let formatter = ISO8601DateFormatter()

        return events.filter {
            guard let dateTime = $0.start.dateTime,
                  let eventDate = formatter.date(from: dateTime) else { return false }
            return Calendar.current.isDate(eventDate, inSameDayAs: date)
        }
    }

    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }

    func monthTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentMonth)
    }
}

struct CalendarDayCell: View {
    let date: Date
    let events: [CalendarEvent]
    let fontSize: Double
    let appFontSize: Double
    let onTap: (CalendarEvent) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2 * fontSize) {
            ZStack {
                if Calendar.current.isDateInToday(date) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 28 * fontSize, height: 28 * fontSize)
                }

                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14 * fontSize, weight: .semibold))
                    .foregroundColor(Calendar.current.isDateInToday(date) ? .white : .primary)
            }

            ForEach(events, id: \.id) { event in
                Text(event.summary ?? "")
                    .font(.system(size: 10 * (appFontSize / 16)))
                    .lineLimit(1)
                    .foregroundColor(.blue)
                    .onTapGesture { onTap(event) }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 60 * fontSize, alignment: .topLeading)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// remaining models + service unchanged

func addToGoogleCalendar() {
    if let url = URL(string:
        "https://calendar.google.com/calendar/u/0/r?cid=admin@stjulittapearland.org") {
        UIApplication.shared.open(url)
    }
}

struct CalendarEvent: Identifiable, Decodable {
    let rawID: String?
    var id: String { rawID ?? UUID().uuidString }
    let summary: String?
    let description: String?
    let location: String?
    let start: EventDate
    let end: EventDate?

    enum CodingKeys: String, CodingKey {
        case rawID = "id"
        case summary, description, location, start, end
    }

    struct EventDate: Decodable {
        let dateTime: String?
        let date: String?
    }
}

struct GoogleResponse: Decodable {
    let items: [CalendarEvent]
}

class CalendarService: ObservableObject {
    @Published var events: [CalendarEvent] = []

    private let apiKey = Config.calAPIKey
    private let calendarID = "admin@stjulittapearland.org"

    func fetchEvents() {
        let encodedCalendarID = calendarID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? calendarID
        let urlString = "https://www.googleapis.com/calendar/v3/calendars/\(encodedCalendarID)/events?key=\(apiKey)&singleEvents=true&orderBy=startTime"

        guard let url = URL(string: urlString) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode(GoogleResponse.self, from: data)

                await MainActor.run {
                    self.events = result.items
                }
            } catch {
                print("Decoding error:", error)
            }
        }
    }
}

struct EventDetailView: View {
    let event: CalendarEvent
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appFontSize") var appFontSize: Double = 16

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .font(.system(size: appFontSize, weight: .semibold))
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text(event.summary ?? "No Title")
                        .font(.system(size: appFontSize, weight: .bold))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start: \(formatDate(event.start))")
                        if let end = event.end {
                            Text("End: \(formatDate(end))")
                        }
                    }
                    .font(.system(size: appFontSize, weight: .semibold))
                    .foregroundColor(.gray)

                    if let location = event.location {
                        SectionBlock(title: "Location", text: location, size: appFontSize)
                    }

                    if let description = event.description {
                        SectionBlock(title: "Details", text: description, size: appFontSize)
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }

    private func formatDate(_ eventDate: CalendarEvent.EventDate) -> String {
        let formatter = ISO8601DateFormatter()

        if let dateTime = eventDate.dateTime,
           let date = formatter.date(from: dateTime) {

            let display = DateFormatter()
            display.dateStyle = .full
            display.timeStyle = .short

            return display.string(from: date)
        }

        return eventDate.date ?? ""
    }
}

struct SectionBlock: View {
    let title: String
    let text: String
    let size: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: size, weight: .semibold))
            Text(text)
                .font(.system(size: size))
        }
    }
}

#Preview {
    ContentView()
}
