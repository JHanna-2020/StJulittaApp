//
//  VideoPlayerScreen.swift
//  App
//
//  Created by John Hanna on 3/8/26.
//
import SwiftUI

struct VideoPlayerScreen: View {

    let videoID: String
    let title: String

    var body: some View {

        VStack {

            YouTubePlayer(videoID: videoID)
                .frame(height: 220)

            Text(title)
                .font(.title3)
                .padding()

            Spacer()
        }
    }
}
