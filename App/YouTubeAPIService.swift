import Foundation
import Combine

class YouTubeAPIService: ObservableObject {
    
    @Published var videos: [YouTubeVideo] = []
    var nextPageToken: String? = nil
    var isLoading = false
    let apiKey = Config.youtubeAPIKey
    let playlistId: String
    
    init(playlistId: String) {
        self.playlistId = playlistId
    }
    func fetchVideos() {
        
        // Prevent multiple simultaneous requests
        if isLoading { return }
        
        // If we already loaded videos and there is no next page, stop
        if !videos.isEmpty && nextPageToken == nil { return }
        
        isLoading = true
        
        var urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=\(playlistId)&key=\(apiKey)"
        
        if let token = nextPageToken {
            urlString += "&pageToken=\(token)"
        }
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            
            do {
                
                guard
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let items = json["items"] as? [[String: Any]]
                else {
                    DispatchQueue.main.async { self.isLoading = false }
                    return
                }
                
                let token = json["nextPageToken"] as? String
                var loadedVideos: [YouTubeVideo] = []
                
                for item in items {
                    
                    guard let snippet = item["snippet"] as? [String: Any] else { continue }
                    
                    let title = snippet["title"] as? String ?? ""
                    
                    // Skip deleted/private videos
                    if title == "Deleted video" || title == "Private video" {
                        continue
                    }
                    
                    let resourceId = snippet["resourceId"] as? [String: Any]
                    let videoId = resourceId?["videoId"] as? String ?? ""
                    
                    let thumbnails = snippet["thumbnails"] as? [String: Any]
                    let high = thumbnails?["high"] as? [String: Any]
                    let medium = thumbnails?["medium"] as? [String: Any]
                    
                    // fallback if high doesn't exist
                    let thumbnail =
                    (high?["url"] as? String) ??
                    (medium?["url"] as? String) ??
                    ""
                    
                    let video = YouTubeVideo(
                        title: title,
                        videoId: videoId,
                        thumbnail: thumbnail
                    )
                    
                    loadedVideos.append(video)
                }
                
                DispatchQueue.main.async {
                    self.nextPageToken = token
                    self.videos.append(contentsOf: loadedVideos)
                    self.isLoading = false
                }
                
            } catch {
                print(error)
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
        }.resume()
    }
}
