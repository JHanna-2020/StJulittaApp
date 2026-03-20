//
//  SermonsPlaylistVIew.swift
//  App
//
//  Created by John Hanna on 3/11/26.
//
import SwiftUI

struct SermonPlaylistView: View {

    let title: String
    @StateObject private var api: YouTubeAPIService
    @AppStorage("appFontSize") var appFontSize: Double = 16

    init(title: String, playlistId: String) {
        self.title = title
        _api = StateObject(
            wrappedValue: YouTubeAPIService(playlistId: playlistId)
        )
    }

    var body: some View {

        List(api.videos) { video in
            
            NavigationLink {
                SermonView(video: video)
            } label: {

                HStack(spacing: 12) {

                    AsyncImage(url: URL(string: video.thumbnail)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 120, height: 70)
                    .clipped()
                    .cornerRadius(8)

                    Text(video.title)
                        .font(.system(size: appFontSize + 2, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)

                }
            }

        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.system(size: appFontSize + 6, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .onAppear {
            api.fetchVideos()
        }
    }
}
