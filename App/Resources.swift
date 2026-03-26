//
//  Resources.swift
//  App
//
//  Created by John Hanna on 3/21/26.
//

import SwiftUI
import WebKit
struct Resources: View{
    @AppStorage("appFontSize") var appFontSize: Double = 16

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to St. Julitta!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            Text("Find below a list of Resources")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .font(.system(size: appFontSize, weight: .semibold))


            WebView(url: URL(string: "https://docs.google.com/document/d/1dIv-1mrYVYUTX_yqMzfbX7ElcxZ14p838Ni9TvqnvOo/edit?usp=sharing")!)
                .cornerRadius(12)
                .padding()
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Resources")
                    .font(.system(size: appFontSize, weight: .semibold))
            }
        }
    }
    
}

struct DocWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
