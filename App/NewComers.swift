//
//  NewComers.swift
//  App
//
//  Created by John Hanna on 3/21/26.
//

import SwiftUI
import WebKit

struct NewComers: View {
    @AppStorage("appFontSize") var appFontSize: Double = 16

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to St. Julitta!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            Text("We're glad you're here. Please fill out the form below so we can get to know you better.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .font(.system(size: appFontSize, weight: .semibold))


            WebView(url: URL(string: "https://forms.gle/d5HfHyJ8rCmRUzuw8")!)
                .cornerRadius(12)
                .padding()
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New Comers")
                    .font(.system(size: appFontSize, weight: .semibold))
            }
        }
    }
    
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

#Preview {
    NewComers()
}
