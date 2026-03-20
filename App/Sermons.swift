//
//  Sermons.swift
//  App
//
//  Created by John Hanna on 3/8/26.
//
import SwiftUI
struct Sermons: View {
    @AppStorage("appFontSize") var appFontSize: Double = 16
    var body: some View {
        NavigationStack{
            ScrollView{
                
                
                ZStack{
                    VStack{
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {

                            ForEach(PlaylistLibrary.sermonPlaylists) { playlist in
                                
                                NavigationLink {
                                    SermonPlaylistView(
                                        title: playlist.title,
                                        playlistId: playlist.playlistId
                                    )
                                } label: {
                                    VStack {
                                        Image(playlist.title)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100)
                                        
                                        Text(playlist.title)
                                            .font(.system(size: appFontSize + 2, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                
                            }

                        }
                        .padding(.horizontal, 36)
                        .padding(.vertical, 24)
                        
                        
                    }
                    
                    .navigationTitle("Sermons")
                    
                    
                }
            }
        }
    }
}

