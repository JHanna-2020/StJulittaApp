//
//  YouTubeVideo.swift
//  App
//
//  Created by John Hanna on 3/7/26.
//
import Foundation

struct YouTubeVideo: Identifiable{
    let id = UUID()
    let title: String
    let videoId: String
    let thumbnail: String
}
