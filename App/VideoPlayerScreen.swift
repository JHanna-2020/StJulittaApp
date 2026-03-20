//
//  VideoPlayerScreen.swift
//  App
//
//  Created by John Hanna on 3/8/26.
//
import SwiftUI
import UIKit
import YouTubeiOSPlayerHelper

struct VideoPlayerScreen: View {

    var videoID: String
    var title: String

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 16) {

                YouTubePlayerView(videoID: videoID)
                    .frame(height: 220)
                    .cornerRadius(12)
                Text("Video here")

                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Button("Watch on YouTube") {
                    openYouTube()
                }
                .buttonStyle(.borderedProminent)

            }
            .padding()
        }
        .navigationTitle("Sermon")
    }

    func openYouTube() {

        if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
            UIApplication.shared.open(url)
        }

    }
}


struct YouTubePlayerView: UIViewRepresentable {

    var videoID: String

    func makeUIView(context: Context) -> YTPlayerView {
        let playerView = YTPlayerView()
        playerView.load(withVideoId: videoID)
        return playerView
    }

    func updateUIView(_ uiView: YTPlayerView, context: Context) {
        // Reload video if needed
        uiView.load(withVideoId: videoID)
    }
}
