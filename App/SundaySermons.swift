//
//  SundaySermons.swift
//  App
//
//  Created by John Hanna on 3/14/26.
//

//
//  SundaySermons.swift
//  App
//
//  Created by John Hanna on 3/7/26.
//
import SwiftUI
struct SundnaySermons: View {
    @StateObject var api = YouTubeAPIService(playlistId: Config.sundaysermonspl)
    @AppStorage("appFontSize") var appFontSize: Double = 16
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
                                .font(.system(size: appFontSize))
                                .foregroundColor(.primary)
                        }
                    }
                    .onAppear {
                        if video.videoId == api.videos.last?.videoId {
                            api.fetchVideos()
                        }
                    }
                }
                .navigationTitle("Orthodox Faith Meeting")
                .navigationBarTitleDisplayMode(.large)
                
            }
            .onAppear {
                if api.videos.isEmpty {
                    api.fetchVideos()
                }
            }
        
    }
        
    
}
