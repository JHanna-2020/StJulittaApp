//
//  SundaySchool.swift
//  App
//
//  Created by John Hanna on 3/20/26.
//
import SwiftUI
struct SundaySchool: View {
    @AppStorage("appFontSize") var appFontSize: Double = 16
    var body: some View {
        Image("img")
        Text("Contact one of the Sunday school servants to make an account")
            .font(.system(size: appFontSize))
        Button(action: openSundaySchool) {
            HStack(spacing: 8) {
                Text("St. Juliita Sunday School")
                    .font(.system(size: appFontSize, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal)
    }
}
func openSundaySchool() {
    if let url = URL(string:
        "http://aar-sds.atwebpages.com") {
        UIApplication.shared.open(url)
    }
}
 

