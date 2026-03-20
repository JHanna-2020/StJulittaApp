//
//  PlaylistLibrary.swift
//  App
//
//  Created by John Hanna on 3/11/26.
//

import Foundation

struct PlaylistLibrary {

    static let sermonPlaylists: [YouTubePlaylist] = [
        YouTubePlaylist(
            title: "Sunday Sermons",
            playlistId: Config.sundaysermonspl
        ),
        YouTubePlaylist(
            title: "Bible Study",
            playlistId: Config.biblestudypl
        ),
        YouTubePlaylist(
            title: "Orthodox Faith Meeting",
            playlistId: Config.orthodoxfaithpl
        )

        

    ]

}
