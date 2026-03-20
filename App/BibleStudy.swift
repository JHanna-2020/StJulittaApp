//
//  BibleStudy.swift
//  App
//
//  Created by John Hanna on 3/8/26.
//
import SwiftUI
struct BibleStudy: View {
    @StateObject var api = YouTubeAPIService(playlistId: Config.biblestudypl)
    var body: some View{
        
            NavigationView{
                List(api.videos) { video in
                    
                    NavigationLink(destination: VideoPlayerScreen(videoID: video.videoId, title: video.title)) {

                        HStack {

                            if video.title == "Deleted video" {

                                Image("deleted")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 70)
                                    .clipped()

                            } else {

                                AsyncImage(url: URL(string: video.thumbnail)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 120, height: 70)
                                .clipped()

                            }

                            Text(video.title)
                                .foregroundStyle(Color(.systemBlue))
                        }
                    }
                    .onAppear {
                        if video.videoId == api.videos.last?.videoId {
                            api.fetchVideos()
                        }
                    }
                }
                .navigationTitle("Bible Study")
                .navigationBarTitleDisplayMode(.large)
                
            }
            .onAppear {
                if api.videos.isEmpty {
                    api.fetchVideos()
                }
            }
        
    }
        
    
}
