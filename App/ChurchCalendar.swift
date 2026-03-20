import SwiftUI
import Combine


struct ChurchCalendar: View {

    @Environment(\.colorScheme) var colorScheme

    @State private var selectedTab = 0
    @StateObject private var service = CalendarService()
    @State private var selectedEvent: CalendarEvent?
    @State private var currentMonth = Date()
    @AppStorage("fontSize") private var fontSize: Double = 1.0
    var body: some View {

        VStack() {
           

            Button {
                addToGoogleCalendar()
            } label: {
                Label(
                    "Add Church Calendar to My Google Calendar",
                    systemImage: "calendar.badge.plus"
                )
            }
            .buttonStyle(.borderedProminent)


            Picker("", selection: $selectedTab) {
                Text("Calendar").tag(0)
                Text("List").tag(1)
            }
            .pickerStyle(.segmented)


            if selectedTab == 0 {
                CalendarGridView(events: service.events)
                    
            } else {
                VStack {
                    HStack {
                        Button {
                            changeMonth(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                        }

                        Spacer()

                        Text(monthTitle())
                            .font(.system(size: 18 * fontSize, weight: .semibold))

                        Spacer()

                        Button {
                            changeMonth(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal)

                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 10 * fontSize) {
                                ForEach(currentMonthEvents) { event in
                                    VStack(alignment: .leading, spacing: 6 * fontSize) {
                                        Text(event.summary ?? "No Title")
                                            .font(.system(size: 14 * fontSize, weight: .semibold))
                                            .foregroundColor(.blue)

                                        Text(formatDate(event.start))
                                            .font(.system(size: 12 * fontSize))
                                            .foregroundColor(.gray)
                                    }
                                    .id(event.id)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(10 * fontSize)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        selectedEvent = event
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .onAppear {
                            scrollToToday(proxy: proxy)
                        }
                        .onChange(of: currentMonth) { _ in
                            scrollToToday(proxy: proxy)
                        }
                    }
                }
            }

        }
        .padding(.horizontal)
        .onAppear {
            service.fetchEvents()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Church Calendar")
                    .font(.system(size: 18 * fontSize, weight: .semibold))
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
    }

    var currentMonthEvents: [CalendarEvent] {
        let calendar = Calendar.current
        let now = currentMonth
        let formatter = ISO8601DateFormatter()

        return service.events.compactMap { event -> (CalendarEvent, Date)? in
            if let dateTime = event.start.dateTime,
               let date = formatter.date(from: dateTime) {
                return (event, date)
            }
            return nil
        }
        .filter { (_, date) in
            calendar.isDate(date, equalTo: now, toGranularity: .month) &&
            calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
        .sorted { $0.1 < $1.1 }
        .map { $0.0 }
    }

    func formatDate(_ eventDate: CalendarEvent.EventDate) -> String {
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

        if let date = eventDate.date {
            return date
        }

        return ""
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

    func scrollToToday(proxy: ScrollViewProxy) {
        let formatter = ISO8601DateFormatter()
        let calendar = Calendar.current
        let today = Date()

        // Try exact today match first
        if let todayEvent = currentMonthEvents.first(where: { event in
            if let dateTime = event.start.dateTime,
               let date = formatter.date(from: dateTime) {
                return calendar.isDate(date, inSameDayAs: today)
            }
            return false
        }) {
            DispatchQueue.main.async {
                proxy.scrollTo(todayEvent.id, anchor: .top)
            }
            return
        }

        // Otherwise scroll to closest upcoming event
        if let upcomingEvent = currentMonthEvents.first(where: { event in
            if let dateTime = event.start.dateTime,
               let date = formatter.date(from: dateTime) {
                return date > today
            }
            return false
        }) {
            DispatchQueue.main.async {
                proxy.scrollTo(upcomingEvent.id, anchor: .top)
            }
        }
    }
}


struct CalendarGridView: View {
    let events: [CalendarEvent]
    @State private var selectedEvent: CalendarEvent?
    @State private var currentMonth = Date()
    @AppStorage("fontSize") private var fontSize: Double = 1.0
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        let days = generateDaysInMonth()

        VStack {
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(monthTitle())
                    .font(.system(size: 18 * fontSize, weight: .semibold))

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 10 * fontSize) {
                ForEach(days, id: \.self) { date in
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

                        ForEach(eventsForDate(date), id: \.id) { event in
                            Text(event.summary ?? "")
                                .font(.system(size: 10 * fontSize))
                                .lineLimit(1)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    selectedEvent = event
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 60 * fontSize, alignment: .topLeading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
    }

    func generateDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let now = currentMonth

        guard let range = calendar.range(of: .day, in: .month, for: now),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return []
        }

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
    }

    func hasEvent(on date: Date) -> Bool {
        let formatter = ISO8601DateFormatter()

        return events.contains { event in
            if let dateTime = event.start.dateTime,
               let eventDate = formatter.date(from: dateTime) {
                return Calendar.current.isDate(eventDate, inSameDayAs: date)
            }
            return false
        }
    }

    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        let formatter = ISO8601DateFormatter()

        return events.filter { event in
            if let dateTime = event.start.dateTime,
               let eventDate = formatter.date(from: dateTime) {
                return Calendar.current.isDate(eventDate, inSameDayAs: date)
            }
            return false
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
        case summary
        case description
        case location
        case start
        case end
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
    @AppStorage("fontSize") private var fontSize: Double = 1.0

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .font(.system(size: 16 * fontSize, weight: .semibold))
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                Text(event.summary ?? "No Title")
                    .font(.system(size: 24 * fontSize, weight: .bold))
                    .multilineTextAlignment(.leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Start: \(formatDate(event.start))")
                    if let end = event.end {
                        Text("End: \(formatDate(end))")
                    }
                }
                .font(.system(size: 16 * fontSize, weight: .semibold))
                .foregroundColor(.gray)

                if let location = event.location {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Location")
                            .font(.system(size: 16 * fontSize, weight: .semibold))
                        Text(location)
                            .font(.system(size: 14 * fontSize))
                    }
                }

                if let description = event.description {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Details")
                            .font(.system(size: 16 * fontSize, weight: .semibold))
                        Text(description)
                            .font(.system(size: 14 * fontSize))
                    }
                }

                    Spacer()
                }
                .padding()
            }
        }
    }

    func formatDate(_ eventDate: CalendarEvent.EventDate) -> String {
        let formatter = ISO8601DateFormatter()

        if let dateTime = eventDate.dateTime,
           let date = formatter.date(from: dateTime) {

            let display = DateFormatter()
            display.dateStyle = .full
            display.timeStyle = .short

            return display.string(from: date)
        }

        if let date = eventDate.date {
            return date
        }

        return ""
    }
}
#Preview {
    ContentView()
}
