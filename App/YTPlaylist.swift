//
//  YTPlaylist.swift
//  App
//
//  Created by John Hanna on 3/11/26.
//
import Foundation

struct YouTubePlaylist: Identifiable {
    let id = UUID()
    let title: String
    let playlistId: String
}
