import SwiftUI
import Combine
import AVKit
import PDFKit
struct Hymns: View {
    @AppStorage("appFontSize") private var appFontSize: Double = 16

    var body: some View {
        NavigationView {
            DriveFolderView(folderID: Config.driveFolder, title: "Hymns", appFontSize: appFontSize)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Folder View

struct DriveFolderView: View {
    let folderID: String
    let title: String
    let appFontSize: Double

    @StateObject private var service = DriveService()

    var body: some View {
        List(service.files) { file in
            if file.isFolder {
                NavigationLink(destination:
                    DriveFolderView(folderID: file.id, title: file.name, appFontSize: appFontSize)
                ) {
                    RowView(file: file, appFontSize: appFontSize)
                }
            } else {
                if file.mimeType.contains("audio") {
                    NavigationLink(destination: AudioPlayerView(file: file, appFontSize: appFontSize)) {
                        RowView(file: file, appFontSize: appFontSize)
                    }
                } else if file.mimeType == "application/pdf" {
                    NavigationLink(destination: PDFViewer(file: file)) {
                        RowView(file: file, appFontSize: appFontSize)
                    }
                } else {
                    Button {
                        let url = "https://drive.google.com/file/d/\(file.id)/view"
                        if let link = URL(string: url) {
                            UIApplication.shared.open(link)
                        }
                    } label: {
                        RowView(file: file, appFontSize: appFontSize)
                    }
                }
            }
        }
        .navigationTitle(title)
        .onAppear {
            service.fetchFiles(folderID: folderID)
        }
    }
}

// MARK: - Row

struct RowView: View {
    let file: DriveFile
    let appFontSize: Double

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: appFontSize, weight: .semibold))
                .foregroundColor(.blue)

            Text(file.name)
                .font(.system(size: appFontSize))

            Spacer()

            if file.isFolder {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 6)
    }

    private var iconName: String {
        if file.isFolder { return "folder" }
        if file.mimeType.contains("audio") { return "headphones" }
        return "doc"
    }
}

// MARK: - Models

struct DriveResponse: Decodable {
    let files: [DriveFile]
}

struct DriveFile: Decodable, Identifiable {
    let id: String
    let name: String
    let mimeType: String

    var isFolder: Bool {
        mimeType == "application/vnd.google-apps.folder"
    }
}

// MARK: - Service

class DriveService: ObservableObject {
    @Published var files: [DriveFile] = []

    private let apiKey = Config.driveAPIKey

    func fetchFiles(folderID: String) {
        let query = "https://www.googleapis.com/drive/v3/files?q=%27\(folderID)%27+in+parents+and+trashed=false&fields=files(id,name,mimeType)&key=\(apiKey)"
        guard let url = URL(string: query) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode(DriveResponse.self, from: data)

                await MainActor.run {
                    self.files = result.files.sorted { $0.name < $1.name }
                }
            } catch {
                // Handle error silently or add user-facing error later
            }
        }
    }
}

//# MARK: - Audio Player

struct AudioPlayerView: View {
    let file: DriveFile
    let appFontSize: Double

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 1
    @State private var playbackRate: Float = 1.0

    private var streamURL: URL? {
        URL(string: "https://drive.google.com/uc?export=download&id=\(file.id)")
    }

    var body: some View {
        VStack(spacing: 30) {
            Text(file.name)
                .font(.system(size: appFontSize, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.top)

            // Progress Bar
            VStack {
                Slider(value: $currentTime, in: 0...duration, onEditingChanged: { editing in
                    if !editing {
                        let time = CMTime(seconds: currentTime, preferredTimescale: 600)
                        player?.seek(to: time)
                    }
                })

                HStack {
                    Text(formatTime(currentTime))
                    Spacer()
                    Text(formatTime(duration))
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding(.horizontal)

            // Controls
            HStack(spacing: 40) {
                Button {
                    seek(by: -15)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.title2)
                }

                Button {
                    togglePlay()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                }

                Button {
                    seek(by: 15)
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.title2)
                }
            }

            // Playback Speed
            HStack(spacing: 16) {
                Text("Speed")
                    .font(.system(size: appFontSize))

                ForEach([0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { rate in
                    Button {
                        setPlaybackRate(rate)
                    } label: {
                        Text(String(format: "%.2gx", rate))
                            .font(.system(size: appFontSize * 0.9))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(playbackRate == Float(rate) ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(6)
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("Now Playing")
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }

    private func setupPlayer() {
        guard let url = streamURL else { return }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        let newPlayer = AVPlayer(url: url)
        player = newPlayer

        // Get duration properly (async)
        if let item = newPlayer.currentItem {
            Task {
                do {
                    let asset = item.asset
                    let durationTime = try await asset.load(.duration)
                    let seconds = CMTimeGetSeconds(durationTime)

                    if seconds.isFinite {
                        await MainActor.run {
                            self.duration = seconds
                        }
                    }
                } catch {
                    // ignore
                }
            }
        }

        addTimeObserver()
        newPlayer.play()
        isPlaying = true
    }

    private func togglePlay() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.rate = playbackRate
        }
        isPlaying.toggle()
    }

    private func setPlaybackRate(_ rate: Double) {
        playbackRate = Float(rate)
        player?.rate = isPlaying ? playbackRate : 0
    }

    private func seek(by seconds: Double) {
        guard let player = player else { return }
        let newTime = max(0, min(currentTime + seconds, duration))
        let time = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: time)
    }

    private func addTimeObserver() {
        guard let player = player else { return }

        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = time.seconds
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - PDF Viewer

struct PDFViewer: View {
    let file: DriveFile

    private var url: URL? {
        URL(string: "https://drive.google.com/uc?export=download&id=\(file.id)")
    }

    var body: some View {
        VStack {
            if let url = url {
                PDFKitView(url: url)
            } else {
                Text("Unable to load PDF")
            }
        }
        .navigationTitle(file.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    static let cache = NSCache<NSURL, NSData>()

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous

        loadPDF(into: pdfView)

        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {}

    private func loadPDF(into pdfView: PDFView) {
        // Check cache first
        if let cachedData = Self.cache.object(forKey: url as NSURL) {
            pdfView.document = PDFDocument(data: cachedData as Data)
            return
        }

        // Download in background
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            // Cache it
            Self.cache.setObject(data as NSData, forKey: url as NSURL)

            DispatchQueue.main.async {
                pdfView.document = PDFDocument(data: data)
            }
        }.resume()
    }
}

#Preview {
    Hymns()
}
