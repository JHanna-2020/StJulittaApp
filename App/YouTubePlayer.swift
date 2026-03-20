import SwiftUI
import YouTubeiOSPlayerHelper

struct YouTubePlayer: UIViewRepresentable {

    let videoID: String
    let startSeconds: Int? = nil

    func makeUIView(context: Context) -> YTPlayerView {

        let playerView = YTPlayerView()

        var playerVars: [String: Any] = [
            "playsinline": 1,
            "autoplay": 1,
            "rel": 0
        ]

        if let startSeconds = startSeconds {
            playerVars["start"] = startSeconds
        }

        playerView.load(
            withVideoId: videoID,
            playerVars: playerVars
        )

        return playerView
    }

    func updateUIView(_ uiView: YTPlayerView, context: Context) {
        // No update needed
    }
}
