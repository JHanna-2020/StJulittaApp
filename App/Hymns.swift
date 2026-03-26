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
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(service.files) { file in
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
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
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
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: appFontSize + 2, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(displayName)
                .font(.system(size: appFontSize, weight: .medium))
                .foregroundColor(.primary)

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var iconName: String {
        if file.isFolder { return "folder" }
        if file.mimeType.contains("audio") { return "headphones" }
        return "doc"
    }

    private var displayName: String {
        (file.name as NSString).deletingPathExtension
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

    func fetchFiles(folderID: String) {
        guard let workerURL = URL(string: "https://api.hannagonjohn.workers.dev") else { return }

        var request = URLRequest(url: workerURL)
        request.httpMethod = "POST"

        let endpoint = "https://www.googleapis.com/drive/v3/files?q=%27\(folderID)%27+in+parents+and+trashed=false&fields=files(id,name,mimeType)"

        let body: [String: Any] = [
            "service": "drive",
            "endpoint": endpoint
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                do {
                    let decoded = try JSONDecoder().decode(DriveResponse.self, from: data)
                    self.files = decoded.files.sorted { $0.name < $1.name }
                } catch {
                    print("Decoding error:", error)
                }
            }
            return
        }.resume()
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
